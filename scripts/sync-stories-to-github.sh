#!/usr/bin/env bash
# sync-stories-to-github.sh
# Creates GitHub issues from AIDLC user stories using gh CLI.
# Usage: ./scripts/sync-stories-to-github.sh [--repo ORG/REPO] [--project NUMBER] [--assignee USER]
#
# Prerequisites:
#   - gh CLI installed and authenticated (gh auth login)
#   - Repository access with issue write permissions
#
# This script reads stories from aidlc-docs/inception/user-stories/stories.md
# and creates GitHub issues with the label 'aidlc:story'.

set -euo pipefail

# --- Configuration (override via flags or environment) ---
REPO="${AIDLC_GITHUB_REPO:-}"
PROJECT_NUMBER="${AIDLC_PROJECT_BOARD:-}"
ASSIGNEE="${AIDLC_TEAM_LEAD:-}"
STORIES_FILE="aidlc-docs/inception/user-stories/stories.md"
DRY_RUN=false

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
  case $1 in
    --repo) REPO="$2"; shift 2 ;;
    --project) PROJECT_NUMBER="$2"; shift 2 ;;
    --assignee) ASSIGNEE="$2"; shift 2 ;;
    --stories-file) STORIES_FILE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help)
      echo "Usage: $0 [--repo ORG/REPO] [--project NUMBER] [--assignee USER] [--stories-file PATH] [--dry-run]"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# --- Validation ---
if ! command -v gh &> /dev/null; then
  echo "❌ Error: gh CLI is not installed. Install from https://cli.github.com/"
  exit 1
fi

if ! gh auth status &> /dev/null 2>&1; then
  echo "❌ Error: gh CLI is not authenticated. Run: gh auth login"
  exit 1
fi

if [[ -z "$REPO" ]]; then
  echo "❌ Error: --repo ORG/REPO is required (or set AIDLC_GITHUB_REPO env var)"
  exit 1
fi

if [[ ! -f "$STORIES_FILE" ]]; then
  echo "❌ Error: Stories file not found: $STORIES_FILE"
  exit 1
fi

# --- Extract org from repo for project commands ---
ORG="${REPO%%/*}"

# --- Ensure label exists ---
if ! gh label list --repo "$REPO" --search "aidlc:story" --json name | grep -q "aidlc:story"; then
  echo "📌 Creating label 'aidlc:story'..."
  gh label create "aidlc:story" --repo "$REPO" --description "AIDLC User Story" --color "0e8a16" 2>/dev/null || true
fi

# --- Parse stories and create issues ---
CREATED=0
SKIPPED=0

echo "📖 Reading stories from: $STORIES_FILE"
echo "📦 Target repo: $REPO"
echo ""

# Simple parser: looks for story headers like "### S1: Story Title" or "### Story 1: Title"
while IFS= read -r line; do
  # Match story headers (e.g., "### S1: Login Feature" or "### Story S1: Login Feature")
  if [[ "$line" =~ ^###[[:space:]]+(S[0-9]+|Story[[:space:]]+[0-9]+):?[[:space:]]+(.*) ]]; then
    STORY_ID="${BASH_REMATCH[1]}"
    STORY_TITLE="${BASH_REMATCH[2]}"
    
    # Check for duplicates
    EXISTING=$(gh issue list --repo "$REPO" --label "aidlc:story" --search "[AIDLC Story $STORY_ID]" --json number --jq 'length' 2>/dev/null || echo "0")
    
    if [[ "$EXISTING" -gt 0 ]]; then
      echo "⏭️  Skipping $STORY_ID (already exists)"
      ((SKIPPED++))
      continue
    fi

    FULL_TITLE="[AIDLC Story $STORY_ID] $STORY_TITLE"
    
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "🔍 [DRY RUN] Would create: $FULL_TITLE"
      ((CREATED++))
      continue
    fi

    # Create the issue
    ISSUE_URL=$(gh issue create --repo "$REPO" \
      --title "$FULL_TITLE" \
      --body "## User Story

Generated from AIDLC inception phase.

**Story ID**: $STORY_ID

---
*Created by Kiro AIDLC — sync-stories-to-github.sh*" \
      --label "aidlc:story" \
      ${ASSIGNEE:+--assignee "$ASSIGNEE"} \
      2>/dev/null) || {
        echo "⚠️  Failed to create issue for $STORY_ID"
        continue
      }

    echo "✅ Created: $FULL_TITLE → $ISSUE_URL"

    # Add to project board if configured
    if [[ -n "$PROJECT_NUMBER" ]]; then
      gh project item-add "$PROJECT_NUMBER" --owner "$ORG" --url "$ISSUE_URL" 2>/dev/null || {
        echo "   ⚠️  Failed to add to project board (non-blocking)"
      }
    fi

    ((CREATED++))
  fi
done < "$STORIES_FILE"

echo ""
echo "📊 Summary: Created $CREATED issues, Skipped $SKIPPED duplicates"
