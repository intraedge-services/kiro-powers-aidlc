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

```bash
gh issue comment "$ISSUE_NUMBER" --repo "ORG/REPO" --body "✅ Code Generation Complete — Implementation approved."
gh issue close "$ISSUE_NUMBER" --repo "ORG/REPO" --reason completed
```

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
