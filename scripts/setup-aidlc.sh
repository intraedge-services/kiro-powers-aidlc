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
# Upgrade behavior:
#   - If AIDLC is already installed: compares versions
#   - If current: prints "already up to date" and exits
#   - If outdated: prompts before overwriting any files
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
#   --force           Skip upgrade prompt and overwrite
#
# Platform compatibility:
#   Mac/Linux: Run directly with bash
#   Windows (WSL): Run inside WSL terminal (bash compatible)
#   Windows (native): Use Git Bash or convert to PowerShell equivalent
#
# ══════════════════════════════════════════════════════════════════════════════

set -uo pipefail

# ── Current Power Version ────────────────────────────────────────────────────
# Bump this on each release of the power
AIDLC_POWER_VERSION="1.2.0"

# ── Colors ───────────────────────────────────────────────────────────────────
# Mac/Linux: ANSI escape codes work natively
# Windows (WSL): Works in WSL terminal
# Windows (native): Use Windows Terminal or Git Bash for color support
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info()    { echo -e "${BLUE}ℹ${NC}  $1"; }
success() { echo -e "${GREEN}✓${NC}  $1"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $1"; }
error()   { echo -e "${RED}✗${NC}  $1"; }

# ── Defaults ─────────────────────────────────────────────────────────────────
WORKSPACE_ROOT="$(pwd)"
INTERACTIVE=false
FORCE=false
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
    --force) FORCE=true; shift ;;
    -h|--help)
      echo "Usage: $0 [--org NAME] [--repo NAME] [--board NUMBER] [--lead USER] [--lang LANG] [--interactive] [--force]"
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
# UPGRADE DETECTION
# ══════════════════════════════════════════════════════════════════════════════

INSTALLED_VERSION=""
IS_UPGRADE=false
IS_FRESH_INSTALL=true

# Check .aidlc-version file first (preferred)
if [ -f "$WORKSPACE_ROOT/.aidlc-version" ]; then
  INSTALLED_VERSION=$(cat "$WORKSPACE_ROOT/.aidlc-version" | tr -d '[:space:]')
  IS_FRESH_INSTALL=false
fi

# Fallback: check aidlc-state.md for version marker
if [ -z "$INSTALLED_VERSION" ] && [ -f "$WORKSPACE_ROOT/aidlc-docs/aidlc-state.md" ]; then
  state_version=$(grep -oP '(?<=AIDLC Version: ).*' "$WORKSPACE_ROOT/aidlc-docs/aidlc-state.md" 2>/dev/null || echo "")
  # Mac/Linux grep -oP may not work on macOS; use sed fallback
  # Mac/Linux (macOS sed):
  #   state_version=$(sed -n 's/.*AIDLC Version: \(.*\)/\1/p' aidlc-docs/aidlc-state.md)
  # Windows (WSL): grep -oP works natively
  # Windows (native PowerShell):
  #   $version = (Select-String -Path "aidlc-docs\aidlc-state.md" -Pattern "AIDLC Version: (.*)").Matches.Groups[1].Value
  if [ -z "$state_version" ]; then
    # macOS-compatible fallback
    state_version=$(sed -n 's/.*AIDLC Version: \(.*\)/\1/p' "$WORKSPACE_ROOT/aidlc-docs/aidlc-state.md" 2>/dev/null || echo "")
  fi
  if [ -n "$state_version" ]; then
    INSTALLED_VERSION="$state_version"
    IS_FRESH_INSTALL=false
  fi
fi

# Fallback: if aidlc-state.md exists but has no version, assume pre-versioning install
if [ "$IS_FRESH_INSTALL" = true ] && [ -f "$WORKSPACE_ROOT/aidlc-docs/aidlc-state.md" ]; then
  if [ -f "$WORKSPACE_ROOT/.kiro/steering/project-config.md" ]; then
    INSTALLED_VERSION="0.0.0"
    IS_FRESH_INSTALL=false
  fi
fi

