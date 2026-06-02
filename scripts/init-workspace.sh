#!/bin/bash
# ──────────────────────────────────────────────────────────────
# AIDLC Power — Workspace Initializer
# Run this from your project root after installing the power.
#
# What it does:
#   1. Copies project-config template to .kiro/steering/
#   2. Copies hooks to .kiro/hooks/
#   3. Prints next steps
#
# Usage:
#   .kiro/powers/kiro-powers-aidlc/scripts/init-workspace.sh
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

# ── Step 2: Hooks ───────────────────────────────────────────
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
