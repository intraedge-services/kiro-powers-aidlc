---
inclusion: always
---
# Pull Request Workflow — Steering Rules

## MANDATORY: Pre-Push Write Access Check

**Before the FIRST `git push` in a session**, verify the user has write access to the target repo:

```bash
# Check write permission before attempting push
PERMISSION=$(gh repo view "ORG/REPO" --json viewerPermission --jq '.viewerPermission' 2>/dev/null)
if [ "$PERMISSION" != "WRITE" ] && [ "$PERMISSION" != "MAINTAIN" ] && [ "$PERMISSION" != "ADMIN" ]; then
  echo "⚠️ You don't have write access to ORG/REPO (current permission: ${PERMISSION:-none})"
  echo "Options:"
  echo "  1. Fork the repo: gh repo fork ORG/REPO --clone=false"
  echo "  2. Request access from the org admin"
  echo "  3. Push to a personal repo instead"
fi
```

**When to run**: Once per session, before the first `git push`. Do NOT attempt the push if permission is insufficient — it produces confusing 403 errors.

**If permission check fails** (e.g., `gh` not available): warn the user and attempt the push anyway (let git report the error naturally).

---

## PR Creation

When creating a pull request via `gh` CLI:

1. **Always write the body to a temp file first**, then use `-F body=@file`:
   ```bash
   # Write body to file (preserves newlines and markdown)
   cat > /tmp/pr-body.md << 'EOF'
   ## Summary
   ...
   EOF

   # Create PR using file input
   gh pr create --base main --head feature-branch \
     --title "feat: short title" \
     -F /tmp/pr-body.md
   ```

2. **Never use inline `-f body="..."` or `--body "..."`** for multi-line content — this strips newlines and breaks markdown rendering.

3. **PR Title**: Max 70 characters. Use conventional commit format: `feat:`, `fix:`, `chore:`, `docs:`.

4. **PR Description structure**:
   ```markdown
   ## Summary
   One paragraph explaining what and why.

   ## Changes
   - Bullet list of key changes (or table for many files)

   ## Testing
   - What was tested and how

   ## Not Changed
   - Explicitly list what was intentionally left untouched
   ```

## PR Description Updates

When updating an existing PR description:

```bash
# Write updated body to file
cat > /tmp/pr-body.md << 'EOF'
...
EOF

# Update via API (preserves newlines)
gh api repos/ORG/REPO/pulls/NUMBER --method PATCH -F body=@/tmp/pr-body.md
```

Never use `gh pr edit --body "..."` for multi-line content.

## PR Review Comments

When responding to PR review comments:

1. **Read all comments first** before responding:
   ```bash
   gh pr view NUMBER --comments
   gh api repos/ORG/REPO/pulls/NUMBER/comments --jq '.[] | {id, path, body, line}'
   ```

2. **Reply to specific review comments** (not generic issue comments):
   ```bash
   gh api repos/ORG/REPO/pulls/NUMBER/comments/COMMENT_ID/replies \
     --method POST -F body=@/tmp/reply.md
   ```

3. **Response format**:
   - Acknowledge the feedback
   - State what action you took (or why you disagree)
   - Reference the commit that addresses it (if applicable)

   Example:
   ```
   Good catch. Fixed in abc1234 — moved the validation to the service layer.
   ```

4. **For multi-line replies**, always use file input:
   ```bash
   cat > /tmp/reply.md << 'EOF'
   Good point. I've refactored this to:
   - Extract the validation logic into a helper
   - Add unit tests for edge cases
   - Update the error messages

   Fixed in abc1234.
   EOF

   gh api repos/ORG/REPO/pulls/NUMBER/comments/COMMENT_ID/replies \
     --method POST -F body=@/tmp/reply.md
   ```

## PR Review Submission

When submitting a review:

```bash
# Write review body to file
cat > /tmp/review.md << 'EOF'
Looks good overall. A few suggestions:
- Consider adding input validation on line 42
- The error message could be more specific
EOF

gh api repos/ORG/REPO/pulls/NUMBER/reviews \
  --method POST \
  -f event="COMMENT" \
  -F body=@/tmp/review.md
```

## Adding Review Comments on Specific Lines

```bash
cat > /tmp/comment.md << 'EOF'
This could throw a NullPointerException if `user` is null.
Consider adding a null check here.
EOF

gh api repos/ORG/REPO/pulls/NUMBER/comments \
  --method POST \
  -f path="src/auth/service.ts" \
  -f commit_id="abc1234" \
  -F body=@/tmp/comment.md \
  -f line=42 \
  -f side="RIGHT"
```

## Key Rule: File Input for All Multi-Line Content

| Operation | Correct | Wrong |
|-----------|---------|-------|
| PR body | `-F body=@/tmp/file.md` | `--body "..."` or `-f body="..."` |
| Comment reply | `-F body=@/tmp/reply.md` | `-f body="..."` |
| Review body | `-F body=@/tmp/review.md` | `-f body="..."` |
| Single-line | `-f body="Quick fix applied"` | (fine for one-liners) |

The rule is simple: **if it has newlines, use a file**.

## Cleanup

Always clean up temp files after PR operations:
```bash
rm -f /tmp/pr-body.md /tmp/reply.md /tmp/review.md /tmp/comment.md
```