# ── Version comparison decision ──────────────────────────────────────────────
if [ "$IS_FRESH_INSTALL" = false ]; then
  if [ "$INSTALLED_VERSION" = "$AIDLC_POWER_VERSION" ]; then
    echo ""
    echo -e "${BOLD}${GREEN}  AIDLC already up to date${NC} (v${AIDLC_POWER_VERSION})"
    echo ""
    echo -e "  ${DIM}Nothing to do. Your workspace is current.${NC}"
    echo ""
    exit 0
  fi

  # Installed but outdated
  IS_UPGRADE=true
  echo ""
  echo -e "${BOLD}${CYAN}  AIDLC Upgrade Available${NC}"
  echo ""
  echo -e "  Installed: ${YELLOW}v${INSTALLED_VERSION}${NC}"
  echo -e "  Available: ${GREEN}v${AIDLC_POWER_VERSION}${NC}"
  echo ""

  if [ "$FORCE" = false ]; then
    echo -ne "  ${BOLD}Upgrade from v${INSTALLED_VERSION} to v${AIDLC_POWER_VERSION}? (y/n):${NC} " >&2
    read -r upgrade_answer
    if [[ ! "$upgrade_answer" =~ ^[Yy]$ ]]; then
      echo ""
      info "Upgrade cancelled. No files were changed."
      exit 0
    fi
  else
    info "Force flag set — proceeding with upgrade"
  fi
  echo ""
fi

# ══════════════════════════════════════════════════════════════════════════════
# AUTO-DETECTION
# ══════════════════════════════════════════════════════════════════════════════

echo ""
echo -e "${BOLD}${CYAN}  AIDLC Setup${NC} ${DIM}— auto-detecting project configuration${NC}"
echo ""

# ── Git Remote → provider, org, repo, branch ────────────────────────────────
# Mac/Linux: git commands work natively
# Windows (WSL): git commands work natively
# Windows (native): Ensure git is in PATH (comes with Git for Windows)
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
# Mac/Linux: brew install gh
# Windows (WSL): sudo apt install gh  OR  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
# Windows (native): winget install GitHub.cli  OR  choco install gh
if [ -z "$TEAM_LEAD" ]; then
  TEAM_LEAD=$(gh api user --jq '.login' 2>/dev/null || echo "")
fi

if [ -z "$BOARD_NUMBER" ] && [ -n "$GITHUB_ORG" ]; then
  # Try to find the first project board for the org
  BOARD_NUMBER=$(gh project list --owner "$GITHUB_ORG" --format json --jq '.[0].number' 2>/dev/null || echo "")
fi

# ── Language Detection ───────────────────────────────────────────────────────
# Mac/Linux: file existence checks work natively
# Windows (WSL): Same as Linux
# Windows (native PowerShell): Test-Path "pyproject.toml" etc.
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
# GENERATE project-config.md (only on fresh install or if missing)
# ══════════════════════════════════════════════════════════════════════════════

# Mac/Linux: mkdir -p works natively
# Windows (WSL): Same as Linux
# Windows (native PowerShell): New-Item -ItemType Directory -Force -Path ".kiro\steering"
mkdir -p "$WORKSPACE_ROOT/.kiro/steering"

if [ "$IS_FRESH_INSTALL" = true ] || [ ! -f "$WORKSPACE_ROOT/.kiro/steering/project-config.md" ]; then
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
else
  info "Keeping existing .kiro/steering/project-config.md (upgrade mode)"
fi

# ══════════════════════════════════════════════════════════════════════════════
# CREATE FOLDER STRUCTURE + INSTALL FILES
# ══════════════════════════════════════════════════════════════════════════════

# Mac/Linux: mkdir -p works natively
# Windows (WSL): Same as Linux
# Windows (native PowerShell):
#   New-Item -ItemType Directory -Force -Path ".kiro\hooks"
#   New-Item -ItemType Directory -Force -Path ".kiro\aws-aidlc-rule-details\common"
#   ... etc.

# Folders
mkdir -p "$WORKSPACE_ROOT/.kiro/hooks"
mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/common"
mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/inception"
mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/construction"
mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/operations"
mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/extensions"
mkdir -p "$WORKSPACE_ROOT/aidlc-docs/inception/user-stories"
mkdir -p "$WORKSPACE_ROOT/aidlc-docs/construction/build-and-test"
mkdir -p "$WORKSPACE_ROOT/aidlc-docs/archive"
mkdir -p "$WORKSPACE_ROOT/aidlc-docs/cycles"
success "Created folder structure"

