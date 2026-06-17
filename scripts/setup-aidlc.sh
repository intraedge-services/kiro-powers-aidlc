#!/bin/bash
# ══════════════════════════════════════════════════════════════════════════════
# AIDLC Bootstrap / Setup Utility
# ══════════════════════════════════════════════════════════════════════════════
#
# Single-command setup for AI-Driven Development Lifecycle in any project.
#
# What it does:
#   1. Detects if AIDLC is already configured
#   2. If not: runs interactive setup (project identity, team, powers)
#   3. Generates project-config.md from your answers
#   4. Creates complete folder structure (.kiro/, aidlc-docs/)
#   5. Installs steering files, hooks, and workflow rule-details
#   6. Prints verification summary
#
# Usage:
#   From your project root:
#     curl -sL <raw-url>/scripts/setup-aidlc.sh | bash
#   Or if power is cloned locally:
#     path/to/kiro-powers-aidlc/scripts/setup-aidlc.sh
#
# ══════════════════════════════════════════════════════════════════════════════

# Note: We intentionally don't use 'set -e' because the script relies on
# [ condition ] && action patterns which return non-zero when condition is false.
# Error handling is done explicitly where needed.

# ── Colors & Formatting ─────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# ── Helper Functions ─────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}ℹ${NC}  $1"; }
success() { echo -e "${GREEN}✓${NC}  $1"; }
warn()    { echo -e "${YELLOW}⚠${NC}  $1"; }
error()   { echo -e "${RED}✗${NC}  $1"; }
header()  { echo -e "\n${BOLD}${CYAN}$1${NC}"; echo -e "${DIM}$(printf '─%.0s' $(seq 1 60))${NC}"; }

prompt_input() {
    local prompt_text="$1"
    local default_val="$2"
    local result=""
    if [ -n "$default_val" ]; then
        echo -ne "${BOLD}$prompt_text${NC} ${DIM}[$default_val]${NC}: " >&2
    else
        echo -ne "${BOLD}$prompt_text${NC}: " >&2
    fi
    read -r result
    echo "${result:-$default_val}"
}

prompt_yes_no() {
    local prompt_text="$1"
    local default_val="${2:-yes}"
    local result=""
    if [ "$default_val" = "yes" ]; then
        echo -ne "${BOLD}$prompt_text${NC} ${DIM}[Y/n]${NC}: " >&2
    else
        echo -ne "${BOLD}$prompt_text${NC} ${DIM}[y/N]${NC}: " >&2
    fi
    read -r result
    result="${result:-$default_val}"
    case "$result" in
        [Yy]*) echo "yes" ;;
        [Nn]*) echo "no" ;;
        *) echo "$default_val" ;;
    esac
}

prompt_choice() {
    local prompt_text="$1"
    shift
    local options=("$@")
    echo -e "\n${BOLD}$prompt_text${NC}" >&2
    for i in "${!options[@]}"; do
        echo -e "  ${CYAN}$((i+1)))${NC} ${options[$i]}" >&2
    done
    echo -ne "${BOLD}Choice${NC} ${DIM}[1-${#options[@]}]${NC}: " >&2
    read -r choice
    choice="${choice:-1}"
    echo "${options[$((choice-1))]}"
}

