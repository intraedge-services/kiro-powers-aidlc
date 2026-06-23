#!/bin/bash
# ══════════════════════════════════════════════════════════════════════════════
# AIDLC Bootstrap — Zero-Prompt Setup
# ══════════════════════════════════════════════════════════════════════════════
#
# Auto-detects everything from your workspace. No questions asked.
#
# What it does:
#   1. Reads git remote → extracts org, repo, branch
#   2. Reads package.json / pyproject.toml → detects language, framework
#   3. Checks gh CLI → finds project board number
#   4. Generates project-config.md with smart defaults
#   5. Creates folder structure, installs steering + hooks
#
# Usage:
#   cd /path/to/your-project
#   path/to/kiro-powers-aidlc/scripts/setup-aidlc.sh
#
# Override auto-detection with flags:
#   --org NAME        GitHub org (default: from git remote)
#   --repo NAME       GitHub repo (default: from git remote)
#   --board NUMBER    Project board number (default: auto-detect or skip)
#   --lead USERNAME   Team lead GitHub username (default: current gh user)
#   --lang LANGUAGE   Primary language (default: auto-detect)
#   --interactive     Force interactive mode (ask all questions)
#
# ══════════════════════════════════════════════════════════════════════════════

set -uo pipefail

# ── Colors ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()    { echo -e "${BLUE}ℹ${NC}  $1"; }
success() { echo -e "${GREEN}✓${NC}  $1"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $1"; }

# ── Defaults ─────────────────────────────────────────────────────────────────
WORKSPACE_ROOT="$(pwd)"
INTERACTIVE=false
GITHUB_ORG=""
GITHUB_REPO=""
BOARD_NUMBER=""
TEAM_LEAD=""
LANGUAGE=""
DEFAULT_BRANCH=""

# ── Parse flags ──────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --org) GITHUB_ORG="$2"; shift 2 ;;
    --repo) GITHUB_REPO="$2"; shift 2 ;;
    --board) BOARD_NUMBER="$2"; shift 2 ;;
    --lead) TEAM_LEAD="$2"; shift 2 ;;
    --lang) LANGUAGE="$2"; shift 2 ;;
    --interactive) INTERACTIVE=true; shift ;;
    -h|--help)
      echo "Usage: $0 [--org NAME] [--repo NAME] [--board NUMBER] [--lead USER] [--lang LANG] [--interactive]"
      exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Resolve Power Directory ──────────────────────────────────────────────────