# ── Steering files ───────────────────────────────────────────────────────────
# Mac/Linux: cp works natively
# Windows (WSL): Same as Linux
# Windows (native PowerShell): Copy-Item -Path "source" -Destination "dest" -Force
if [ -n "$POWER_DIR" ] && [ -d "$POWER_DIR/steering" ]; then
  for f in "$POWER_DIR/steering/"*.md; do
    [ -f "$f" ] || continue
    fname="$(basename "$f")"
    [ "$fname" = "project-config-template.md" ] && continue

    target="$WORKSPACE_ROOT/.kiro/steering/$fname"

    # On upgrade: never silently overwrite existing steering files
    if [ "$IS_UPGRADE" = true ] && [ -f "$target" ]; then
      # Compare content — only update if different
      if ! diff -q "$f" "$target" &>/dev/null; then
        cp "$target" "${target}.bak"
        cp "$f" "$target"
        info "Updated $fname (backup: ${fname}.bak)"
      fi
    else
      cp "$f" "$target" 2>/dev/null
    fi
  done
  success "Installed steering files"
fi

# ── Workflow rule-details ────────────────────────────────────────────────────
if [ -n "$POWER_DIR" ] && [ -d "$POWER_DIR/workflows" ]; then
  cp "$POWER_DIR/workflows/common/"*.md "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/common/" 2>/dev/null
  cp "$POWER_DIR/workflows/inception/"*.md "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/inception/" 2>/dev/null
  cp "$POWER_DIR/workflows/construction/"*.md "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/construction/" 2>/dev/null
  cp "$POWER_DIR/workflows/operations/"*.md "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/operations/" 2>/dev/null
  [ -d "$POWER_DIR/workflows/extensions" ] && cp -R "$POWER_DIR/workflows/extensions/"* "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/extensions/" 2>/dev/null
  success "Installed workflow rules"
fi

# ── Hooks ────────────────────────────────────────────────────────────────────
if [ -n "$POWER_DIR" ] && [ -d "$POWER_DIR/hooks" ]; then
  for f in "$POWER_DIR/hooks/"*.json; do
    [ -f "$f" ] || continue
    fname="$(basename "$f")"
    target="$WORKSPACE_ROOT/.kiro/hooks/$fname"

    # On upgrade: don't overwrite user-customized hooks
    if [ "$IS_UPGRADE" = true ] && [ -f "$target" ]; then
      if ! diff -q "$f" "$target" &>/dev/null; then
        cp "$target" "${target}.bak"
        cp "$f" "$target"
        info "Updated hook $fname (backup: ${fname}.bak)"
      fi
    else
      cp "$f" "$target" 2>/dev/null
    fi
  done
  success "Installed hooks"
fi

# ── AIDLC state ─────────────────────────────────────────────────────────────
if [ ! -f "$WORKSPACE_ROOT/aidlc-docs/aidlc-state.md" ]; then
  cat > "$WORKSPACE_ROOT/aidlc-docs/aidlc-state.md" << STATEEOF
# AIDLC State
- **Phase**: Not Started
- **Stage**: N/A
- **AIDLC Version**: ${AIDLC_POWER_VERSION}
STATEEOF
fi

# ── Audit log ────────────────────────────────────────────────────────────────
if [ ! -f "$WORKSPACE_ROOT/aidlc-docs/audit.md" ]; then
  echo "# AIDLC Audit Log" > "$WORKSPACE_ROOT/aidlc-docs/audit.md"
fi

# ── Write version file ───────────────────────────────────────────────────────
echo "$AIDLC_POWER_VERSION" > "$WORKSPACE_ROOT/.aidlc-version"
success "Version recorded: v${AIDLC_POWER_VERSION}"