# ── Resolve Power Directory ──────────────────────────────────────────────────
resolve_power_dir() {
    # First: try BASH_SOURCE (works when script is invoked directly or via path)
    if [ -n "${BASH_SOURCE[0]}" ] && [ "${BASH_SOURCE[0]}" != "bash" ]; then
        local script_path="${BASH_SOURCE[0]}"
        # Resolve symlinks
        while [ -L "$script_path" ]; do
            script_path="$(readlink "$script_path")"
        done
        SCRIPT_DIR="$(cd "$(dirname "$script_path")" && pwd)"
        local candidate="$(dirname "$SCRIPT_DIR")"
        # Verify it's actually the power directory (has workflows/ and POWER.md)
        if [ -d "$candidate/workflows" ] && [ -f "$candidate/POWER.md" ]; then
            POWER_DIR="$candidate"
            return
        fi
    fi

    # Fallback: try common locations relative to workspace
    if [ -d ".kiro/powers/kiro-powers-aidlc" ]; then
        POWER_DIR="$(cd ".kiro/powers/kiro-powers-aidlc" && pwd)"
    elif [ -d "../kiro-powers-aidlc" ]; then
        POWER_DIR="$(cd "../kiro-powers-aidlc" && pwd)"
    else
        POWER_DIR=""
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 1: DETECTION
# ══════════════════════════════════════════════════════════════════════════════

detect_existing_aidlc() {
    header "🔍 Phase 1: Detection"

    WORKSPACE_ROOT="$(pwd)"
    ALREADY_CONFIGURED=false
    PARTIAL_CONFIG=false

    local checks_passed=0
    local checks_total=5

    # Check 1: project-config.md exists and has non-placeholder values
    if [ -f "$WORKSPACE_ROOT/.kiro/steering/project-config.md" ]; then
        if grep -q "{Project Name}\|{org-name}\|{repo-name}" "$WORKSPACE_ROOT/.kiro/steering/project-config.md" 2>/dev/null; then
            warn "project-config.md exists but has placeholder values"
            PARTIAL_CONFIG=true
        else
            success "project-config.md configured"
            checks_passed=$((checks_passed + 1))
        fi
    else
        info "No project-config.md found"
    fi

    # Check 2: aidlc-docs/ directory exists
    if [ -d "$WORKSPACE_ROOT/aidlc-docs" ]; then
        success "aidlc-docs/ directory exists"
        checks_passed=$((checks_passed + 1))
    else
        info "No aidlc-docs/ directory"
    fi

    # Check 3: Workflow rule-details exist
    if [ -d "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details" ]; then
        success "Workflow rule-details installed"
        checks_passed=$((checks_passed + 1))
    else
        info "No workflow rule-details"
    fi

    # Check 4: Steering files exist (core-workflow)
    if [ -f "$WORKSPACE_ROOT/.kiro/steering/aws-aidlc-rules/core-workflow.md" ] || \
       [ -f "$WORKSPACE_ROOT/.kiro/steering/core-workflow.md" ]; then
        success "Core workflow steering installed"
        checks_passed=$((checks_passed + 1))
    else
        info "No core workflow steering"
    fi

    # Check 5: Hooks installed
    if [ -d "$WORKSPACE_ROOT/.kiro/hooks" ] && [ "$(ls -A "$WORKSPACE_ROOT/.kiro/hooks/" 2>/dev/null)" ]; then
        success "Hooks installed"
        checks_passed=$((checks_passed + 1))
    else
        info "No hooks installed"
    fi

    echo ""
    if [ "$checks_passed" -eq "$checks_total" ]; then
        ALREADY_CONFIGURED=true
        success "AIDLC is fully configured ($checks_passed/$checks_total checks passed)"
    elif [ "$checks_passed" -gt 0 ]; then
        PARTIAL_CONFIG=true
        warn "AIDLC is partially configured ($checks_passed/$checks_total checks passed)"
    else
        info "AIDLC is not configured — starting fresh setup"
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 2: INTERACTIVE SETUP
# ══════════════════════════════════════════════════════════════════════════════

collect_project_identity() {
    header "📋 Phase 2: Project Configuration"
    echo -e "${DIM}Let's configure your project. Press Enter to accept defaults.${NC}\n"

    # Project Name - try to infer from directory name
    local dir_name
    dir_name="$(basename "$WORKSPACE_ROOT")"
    PROJECT_NAME=$(prompt_input "Project name" "$dir_name")

    # GitHub Org - extract from git remote URL
    local git_org=""
    if [ -f ".git/config" ]; then
        local remote_url
        remote_url=$(git remote get-url origin 2>/dev/null || echo "")
        if [ -n "$remote_url" ]; then
            # Handle both SSH (git@github.com:org/repo.git) and HTTPS (https://github.com/org/repo.git)
            git_org=$(echo "$remote_url" | sed -E 's|.*github\.com[:/]([^/]+)/.*|\1|')
        fi
    fi
    GITHUB_ORG=$(prompt_input "GitHub organization" "$git_org")

    # GitHub Repo
    local git_repo=""
    if [ -f ".git/config" ]; then
        local remote_url
        remote_url=$(git remote get-url origin 2>/dev/null || echo "")
        if [ -n "$remote_url" ]; then
            git_repo=$(echo "$remote_url" | sed -E 's|.*github\.com[:/][^/]+/([^.]+)(\.git)?$|\1|')
        fi
    fi
    GITHUB_REPO=$(prompt_input "GitHub repository" "${git_repo:-$dir_name}")

    # Project Board Number
    BOARD_NUMBER=$(prompt_input "GitHub Project board number (or 'none')" "none")

    # Default Branch
    local default_branch="main"
    if [ -f ".git/HEAD" ]; then
        local head_ref
        head_ref=$(cat .git/HEAD 2>/dev/null)
        if [[ "$head_ref" == ref:* ]]; then
            default_branch=$(echo "$head_ref" | sed 's|ref: refs/heads/||')
        fi
    fi
    DEFAULT_BRANCH=$(prompt_input "Default branch" "$default_branch")
}

collect_team_info() {
    header "👥 Team"
    echo -e "${DIM}Provide GitHub usernames (comma-separated for multiple).${NC}\n"

    TEAM_LEAD=$(prompt_input "Team lead (GitHub username)" "")
    DEVELOPERS=$(prompt_input "Developers (comma-separated)" "")
    REVIEWERS=$(prompt_input "Reviewers (comma-separated)" "${TEAM_LEAD}")
}

collect_tech_stack() {
    header "🛠️  Tech Stack"

    LANGUAGE=$(prompt_input "Primary language" "Python")
    FRAMEWORK=$(prompt_input "Framework(s)" "AWS CDK")
    RUNTIME=$(prompt_input "Runtime/compute" "AWS Glue 4.0, Step Functions")
    STORAGE=$(prompt_input "Storage" "S3")
    DATABASE=$(prompt_input "Database/catalog" "Glue Catalog, Athena")
    MONITORING=$(prompt_input "Monitoring" "CloudWatch")
}

collect_aidlc_preferences() {
    header "⚙️  AIDLC Preferences"

    DEPTH=$(prompt_choice "Default workflow depth:" "minimal" "standard" "comprehensive")
    AUTO_ISSUES=$(prompt_yes_no "Auto-create GitHub issues from user stories?" "yes")
    AUTO_BOARD_SYNC=$(prompt_yes_no "Auto-sync board status on stage transitions?" "yes")
    GENERATE_DIAGRAMS=$(prompt_yes_no "Generate diagrams during workflow?" "yes")
}

collect_powers_selection() {
    header "🔌 Powers Selection"
    echo -e "${DIM}Select which powers to enable. You can change these later in project-config.md${NC}\n"

    POWER_GITHUB=$(prompt_yes_no "Enable GitHub integration (issues, board sync)?" "yes")
    POWER_DATA_ENG=$(prompt_yes_no "Enable AWS Data Engineering (Glue, EMR, Athena)?" "no")
    POWER_INFRA=$(prompt_yes_no "Enable Infrastructure as Code (CDK/Terraform)?" "yes")

    if [ "$POWER_INFRA" = "yes" ]; then
        INFRA_POWER=$(prompt_choice "Infrastructure power:" "kiro-powers-aws-cdk-python" "terraform" "aws-infrastructure-as-code")
    fi

    POWER_DIAGRAMS=$(prompt_yes_no "Enable Diagrams generation?" "yes")
    POWER_CICD=$(prompt_yes_no "Enable CI/CD integration?" "no")

    if [ "$POWER_CICD" = "yes" ]; then
        CICD_POWER=$(prompt_choice "CI/CD power:" "kiro-powers-circleci" "github-actions")
    fi
}

collect_extensions_selection() {
    header "🧩 Extensions"
    echo -e "${DIM}Extensions add blocking quality rules during the AIDLC workflow.${NC}\n"

    EXT_SECURITY=$(prompt_yes_no "Enable Security Baseline (OWASP-aligned)?" "yes")
    EXT_TESTING=$(prompt_yes_no "Enable Property-Based Testing?" "no")
    EXT_RESILIENCY=$(prompt_yes_no "Enable Resiliency Baseline (AWS Well-Architected)?" "no")
}

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 3: GENERATION
# ══════════════════════════════════════════════════════════════════════════════

generate_project_config() {
    header "📝 Generating project-config.md"

    # Build powers registry table rows
    local powers_rows=""
    if [ "$POWER_GITHUB" = "yes" ]; then
        powers_rows+="| project-management | kiro-powers-github | After user stories, board sync on stage transitions |\n"
    fi
    if [ "$POWER_DATA_ENG" = "yes" ]; then
        powers_rows+="| data-engineering | kiro-powers-aws-data-engineering | Code gen for Glue jobs, Athena queries, EMR clusters |\n"
    fi
    if [ "$POWER_INFRA" = "yes" ]; then
        powers_rows+="| infrastructure | ${INFRA_POWER} | Infrastructure design, code generation, template validation |\n"
    fi
    if [ "$POWER_DIAGRAMS" = "yes" ]; then
        powers_rows+="| diagrams | kiro-powers-diagrams | Architecture docs, pipeline flow diagrams |\n"
    fi
    if [ "$POWER_CICD" = "yes" ]; then
        powers_rows+="| ci-cd | ${CICD_POWER} | Build & test validation, pipeline templates |\n"
    fi

    # Build extensions table rows
    local ext_security_val="no"
    local ext_testing_val="no"
    local ext_resiliency_val="no"
    [ "$EXT_SECURITY" = "yes" ] && ext_security_val="yes"
    [ "$EXT_TESTING" = "yes" ] && ext_testing_val="yes"
    [ "$EXT_RESILIENCY" = "yes" ] && ext_resiliency_val="yes"

    # Board number display
    local board_display="$BOARD_NUMBER"
    [ "$BOARD_NUMBER" = "none" ] && board_display="N/A"

    mkdir -p "$WORKSPACE_ROOT/.kiro/steering"

    cat > "$WORKSPACE_ROOT/.kiro/steering/project-config.md" << CONFIGEOF
---
inclusion: always
---
# Project Configuration — ${PROJECT_NAME}

## Project Identity

- **Name**: ${PROJECT_NAME}
- **GitHub Org**: ${GITHUB_ORG}
- **GitHub Repo**: ${GITHUB_REPO}
- **Project Board Number**: ${board_display}
- **Default Branch**: ${DEFAULT_BRANCH}

## Team

- **Lead**: ${TEAM_LEAD}
- **Developers**: ${DEVELOPERS}
- **Reviewers**: ${REVIEWERS}

## Tech Stack

- **Language**: ${LANGUAGE}
- **Framework**: ${FRAMEWORK}
- **Runtime**: ${RUNTIME}
- **Storage**: ${STORAGE}
- **Database**: ${DATABASE}
- **Monitoring**: ${MONITORING}

## AIDLC Preferences

- **Default Depth**: ${DEPTH}
- **Auto-create Issues**: ${AUTO_ISSUES}
- **Auto-sync Board**: ${AUTO_BOARD_SYNC}
- **Generate Diagrams**: ${GENERATE_DIAGRAMS}

## Installed Powers Registry

| Category | Power Name | Activate During |
|----------|-----------|-----------------|
$(echo -e "$powers_rows")
## Extensions

| Extension | Enabled | Notes |
|-----------|---------|-------|
| security-baseline | ${ext_security_val} | OWASP-aligned security rules |
| property-based-testing | ${ext_testing_val} | Property-based testing with Hypothesis/fast-check |
| resiliency-baseline | ${ext_resiliency_val} | AWS Well-Architected Reliability Pillar |

## Power Activation Clarifications

- **data-engineering**: Only activates for AWS data services (Glue, EMR, Athena, Spark). NOT for general Python/ML code.
- **infrastructure**: Activates for ANY IaC code — CDK, Terraform, CloudFormation. Must activate BEFORE designing.
- **ci-cd**: Activates for new service pipelines or during Build & Test to validate CI configs.
- **diagrams**: Activates at multiple stages for visual documentation.
CONFIGEOF

    success "Generated .kiro/steering/project-config.md"
}

create_folder_structure() {
    header "📁 Creating Folder Structure"

    # .kiro directories
    mkdir -p "$WORKSPACE_ROOT/.kiro/steering/aws-aidlc-rules"
    mkdir -p "$WORKSPACE_ROOT/.kiro/hooks"
    mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/common"
    mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/inception"
    mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/construction"
    mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/operations"
    mkdir -p "$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details/extensions"

    # aidlc-docs directories
    mkdir -p "$WORKSPACE_ROOT/aidlc-docs/inception/plans"
    mkdir -p "$WORKSPACE_ROOT/aidlc-docs/inception/reverse-engineering"
    mkdir -p "$WORKSPACE_ROOT/aidlc-docs/inception/requirements"
    mkdir -p "$WORKSPACE_ROOT/aidlc-docs/inception/user-stories"
    mkdir -p "$WORKSPACE_ROOT/aidlc-docs/inception/application-design"
    mkdir -p "$WORKSPACE_ROOT/aidlc-docs/construction/plans"
    mkdir -p "$WORKSPACE_ROOT/aidlc-docs/construction/build-and-test"
    mkdir -p "$WORKSPACE_ROOT/aidlc-docs/operations"

    success "Created .kiro/ directory structure"
    success "Created aidlc-docs/ directory structure"
}

install_steering_files() {
    header "📄 Installing Steering Files"

    # Core workflow steering (goes into aws-aidlc-rules subdirectory)
    if [ -n "$POWER_DIR" ] && [ -f "$POWER_DIR/steering/core-workflow.md" ]; then
        cp "$POWER_DIR/steering/core-workflow.md" \
           "$WORKSPACE_ROOT/.kiro/steering/aws-aidlc-rules/core-workflow.md"
        success "Installed core-workflow.md"
    else
        # Generate minimal core-workflow reference
        cat > "$WORKSPACE_ROOT/.kiro/steering/aws-aidlc-rules/core-workflow.md" << 'CWEOF'
# PRIORITY: This workflow OVERRIDES all other built-in workflows
# When user requests software development, ALWAYS follow this workflow FIRST

## MANDATORY: Rule Details Loading
**CRITICAL**: When performing any phase, you MUST read and use relevant content from rule detail files.
Check this path: `.kiro/aws-aidlc-rule-details/`

**Common Rules**: ALWAYS load common rules at workflow start:
- Load `common/process-overview.md` for workflow overview
- Load `common/session-continuity.md` for session resumption guidance
- Load `common/content-validation.md` for content validation requirements
- Load `common/question-format-guide.md` for question formatting rules

## MANDATORY: Custom Welcome Message
Load the welcome message from `.kiro/aws-aidlc-rule-details/common/welcome-message.md`

## MANDATORY: Extensions Loading
Scan `.kiro/aws-aidlc-rule-details/extensions/` for `*.opt-in.md` files at workflow start.

For complete workflow details, see the rule-details files.
CWEOF
        success "Generated core-workflow.md (standalone mode)"
    fi

    # Additional steering files from power (if available)
    if [ -n "$POWER_DIR" ] && [ -d "$POWER_DIR/steering" ]; then
        for steering_file in "$POWER_DIR/steering/"*.md; do
            [ -f "$steering_file" ] || continue
            local fname
            fname="$(basename "$steering_file")"
            # Skip template docs and core-workflow (already handled)
            [ "$fname" = "project-config-template.md" ] && continue
            [ "$fname" = "core-workflow.md" ] && continue

            local target="$WORKSPACE_ROOT/.kiro/steering/$fname"
            if [ ! -f "$target" ]; then
                cp "$steering_file" "$target"
                success "Installed steering: $fname"
            else
                info "Steering already exists: $fname (skipped)"
            fi
        done
    fi
}

install_workflow_rules() {
    header "📚 Installing Workflow Rule-Details"

    local target_dir="$WORKSPACE_ROOT/.kiro/aws-aidlc-rule-details"

    if [ -n "$POWER_DIR" ] && [ -d "$POWER_DIR/workflows" ]; then
        # Copy from power's workflows/ into rule-details
        local count=0

        # Common
        for f in "$POWER_DIR/workflows/common/"*.md; do
            [ -f "$f" ] || continue
            cp "$f" "$target_dir/common/"
            count=$((count + 1))
        done

        # Inception
        for f in "$POWER_DIR/workflows/inception/"*.md; do
            [ -f "$f" ] || continue
            cp "$f" "$target_dir/inception/"
            count=$((count + 1))
        done

        # Construction
        for f in "$POWER_DIR/workflows/construction/"*.md; do
            [ -f "$f" ] || continue
            cp "$f" "$target_dir/construction/"
            count=$((count + 1))
        done

        # Operations
        for f in "$POWER_DIR/workflows/operations/"*.md; do
            [ -f "$f" ] || continue
            cp "$f" "$target_dir/operations/"
            count=$((count + 1))
        done

        # Extensions (recursive copy)
        if [ -d "$POWER_DIR/workflows/extensions" ]; then
            cp -R "$POWER_DIR/workflows/extensions/"* "$target_dir/extensions/" 2>/dev/null || true
            count=$((count + 1))
        fi

        success "Installed $count workflow files into .kiro/aws-aidlc-rule-details/"
    else
        warn "Power directory not found — workflow files not installed"
        warn "You can manually copy workflow files later from the kiro-powers-aidlc repo"
    fi
}

install_hooks() {
    header "🪝 Installing Hooks"

    if [ -n "$POWER_DIR" ] && [ -d "$POWER_DIR/hooks" ]; then
        local count=0
        for hook in "$POWER_DIR/hooks/"*.json; do
            [ -f "$hook" ] || continue
            local fname
            fname="$(basename "$hook")"
            if [ ! -f "$WORKSPACE_ROOT/.kiro/hooks/$fname" ]; then
                cp "$hook" "$WORKSPACE_ROOT/.kiro/hooks/$fname"
                success "Installed hook: $fname"
                count=$((count + 1))
            else
                info "Hook already exists: $fname (skipped)"
            fi
        done
        if [ "$count" -eq 0 ]; then
            info "All hooks already installed"
        fi
    else
        warn "Power directory not found — hooks not installed"
        warn "You can manually copy hooks later from the kiro-powers-aidlc repo"
    fi
}

create_aidlc_state() {
    header "📊 Initializing AIDLC State"

    if [ ! -f "$WORKSPACE_ROOT/aidlc-docs/aidlc-state.md" ]; then
        cat > "$WORKSPACE_ROOT/aidlc-docs/aidlc-state.md" << 'STATEEOF'
# AIDLC State

## Current Status
- **Phase**: Not Started
- **Stage**: N/A
- **Last Updated**: N/A

## Inception Phase Progress
- [ ] Workspace Detection
- [ ] Reverse Engineering
- [ ] Requirements Analysis
- [ ] User Stories
- [ ] Workflow Planning
- [ ] Application Design
- [ ] Units Generation

## Construction Phase Progress
- [ ] Functional Design
- [ ] NFR Requirements
- [ ] NFR Design
- [ ] Infrastructure Design
- [ ] Code Generation
- [ ] Build and Test

## Extension Configuration
| Extension | Enabled | Opted-In During |
|-----------|---------|-----------------|
| security-baseline | pending | — |
| property-based-testing | pending | — |
| resiliency-baseline | pending | — |
STATEEOF
        success "Created aidlc-docs/aidlc-state.md"
    else
        info "aidlc-state.md already exists (skipped)"
    fi

    # Create audit.md
    if [ ! -f "$WORKSPACE_ROOT/aidlc-docs/audit.md" ]; then
        cat > "$WORKSPACE_ROOT/aidlc-docs/audit.md" << AUDITEOF
# AIDLC Audit Log

## Setup
**Timestamp**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
**Action**: AIDLC Bootstrap / Setup Utility executed
**Context**: Project "${PROJECT_NAME}" initialized with AIDLC workflow

---
AUDITEOF
        success "Created aidlc-docs/audit.md"
    else
        info "audit.md already exists (skipped)"
    fi
}

update_gitignore() {
    # Ensure .gitignore doesn't exclude aidlc-docs or .kiro
    if [ -f "$WORKSPACE_ROOT/.gitignore" ]; then
        if grep -q "^\.kiro/$" "$WORKSPACE_ROOT/.gitignore" 2>/dev/null; then
            warn ".gitignore excludes .kiro/ — AIDLC files won't be tracked!"
            warn "Consider removing '.kiro/' from .gitignore"
        fi
    fi
}

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 4: VERIFICATION & SUMMARY
# ══════════════════════════════════════════════════════════════════════════════

print_summary() {
    header "✅ Setup Complete!"

    echo ""
    echo -e "${BOLD}Project:${NC} ${PROJECT_NAME}"
    echo -e "${BOLD}Repo:${NC}    ${GITHUB_ORG}/${GITHUB_REPO}"
    echo -e "${BOLD}Branch:${NC}  ${DEFAULT_BRANCH}"
    echo ""

    echo -e "${BOLD}Installed Components:${NC}"
    echo -e "  ${GREEN}✓${NC} .kiro/steering/project-config.md (configured)"
    echo -e "  ${GREEN}✓${NC} .kiro/steering/aws-aidlc-rules/core-workflow.md"
    echo -e "  ${GREEN}✓${NC} .kiro/aws-aidlc-rule-details/ (workflow files)"
    echo -e "  ${GREEN}✓${NC} .kiro/hooks/ (board sync, power orchestration)"
    echo -e "  ${GREEN}✓${NC} aidlc-docs/ (state tracking, audit log)"
    echo ""

    echo -e "${BOLD}Enabled Powers:${NC}"
    [ "$POWER_GITHUB" = "yes" ] && echo -e "  ${CYAN}●${NC} kiro-powers-github (project management)"
    [ "$POWER_DATA_ENG" = "yes" ] && echo -e "  ${CYAN}●${NC} kiro-powers-aws-data-engineering"
    [ "$POWER_INFRA" = "yes" ] && echo -e "  ${CYAN}●${NC} ${INFRA_POWER} (infrastructure)"
    [ "$POWER_DIAGRAMS" = "yes" ] && echo -e "  ${CYAN}●${NC} kiro-powers-diagrams"
    [ "$POWER_CICD" = "yes" ] && echo -e "  ${CYAN}●${NC} ${CICD_POWER} (ci/cd)"
    echo ""

    echo -e "${BOLD}Extensions:${NC}"
    [ "$EXT_SECURITY" = "yes" ] && echo -e "  ${GREEN}●${NC} security-baseline (enabled)"
    [ "$EXT_TESTING" = "yes" ] && echo -e "  ${GREEN}●${NC} property-based-testing (enabled)"
    [ "$EXT_RESILIENCY" = "yes" ] && echo -e "  ${GREEN}●${NC} resiliency-baseline (enabled)"
    echo ""

    echo -e "${DIM}────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "${BOLD}Next Steps:${NC}"
    echo -e "  1. Review ${CYAN}.kiro/steering/project-config.md${NC} and adjust if needed"
    echo -e "  2. Ensure your powers are installed in Kiro (Powers panel)"
    echo -e "  3. Start using AIDLC:"
    echo -e "     ${GREEN}\"Using AI-DLC, build me ...\"${NC}"
    echo ""
    echo -e "  ${DIM}To re-run setup: path/to/kiro-powers-aidlc/scripts/setup-aidlc.sh${NC}"
    echo -e "${DIM}────────────────────────────────────────────────────────────────${NC}"
}

# ══════════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ══════════════════════════════════════════════════════════════════════════════

main() {
    echo ""
    echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${CYAN}   AIDLC Bootstrap / Setup Utility  v1.0.0${NC}"
    echo -e "${BOLD}${CYAN}   AI-Driven Development Lifecycle${NC}"
    echo -e "${BOLD}${CYAN}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${DIM}   Workspace: $(pwd)${NC}"
    echo ""

    # Resolve where the power lives
    resolve_power_dir

    if [ -z "$POWER_DIR" ]; then
        warn "Could not locate kiro-powers-aidlc directory"
        warn "Workflow files and hooks will need manual installation"
        echo ""
        echo -e "${DIM}Tip: Clone the power first:${NC}"
        echo -e "${DIM}  git clone https://github.com/intraedge-services/kiro-powers-aidlc.git /tmp/aidlc${NC}"
        echo -e "${DIM}  /tmp/aidlc/scripts/setup-aidlc.sh${NC}"
        echo ""
    fi

    # Phase 1: Detection
    detect_existing_aidlc

    # Handle already-configured case
    if [ "$ALREADY_CONFIGURED" = true ]; then
        echo ""
        local action
        action=$(prompt_choice "AIDLC is already configured. What would you like to do?" \
            "Exit (keep current config)" \
            "Re-run setup (overwrite project-config)" \
            "Repair (reinstall missing files only)")

        case "$action" in
            "Exit (keep current config)")
                info "Exiting. Your AIDLC configuration is intact."
                exit 0
                ;;
            "Re-run setup (overwrite project-config)")
                info "Starting fresh setup..."
                ;;
            "Repair (reinstall missing files only)")
                info "Running repair mode..."
                create_folder_structure
                install_steering_files
                install_workflow_rules
                install_hooks
                update_gitignore
                echo ""
                success "Repair complete! Missing files have been reinstalled."
                exit 0
                ;;
        esac
    fi

    # Handle partial config case
    if [ "$PARTIAL_CONFIG" = true ] && [ "$ALREADY_CONFIGURED" = false ]; then
        echo ""
        local action
        action=$(prompt_choice "Partial AIDLC config detected. What would you like to do?" \
            "Continue setup (fill in missing pieces)" \
            "Start fresh (overwrite everything)" \
            "Exit")

        case "$action" in
            "Exit")
                exit 0
                ;;
            "Start fresh (overwrite everything)")
                info "Starting fresh..."
                ;;
            "Continue setup (fill in missing pieces)")
                info "Continuing setup..."
                ;;
        esac
    fi

    # Phase 2: Interactive Setup
    collect_project_identity
    collect_team_info
    collect_tech_stack
    collect_aidlc_preferences
    collect_powers_selection
    collect_extensions_selection

    # Phase 3: Generation & Installation
    generate_project_config
    create_folder_structure
    install_steering_files
    install_workflow_rules
    install_hooks
    create_aidlc_state
    update_gitignore

    # Phase 4: Summary
    print_summary
}

# Run main
main "$@"
