#!/bin/bash
# ──────────────────────────────────────────────────────────────
# AIDLC Power — Legacy Workspace Initializer
# ──────────────────────────────────────────────────────────────
#
# ⚠️  DEPRECATED: Use setup-aidlc.sh instead for full interactive setup.
#     This script is kept for backward compatibility (non-interactive mode).
#
# Usage:
#   .kiro/powers/kiro-powers-aidlc/scripts/init-workspace.sh
#
# For the full interactive bootstrap experience, use:
#   .kiro/powers/kiro-powers-aidlc/scripts/setup-aidlc.sh
#
# ──────────────────────────────────────────────────────────────

set -e

# Determine power directory (relative to this script)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
POWER_DIR="$(dirname "$SCRIPT_DIR")"

# Determine workspace root (where the user runs this from)
WORKSPACE_ROOT="$(pwd)"

echo "🔧 AIDLC Power — Workspace Setup"
echo "   Power location: $POWER_DIR"
echo "   Workspace: $WORKSPACE_ROOT"
echo ""

# ── Step 1: Project Config ──────────────────────────────────
mkdir -p "$WORKSPACE_ROOT/.kiro/steering"

if [ -f "$WORKSPACE_ROOT/.kiro/steering/project-config.md" ]; then
    echo "✓ .kiro/steering/project-config.md already exists (skipped)"
else
    cp "$POWER_DIR/templates/project-config.md" "$WORKSPACE_ROOT/.kiro/steering/project-config.md"
    echo "✓ Created .kiro/steering/project-config.md"
fi

# ── Step 2: Steering Files ───────────────────────────────────
STEERING_COPIED=0
for steering_file in "$POWER_DIR/steering/"*.md; do
    [ -f "$steering_file" ] || continue
    STEERING_NAME="$(basename "$steering_file")"
    # Skip the template guide — it's documentation, not a runtime steering file
    [ "$STEERING_NAME" = "project-config-template.md" ] && continue
    if [ -f "$WORKSPACE_ROOT/.kiro/steering/$STEERING_NAME" ]; then
        echo "✓ .kiro/steering/$STEERING_NAME already exists (skipped)"
    else
        cp "$steering_file" "$WORKSPACE_ROOT/.kiro/steering/$STEERING_NAME"
        echo "✓ Copied steering: $STEERING_NAME"
        STEERING_COPIED=$((STEERING_COPIED + 1))
    fi
done

if [ "$STEERING_COPIED" -eq 0 ]; then
    echo "✓ All steering files already installed"
fi

# ── Step 3: Hooks ───────────────────────────────────────────
mkdir -p "$WORKSPACE_ROOT/.kiro/hooks"

HOOKS_COPIED=0
for hook in "$POWER_DIR/hooks/"*.json; do
    [ -f "$hook" ] || continue
    HOOK_NAME="$(basename "$hook")"
    if [ -f "$WORKSPACE_ROOT/.kiro/hooks/$HOOK_NAME" ]; then
        echo "✓ .kiro/hooks/$HOOK_NAME already exists (skipped)"
    else
        cp "$hook" "$WORKSPACE_ROOT/.kiro/hooks/$HOOK_NAME"
        echo "✓ Copied hook: $HOOK_NAME"
        HOOKS_COPIED=$((HOOKS_COPIED + 1))
    fi
done

if [ "$HOOKS_COPIED" -eq 0 ]; then
    echo "✓ All hooks already installed"
fi

# ── Done ────────────────────────────────────────────────────
echo ""
echo "──────────────────────────────────────────────"
echo "✅ AIDLC workspace setup complete!"
echo ""
echo "Next steps:"
echo "  1. Edit .kiro/steering/project-config.md with your project details:"
echo "     - GitHub org/repo/board number"
echo "     - Team members"
echo "     - Tech stack"
echo "     - Which powers you have installed (remove rows you don't need)"
echo ""
echo "  2. Start using AIDLC in Kiro:"
echo '     "Using AI-DLC, build me ..."'
echo "──────────────────────────────────────────────"