# ── Update aidlc-state.md with version (on upgrade) ─────────────────────────
if [ "$IS_UPGRADE" = true ]; then
  # Mac/Linux (macOS sed -i requires ''):
  sed -i '' "s/AIDLC Version: .*/AIDLC Version: ${AIDLC_POWER_VERSION}/" "$WORKSPACE_ROOT/aidlc-docs/aidlc-state.md" 2>/dev/null || \
  # Linux sed -i without '':
  sed -i "s/AIDLC Version: .*/AIDLC Version: ${AIDLC_POWER_VERSION}/" "$WORKSPACE_ROOT/aidlc-docs/aidlc-state.md" 2>/dev/null || true
  # Windows (WSL): Linux sed works
  # Windows (native PowerShell):
  #   (Get-Content "aidlc-docs\aidlc-state.md") -replace "AIDLC Version: .*", "AIDLC Version: $version" | Set-Content "aidlc-docs\aidlc-state.md"
fi

# ══════════════════════════════════════════════════════════════════════════════
# GPG SIGNING CHECK
# ══════════════════════════════════════════════════════════════════════════════

# Mac/Linux: gpg comes with most distros; brew install gnupg on macOS
# Windows (WSL): sudo apt install gnupg
# Windows (native): winget install GnuPG.GnuPG  OR  choco install gpg4win
echo ""
signing_key=$(git config --get user.signingkey 2>/dev/null || echo "")
gpg_sign=$(git config --get commit.gpgsign 2>/dev/null || echo "")

if [ -z "$signing_key" ] || [ "$gpg_sign" != "true" ]; then
  warn "GPG commit signing is not configured."
  echo -e "  ${DIM}AIDLC requires signed commits. Run these commands:${NC}"
  echo ""
  echo -e "  ${CYAN}gpg --full-generate-key${NC}"
  echo -e "  ${CYAN}gpg --list-secret-keys --keyid-format=long${NC}"
  echo -e "  ${CYAN}git config --global user.signingkey <YOUR_KEY_ID>${NC}"
  echo -e "  ${CYAN}git config --global commit.gpgsign true${NC}"
  echo ""
  echo -e "  ${DIM}SSH signing is also supported — set gpg.format=ssh and point user.signingkey to your key.${NC}"
  echo ""
else
  success "GPG signing configured (key: ${signing_key:0:8}...)"
fi

# ══════════════════════════════════════════════════════════════════════════════
# DONE
# ══════════════════════════════════════════════════════════════════════════════

echo ""
if [ "$IS_UPGRADE" = true ]; then
  echo -e "${BOLD}${GREEN}Upgrade complete!${NC} v${INSTALLED_VERSION} → v${AIDLC_POWER_VERSION}"
else
  echo -e "${BOLD}${GREEN}Done!${NC} AIDLC configured for ${CYAN}${GITHUB_ORG}/${GITHUB_REPO}${NC} (${PROVIDER})"
fi
echo ""
echo -e "  ${DIM}To start:${NC} ${GREEN}\"Using AI-DLC, build me ...\"${NC}"
echo -e "  ${DIM}To customize:${NC} edit ${CYAN}.kiro/steering/project-config.md${NC}"
echo ""

# ── Post-setup hints for incomplete config ───────────────────────────────────
HINTS=""
if [ -z "$BOARD_NUMBER" ] || [ "$BOARD_NUMBER" = "none" ]; then
  HINTS+="  ${YELLOW}→${NC} No project board detected. To enable issue sync, update:\n"
  HINTS+="    ${CYAN}Board ID${NC} in .kiro/steering/project-config.md\n"
fi
if [ -z "$TEAM_LEAD" ]; then
  HINTS+="  ${YELLOW}→${NC} No team lead detected. Update ${CYAN}Team → Lead${NC} in project-config.md\n"
fi
if [ -z "$FRAMEWORK" ]; then
  HINTS+="  ${YELLOW}→${NC} No framework detected. Add ${CYAN}Framework${NC} in project-config.md if applicable\n"
fi

if [ -n "$HINTS" ]; then
  echo -e "${BOLD}📝 Action needed:${NC} Update your config to enable full features:"
  echo -e "$HINTS"
  echo -e "  ${DIM}After updating, say \"Sync stories.md to board\" in Kiro anytime.${NC}"
  echo ""
fi