POWER_DIR=""
if [ -n "${BASH_SOURCE[0]}" ] && [ "${BASH_SOURCE[0]}" != "bash" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  candidate="$(dirname "$SCRIPT_DIR")"
  if [ -d "$candidate/workflows" ] && [ -f "$candidate/POWER.md" ]; then
    POWER_DIR="$candidate"
  fi
fi
[ -z "$POWER_DIR" ] && [ -d ".kiro/powers/kiro-powers-aidlc/workflows" ] && \
  POWER_DIR="$(cd ".kiro/powers/kiro-powers-aidlc" && pwd)"

# ══════════════════════════════════════════════════════════════════════════════
# AUTO-DETECTION
# ══════════════════════════════════════════════════════════════════════════════

echo ""
echo -e "${BOLD}${CYAN}  AIDLC Setup${NC} ${DIM}— auto-detecting project configuration${NC}"
echo ""

# ── Git Remote → provider, org, repo, branch ────────────────────────────────
PROVIDER=""
if [ -z "$GITHUB_ORG" ] || [ -z "$GITHUB_REPO" ]; then
  remote_url=$(git remote get-url origin 2>/dev/null || echo "")
  if [ -n "$remote_url" ]; then
    # Detect provider from remote URL
    if echo "$remote_url" | grep -q "github.com"; then
      PROVIDER="github"
    elif echo "$remote_url" | grep -q "gitlab"; then
      PROVIDER="gitlab"
    elif echo "$remote_url" | grep -q "bitbucket"; then
      PROVIDER="bitbucket"
    elif echo "$remote_url" | grep -q "dev.azure.com"; then
      PROVIDER="azure-devops"
    else
      PROVIDER="github"
    fi
    # Extract org and repo (works for github, gitlab, bitbucket SSH/HTTPS patterns)
    GITHUB_ORG="${GITHUB_ORG:-$(echo "$remote_url" | sed -E 's|.*[:/]([^/]+)/[^/]+(\.git)?$|\1|')}"
    GITHUB_REPO="${GITHUB_REPO:-$(echo "$remote_url" | sed -E 's|.*[:/][^/]+/([^.]+)(\.git)?$|\1|')}"
  fi
fi
PROVIDER="${PROVIDER:-github}"

if [ -z "$DEFAULT_BRANCH" ]; then
  DEFAULT_BRANCH=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|origin/||' || echo "main")
  [ -z "$DEFAULT_BRANCH" ] && DEFAULT_BRANCH="main"
fi

PROJECT_NAME="${GITHUB_REPO:-$(basename "$WORKSPACE_ROOT")}"

# ── gh CLI → current user, project board ─────────────────────────────────────
if [ -z "$TEAM_LEAD" ]; then
  TEAM_LEAD=$(gh api user --jq '.login' 2>/dev/null || echo "")
fi

if [ -z "$BOARD_NUMBER" ] && [ -n "$GITHUB_ORG" ]; then
  # Try to find the first project board for the org
  BOARD_NUMBER=$(gh project list --owner "$GITHUB_ORG" --format json --jq '.[0].number' 2>/dev/null || echo "")
fi

# ── Language Detection ───────────────────────────────────────────────────────
if [ -z "$LANGUAGE" ]; then
  if [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
    LANGUAGE="Python"
  elif [ -f "package.json" ]; then
    if grep -q '"typescript"' package.json 2>/dev/null; then
      LANGUAGE="TypeScript"
    else
      LANGUAGE="JavaScript"
    fi
  elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
    LANGUAGE="Java"
  elif [ -f "go.mod" ]; then
    LANGUAGE="Go"
  elif [ -f "Cargo.toml" ]; then
    LANGUAGE="Rust"
  else
    LANGUAGE="Python"
  fi
fi

# ── Framework Detection ──────────────────────────────────────────────────────
FRAMEWORK=""
if [ -f "cdk.json" ]; then
  FRAMEWORK="AWS CDK"
elif [ -f "terraform.tf" ] || [ -d ".terraform" ] || ls *.tf &>/dev/null 2>&1; then
  FRAMEWORK="Terraform"
elif [ -f "serverless.yml" ]; then
  FRAMEWORK="Serverless Framework"
elif [ -f "package.json" ] && grep -q "next" package.json 2>/dev/null; then
  FRAMEWORK="Next.js"
elif [ -f "package.json" ] && grep -q "react" package.json 2>/dev/null; then
  FRAMEWORK="React"
fi

# ── Print what we found ──────────────────────────────────────────────────────
success "Provider: $PROVIDER"
success "Org: ${GITHUB_ORG:-<not detected>}"
success "Repo: ${GITHUB_REPO:-<not detected>}"
success "Branch: $DEFAULT_BRANCH"
success "Lead: ${TEAM_LEAD:-<not detected>}"
success "Board: ${BOARD_NUMBER:-<none>}"
success "Language: $LANGUAGE"
[ -n "$FRAMEWORK" ] && success "Framework: $FRAMEWORK"
echo ""

# ── Interactive fallback for missing required values ─────────────────────────
if [ -z "$GITHUB_ORG" ] || [ "$INTERACTIVE" = true ]; then
  echo -ne "${BOLD}GitHub org${NC}: " >&2; read -r GITHUB_ORG
fi
if [ -z "$GITHUB_REPO" ] || [ "$INTERACTIVE" = true ]; then
  echo -ne "${BOLD}GitHub repo${NC}: " >&2; read -r GITHUB_REPO
fi

# ══════════════════════════════════════════════════════════════════════════════
# GENERATE project-config.md
# ══════════════════════════════════════════════════════════════════════════════

mkdir -p "$WORKSPACE_ROOT/.kiro/steering"

cat > "$WORKSPACE_ROOT/.kiro/steering/project-config.md" << EOF
---
inclusion: always
---
# Project Configuration

## Project Identity

- **Name**: ${PROJECT_NAME}
- **Default Branch**: ${DEFAULT_BRANCH}

## Source Control

- **Provider**: ${PROVIDER}
- **Org/Owner**: ${GITHUB_ORG}
- **Repo**: ${GITHUB_REPO}

## Project Tracking

- **Board Provider**: ${PROVIDER}-projects
- **Board ID**: ${BOARD_NUMBER:-none}

## Team

- **Lead**: ${TEAM_LEAD}

## Tech Stack

- **Language**: ${LANGUAGE}
${FRAMEWORK:+- **Framework**: $FRAMEWORK}

## AIDLC Preferences

- **Auto-create Issues**: yes
- **Auto-sync Board**: yes

## Installed Powers Registry

| Category | Power Name | Activate During |
|----------|-----------|------------------|

EOF

success "Generated .kiro/steering/project-config.md"

# ══════════════════════════════════════════════════════════════════════════════
# CREATE FOLDER STRUCTURE + INSTALL FILES
# ══════════════════════════════════════════════════════════════════════════════

# Folders
mkdir -p "$WORKSPACE_ROOT/.kiro/hooks"
mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/common"
mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/inception"
mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/construction"
mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/operations"
mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/extensions"
mkdir -p "$WORKSPACE_ROOT/aidlc-docs/inception/user-stories"
mkdir -p "$WORKSPACE_ROOT/aidlc-docs/construction/build-and-test"
success "Created folder structure"

# Steering files
if [ -n "$POWER_DIR" ] && [ -d "$POWER_DIR/steering" ]; then
  for f in "$POWER_DIR/steering/"*.md; do
    [ -f "$f" ] || continue
    fname="$(basename "$f")"
    [ "$fname" = "project-config-template.md" ] && continue
    cp "$f" "$WORKSPACE_ROOT/.kiro/steering/$fname" 2>/dev/null
  done
  success "Installed steering files"
fi

# Workflow rule-details
if [ -n "$POWER_DIR" ] && [ -d "$POWER_DIR/workflows" ]; then
  cp "$POWER_DIR/workflows/common/"*.md "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/common/" 2>/dev/null
  cp "$POWER_DIR/workflows/inception/"*.md "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/inception/" 2>/dev/null
  cp "$POWER_DIR/workflows/construction/"*.md "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/construction/" 2>/dev/null
  cp "$POWER_DIR/workflows/operations/"*.md "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/operations/" 2>/dev/null
  [ -d "$POWER_DIR/workflows/extensions" ] && cp -R "$POWER_DIR/workflows/extensions/"* "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/extensions/" 2>/dev/null
  success "Installed workflow rules"
fi

# Hooks
if [ -n "$POWER_DIR" ] && [ -d "$POWER_DIR/hooks" ]; then
  cp "$POWER_DIR/hooks/"*.json "$WORKSPACE_ROOT/.kiro/hooks/" 2>/dev/null
  success "Installed hooks"
fi

# AIDLC state
if [ ! -f "$WORKSPACE_ROOT/aidlc-docs/aidlc-state.md" ]; then
  cat > "$WORKSPACE_ROOT/aidlc-docs/aidlc-state.md" << 'STATEEOF'
# AIDLC State
- **Phase**: Not Started
- **Stage**: N/A
STATEEOF
fi

# Audit log
if [ ! -f "$WORKSPACE_ROOT/aidlc-docs/audit.md" ]; then
  echo "# AIDLC Audit Log" > "$WORKSPACE_ROOT/aidlc-docs/audit.md"
fi

# ══════════════════════════════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════════════════════════════

echo ""
echo -e "${BOLD}${GREEN}Done!${NC} AIDLC configured for ${CYAN}${GITHUB_ORG}/${GITHUB_REPO}${NC} (${PROVIDER})"
echo ""
echo -e "  ${DIM}To start:${NC} ${GREEN}\"Using AI-DLC, build me ...\"${NC}"
echo -e "  ${DIM}To customize:${NC} edit ${CYAN}.kiro/steering/project-config.md${NC}"
echo ""
