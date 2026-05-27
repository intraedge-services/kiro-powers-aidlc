# GitHub Integration Steering

Detailed instructions for integrating AIDLC with GitHub project management via the `kiro-powers-github` power.

## Prerequisites

- `kiro-powers-github` power installed and configured
- GitHub PAT with `repo` + `project` scopes
- Project board created in the GitHub org
- `project-config.md` with GitHub org, repo, and board number

## Spec-to-Issues Flow

### When to Execute
After User Stories stage is approved, before Workflow Planning.

### Issue Creation Format

**Title**: `[AIDLC Story {story_id}] {story_title}`

**Body**:
```markdown
## User Story

{full story text in As a/I want/So that format}

## Acceptance Criteria

- [ ] {criterion 1}
- [ ] {criterion N}

## Traceability

- **Requirement**: {requirement_id}
- **Feature Area**: {feature_area}
- **Source**: `aidlc-docs/inception/user-stories/stories.md`

---
*Created by Kiro AIDLC Power — Spec-to-Issues flow*
```

**Labels** (auto-create if not exists):
- `aidlc:story` — Always applied
- `feature:{area}` — From story's feature area (lowercase, hyphenated)
- `tech-debt` — If story is in Technical Debt section

**Assignees**: From project-config team lead

### Board Placement

After creating each issue:
1. Use `projects_write` with method `add_project_item`
2. Board's default status ("Todo") applies automatically

### Duplicate Detection

Before creating:
1. Search existing issues with label `aidlc:story`
2. Check if title contains same story ID
3. If duplicate: Skip, log in audit.md

## Board Sync Flow

### Stage → Board Status Mapping

| AIDLC Event | Board Action | Issue Comment |
|-------------|-------------|---------------|
| Code Gen starts | Move to "In Progress" | 🔄 Code Generation Started |
| Code Gen approved | Move to "Done" + close | ✅ Code Generation Complete |
| Build & Test starts | Move to "In Progress" | 🔄 Build & Test Started |
| Build & Test approved | Move to "Done" + close | ✅ Implementation Complete |

### Finding the Matching Issue

1. Get unit name from AIDLC context
2. Search issues with label `aidlc:story`
3. Match by story ID in title
4. If no match: Log warning, skip

### Moving Items on the Board

1. `projects_list` method `list_project_items` → get item ID
2. `projects_list` method `list_project_fields` → get Status field ID + option IDs
3. `projects_write` method `update_project_item` → change status

## Error Recovery

- Issue creation fails: Retry once, then log and continue
- Board update fails: Non-blocking, log and continue
- Power not installed: Skip all GitHub integration silently
