# GitHub Integration Steering

Detailed instructions for integrating AIDLC with project management using CLI tools directly.

## Supported Providers

| Provider | CLI Tool | Issue Command | Board Sync |
|----------|----------|---------------|------------|
| `github` | `gh` | `gh issue create` | `gh project item-add` |
| `gitlab` | `glab` | `glab issue create` | via API |
| `bitbucket` | `bb` | via API | via API |
| `azure-devops` | `az boards` | `az boards work-item create` | automatic |

The workflow reads `Source Control → Provider` from project-config.md and uses the corresponding CLI.

## Prerequisites (GitHub — default)

- `gh` CLI installed ([https://cli.github.com/](https://cli.github.com/))
- Authenticated: `gh auth login` (needs `repo` + `project` scopes)
- Project board created in the GitHub org
- `.kiro/steering/project-config.md` with Source Control + Project Tracking filled in

## Prerequisites (GitLab)

- `glab` CLI installed ([https://gitlab.com/gitlab-org/cli](https://gitlab.com/gitlab-org/cli))
- Authenticated: `glab auth login`
- Board created in the GitLab project

## Why CLI Tools (Not MCP Powers)

- **Fewer tools exposed** → fewer Kiro confirmation prompts → faster workflow
- **No MCP server to run** → simpler setup, no background processes
- **Standard dev tooling** → most developers already have `gh`/`glab` installed
- **Direct execution** → single bash command per operation, no power activation chain

## Spec-to-Issues Flow

### When to Execute
After User Stories stage is approved, before Workflow Planning. This is triggered by:
1. The `spec-to-issues.json` hook (fires on `PostFileCreate` when `stories.md` is created)
2. The steering instruction in `core-workflow.md` step 11 (model executes after user approval)

### Duplicate Detection

Before creating any issue:
```bash
gh issue list --repo "ORG/REPO" --label "aidlc:story" --search "[AIDLC Story {ID}]" --json number --jq 'length'
```
If result > 0: skip that story (already exists).

### Issue Creation

```bash
gh issue create --repo "ORG/REPO" \
  --title "[AIDLC Story {story_id}] {story_title}" \
  --body "## User Story

{full story text in As a/I want/So that format}

## Acceptance Criteria

- [ ] {criterion 1}
- [ ] {criterion N}

## Traceability

- **Story ID**: {story_id}
- **Feature Area**: {feature_area}
- **Source**: aidlc-docs/inception/user-stories/stories.md

---
*Created by Kiro AIDLC*" \
  --label "aidlc:story" \
  --assignee "TEAM_LEAD"
```

### Label Auto-Creation

If the `aidlc:story` label doesn't exist yet:
```bash
gh label create "aidlc:story" --repo "ORG/REPO" --description "AIDLC User Story" --color "0e8a16"
```

### Board Placement

After creating each issue, add to the project board:
```bash
gh project item-add PROJECT_NUMBER --owner "ORG" --url ISSUE_URL
```
The board's default status ("Todo") applies automatically.

## Board Sync Flow

### Stage → Board Action Mapping

| AIDLC Event | `gh` Command | Comment Text |
|-------------|-------------|--------------|
| Code Gen starts | `gh issue comment` | 🔄 Code Generation Started |
| Code Gen approved | `gh issue close --reason completed` | ✅ Code Generation Complete |
| Build & Test starts | `gh issue comment` | 🔄 Build & Test Started |

### Finding the Matching Issue

```bash
# Get issue number by searching for story ID in title
ISSUE_NUMBER=$(gh issue list --repo "ORG/REPO" --label "aidlc:story" --search "[AIDLC Story {ID}]" --json number --jq '.[0].number')
```

If no match found: log warning, skip (non-blocking).

### Commenting on an Issue

```bash
gh issue comment "$ISSUE_NUMBER" --repo "ORG/REPO" --body "🔄 Code Generation Started"
```

### Closing an Issue

When closing an issue after code generation is approved, the closing comment MUST include story-specific implementation details — not just a generic "Complete" message.

**Closing Comment Template:**

```bash
gh issue comment "$ISSUE_NUMBER" --repo "ORG/REPO" --body "## ✅ Implementation Complete

### What Was Built
{Describe the specific feature/endpoint/component that was implemented for THIS story}

### Files Created/Modified
- \`{file_path_1}\` — {what it does}
- \`{file_path_2}\` — {what it does}

### Acceptance Criteria Verified
- [x] {criterion 1 — how it was verified}
- [x] {criterion 2 — how it was verified}
- [x] {criterion N — how it was verified}

### Test Coverage
- {N} unit tests covering this story
- Key test cases: {brief list of what's tested}

---
*Closed by Kiro AIDLC — Code Generation approved*"
gh issue close "$ISSUE_NUMBER" --repo "ORG/REPO" --reason completed
```

**Example — for a "Create a Task" story:**
```bash
gh issue comment "$ISSUE_NUMBER" --repo "ORG/REPO" --body "## ✅ Implementation Complete

### What Was Built
POST /tasks endpoint that creates a new task with auto-generated UUID, default status 'todo', and ISO 8601 timestamp.

### Files Created/Modified
- \`app/routes.py\` — POST /tasks route handler with 201 response
- \`app/models.py\` — TaskCreate schema (title required, description optional)
- \`app/store.py\` — create_task() method with UUID generation

### Acceptance Criteria Verified
- [x] POST /tasks returns 201 with the created task — verified via test_create_task_with_title
- [x] Response includes auto-generated UUID, title, status=todo, and created_at — verified via assertions on response body
- [x] POST /tasks without a title returns 422 — verified via test_create_task_without_title_returns_422
- [x] Optional description field is stored when provided — verified via test_create_task_with_description

### Test Coverage
- 4 unit tests covering this story
- Key test cases: valid creation, creation with description, missing title (422), empty title (422)

---
*Closed by Kiro AIDLC — Code Generation approved*"
gh issue close "$ISSUE_NUMBER" --repo "ORG/REPO" --reason completed
```

**Rules for Closing Comments:**
- NEVER use a generic one-liner like "Code Generation Complete" — always include story-specific details
- Reference actual file paths from the generated code
- Mark each acceptance criterion as checked with a brief note on how it was verified
- Include test count and key test case names relevant to THIS story
- If multiple stories share implementation (e.g., shared models file), still describe what's relevant to each specific story

When an issue is closed and it's on a project board, many board configurations will auto-move it to "Done".

## Helper Script

A standalone script is available at `scripts/sync-stories-to-github.sh` for bulk story creation:

```bash
# Basic usage
./scripts/sync-stories-to-github.sh --repo "org/repo" --project 5 --assignee "username"

# Dry run (preview without creating)
./scripts/sync-stories-to-github.sh --repo "org/repo" --dry-run

# Using environment variables
export AIDLC_GITHUB_REPO="org/repo"
export AIDLC_PROJECT_BOARD="5"
export AIDLC_TEAM_LEAD="username"
./scripts/sync-stories-to-github.sh
```

## Error Recovery

- **`gh` not installed**: Warn user: "⚠️ GitHub CLI (gh) not installed. Install from https://cli.github.com/" — continue workflow (non-blocking)
- **`gh` not authenticated**: Warn user: "⚠️ Run `gh auth login` to enable GitHub sync" — continue workflow (non-blocking)
- **Issue creation fails**: Retry once, then log and continue
- **Board update fails**: Non-blocking, log and continue
- **Config has placeholders**: Skip all GitHub integration silently

## Pull Request Creation

### When to Generate a PR Description

Whenever a PR is created — whether via Kiro (`gh pr create`), manually from the terminal, or from the GitHub UI — the AIDLC workflow MUST generate a detailed PR description from context.

**Trigger**: User asks Kiro to create a PR, push and create PR, or says "create a pull request."

### PR Description Template

The PR description MUST be auto-populated from AIDLC artifacts. Use this structure:

```markdown
## Summary

{2-3 sentence high-level summary of what this PR delivers}

## Stories Implemented

{For each story completed in this branch:}
- [AIDLC Story {ID}] {title} — #{issue_number}

## What Changed

{Group by area, not by file. Focus on behavior changes:}

### {Area 1 — e.g., "Map Component"}
- {What was added/changed and why}

### {Area 2 — e.g., "API Layer"}
- {What was added/changed and why}

## Key Decisions

- {Decision 1 — e.g., "Chose Mapbox over Google Maps for offline support"}
- {Decision 2 — e.g., "Used SWR for client-side caching instead of Redux"}

## How to Test

1. {Step 1}
2. {Step 2}
3. {Step N}

## Files Changed

{Auto-generated from git diff — key files only, not every line:}
- `src/components/MapView.tsx` — New map component
- `src/services/locationService.ts` — Geocoding integration
- `tests/MapView.test.tsx` — Component tests

---
*Generated by Kiro AIDLC*
```

### How to Generate the Content

1. **Summary**: Read `aidlc-docs/aidlc-state.md` and the completed unit plans to summarize scope
2. **Stories**: Match branch work to `aidlc:story` issues (from stories.md)
3. **What Changed**: Read the code gen plan files and group by feature area
4. **Key Decisions**: Extract from functional design / NFR design / infrastructure design docs
5. **How to Test**: Extract from `build-and-test/` instructions
6. **Files Changed**: Run `git diff --stat main...HEAD` to list key files

### CLI Command

```bash
gh pr create --repo "ORG/REPO" \
  --title "{concise title — max 70 chars}" \
  --body "PR_BODY_FROM_TEMPLATE_ABOVE" \
  --base main \
  --head CURRENT_BRANCH
```

### Rules

- **Never create a PR with an empty description** — always populate from context
- **Never create a PR with just a title** — the body is mandatory
- **If AIDLC artifacts aren't available** (e.g., user didn't use full workflow): generate description from `git log` and `git diff --stat` instead
- **Title format**: Keep under 70 chars. Use conventional commits style if the project uses it (e.g., `feat: add interactive city map with POI display`)
- **Link to issues**: Reference story issues with `Closes #N` or `Resolves #N` to auto-close on merge

## Configuration Reference

From `.kiro/steering/project-config.md`:

```markdown
## Source Control
- **Provider**: github
- **Org/Owner**: my-org
- **Repo**: my-repo

## Project Tracking
- **Board Provider**: github-projects
- **Board ID**: 7

## Team
- **Lead**: username

## AIDLC Preferences
- **Auto-create Issues**: yes
- **Auto-sync Board**: yes
```

**Provider-specific behavior:**
- If `Provider` is `github`: uses `gh` CLI
- If `Provider` is `gitlab`: uses `glab` CLI
- If `Provider` is `none` or missing: skips all issue/board operations silently
- If `Board Provider` is `none`: creates issues but skips board placement
- If values contain `{` (placeholder): skips all operations silently

## PR Review Comments Workflow

### Auto-Check on Session Start

The `pr-review-check.json` hook fires on `SessionStart` and checks if the current branch has an open PR with unresolved review comments. If found, it notifies the user and offers to help.

### Addressing Review Comments

When the user asks to address review comments (or accepts the SessionStart prompt), follow this workflow:

1. **Fetch review comments**:
   ```bash
   gh pr view PR_NUMBER --repo "ORG/REPO" --json reviews,comments
   gh api repos/ORG/REPO/pulls/PR_NUMBER/comments --jq '.[] | {id, path, line, body, user: .user.login}'
   ```

2. **Group by file** — present a summary:
   ```markdown
   📝 **Review comments on PR #N:**

   **src/components/MapView.tsx** (2 comments):
   - Line 42: "Consider memoizing this callback" — @reviewer
   - Line 89: "Missing error boundary" — @reviewer

   **src/services/api.ts** (1 comment):
   - Line 15: "Add timeout to fetch" — @reviewer
   ```

3. **Address each comment**:
   - Read the file and the specific line referenced
   - Make the fix based on the reviewer's feedback
   - If the comment is unclear or the agent disagrees, explain why and ask the user

4. **After all fixes applied**:
   - Run tests/build to verify nothing broke
   - Commit with message: `fix: address PR review feedback`
   - Push to the same branch
   - Reply to each review comment on GitHub:
     ```bash
     gh api repos/ORG/REPO/pulls/PR_NUMBER/comments \
       --method POST --field body="Fixed — {brief description}" --field in_reply_to=COMMENT_ID
     ```

5. **Notify the user**:
   ```
   ✅ Addressed N review comments, pushed fixes, and replied on GitHub.
   ```

### Manual Trigger

User can ask anytime:
- "Check PR review comments"
- "Address review feedback on PR #14"
- "What review comments are pending?"

The steering context from this file gives the agent full instructions on how to handle it.

### Rules

- Never auto-fix without user consent (SessionStart hook only notifies, doesn't act)
- If a review comment requires a design decision, ask the user
- Always run tests after making review fixes
- Reply to each comment on GitHub so the reviewer sees the response
- If `gh` is not available, tell the user and skip


## PR Review Workflow (Reviewer Side)

### Purpose

Allows a reviewer to use Kiro to perform a structured PR review based on the project's quality standards, extensions, and AIDLC conventions.

### Trigger

Reviewer says:
- "Review PR #N"
- "Review PR #N using AIDLC quality standards"
- "Review this PR" (if on the branch)

### Review Process

1. **Fetch the PR diff and metadata**:
   ```bash
   gh pr view PR_NUMBER --repo "ORG/REPO" --json title,body,files,additions,deletions,labels
   gh pr diff PR_NUMBER --repo "ORG/REPO"
   ```

2. **Load project context**:
   - Read `.kiro/steering/project-config.md` for tech stack and extensions
   - If `security-baseline` extension is enabled → check security rules against the diff
   - If `resiliency-baseline` extension is enabled → check resiliency patterns
   - Check linked AIDLC story (from labels/title) for acceptance criteria

3. **Analyze the diff against these criteria**:

   | Check | What to Look For |
   |-------|-----------------|
   | **Correctness** | Does the code do what the story/PR description says? |
   | **Acceptance Criteria** | Are all criteria from the linked story met? |
   | **Security** (if extension active) | Input validation, auth, secrets, error handling |
   | **Resiliency** (if extension active) | Retries, timeouts, error boundaries, graceful degradation |
   | **Code Quality** | Naming, structure, duplication, complexity |
   | **Tests** | Are new features tested? Coverage gaps? |
   | **Documentation** | Are public APIs/interfaces documented? |

4. **Generate a structured review**:

   ```markdown
   ## PR Review: #{number} — {title}

   ### Summary
   {2-3 sentences: what the PR does and overall assessment}

   ### ✅ What's Good
   - {Positive observation 1}
   - {Positive observation 2}

   ### 🔍 Suggestions
   
   **{file_path}** (line {N}):
   > {quote the relevant code}
   
   {Explain the issue and suggest a fix}

   **{file_path}** (line {N}):
   > {quote the relevant code}
   
   {Explain the issue and suggest a fix}

   ### 🔒 Extension Compliance
   | Extension | Status | Notes |
   |-----------|--------|-------|
   | security-baseline | ✅ Pass | No issues found |
   | resiliency-baseline | ⚠️ Suggestion | Consider adding retry on line 42 |

   ### Acceptance Criteria Check
   - [x] {criterion 1 — met}
   - [x] {criterion 2 — met}
   - [ ] {criterion 3 — not addressed in this PR}

   ### Verdict
   **{APPROVE / REQUEST_CHANGES / COMMENT}** — {one-line reasoning}
   ```

5. **Ask user before submitting**:
   ```
   Here's my review. Would you like me to:
   - Submit as APPROVE
   - Submit as REQUEST_CHANGES
   - Submit as COMMENT (feedback only)
   - Edit before submitting
   ```

6. **Submit the review on GitHub**:
   ```bash
   gh pr review PR_NUMBER --repo "ORG/REPO" \
     --event {APPROVE|REQUEST_CHANGES|COMMENT} \
     --body "REVIEW_BODY"
   ```

   For inline comments on specific lines:
   ```bash
   gh api repos/ORG/REPO/pulls/PR_NUMBER/comments \
     --method POST \
     --field body="COMMENT" \
     --field commit_id="HEAD_SHA" \
     --field path="FILE_PATH" \
     --field line=LINE_NUMBER \
     --field side="RIGHT"
   ```

### Review Depth Levels

| Request | Depth | Time |
|---------|-------|------|
| "Quick review PR #N" | Skim: correctness + obvious issues only | ~30 sec |
| "Review PR #N" | Standard: all checks above | ~2 min |
| "Deep review PR #N" | Thorough: line-by-line, performance, edge cases, security | ~5 min |

### Rules

- Always show the review to the user before submitting
- Never auto-approve without user confirmation
- If the PR is by the same user, suggest COMMENT instead of APPROVE (can't approve own PR)
- Be constructive — suggest fixes, don't just point out problems
- If no extensions are configured, skip the compliance table
- Keep inline comments focused — one concern per comment, with a suggested fix
- If the diff is too large (>1000 lines), ask user which files to focus on
