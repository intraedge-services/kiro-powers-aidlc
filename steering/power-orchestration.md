---
inclusion: auto
---

# Power Orchestration Rules

This steering file defines when and how the AIDLC workflow activates other installed powers based on the project's `project-config.md` registry.

## How Orchestration Works

1. At workflow start, read the project's `.kiro/steering/project-config.md`
2. Parse the "Installed Powers Registry" table
3. At each AIDLC stage transition, check if any registered power should be activated
4. If yes, activate the power using `kiroPowers` action="activate" and execute the defined action
5. Orchestration failures are non-blocking — log a warning and continue the AIDLC workflow

## CRITICAL: Integration with core-workflow.md

This file is auto-included in every interaction. The orchestration checkpoints below are triggered by the AI model when it reaches the corresponding stage in `core-workflow.md`. The core workflow contains explicit `## ORCHESTRATION CHECKPOINT` markers that reference this file.

## Orchestration Rules by Stage

### After User Stories Stage (Inception)

**Trigger**: User stories have been approved by the user (user says "Approve & Continue" at User Stories completion).

**Check**: Is there a power registered with category `project-management` in project-config.md?

**If YES**:
1. Activate the registered project-management power using `kiroPowers` action="activate"
2. Read the generated `aidlc-docs/inception/user-stories/stories.md`
3. For each user story:
   - Create a GitHub issue with title `[AIDLC Story {id}] {story title}`
   - Body: Story description + acceptance criteria as checkboxes
   - Labels: `aidlc:story`
   - Add the issue to the configured project board (from project-config.md)
4. Report to user: "Created {N} issues on the project board. Continuing to next stage."

**If NO**: Skip silently, proceed to next stage.

### Code Generation Start (Construction)

**Trigger**: Code Generation stage begins for a unit.

**Check `project-management`**: If registered, find the matching GitHub issue and move it to "In Progress" on the board.

**Check `data-engineering`**: If registered AND the unit involves Glue/EMR/Athena/Spark, activate the data-engineering power for code patterns.

**Check `infrastructure`**: If registered AND the unit involves CDK/Terraform/CloudFormation, activate the infrastructure power for IaC validation.

### Code Generation Complete (Construction)

**Trigger**: Code Generation stage approved by user.

**Check `project-management`**: If registered, find the matching GitHub issue, move to "Done", add completion comment, close the issue.

### Infrastructure Design Stage (Construction)

**Trigger**: Infrastructure Design stage begins.

**Check `infrastructure`**: Activate for IaC guidance and validation.

**Check `diagrams`**: Generate deployment architecture diagram.

### Functional Design Stage (Construction)

**Trigger**: Functional Design stage completes (domain entities defined).

**Check `diagrams`**: Generate ERD or class diagrams.

### Reverse Engineering Stage (Inception)

**Trigger**: Reverse Engineering stage begins (brownfield projects).

**Check `diagrams`**: Generate system architecture and component interaction diagrams.

## Registry Parsing Rules

The project-config.md contains a table:
```
| Category | Power Name | Activate During |
```

- `Category`: Used to match orchestration rules above
- `Power Name`: The exact power name to pass to `kiroPowers` action="activate"
- `Activate During`: Human-readable (for documentation only)

**If a category has no registered power**: Skip silently.
**If a registered power is not installed**: Warn user: "Power '{name}' is registered but not installed. Skipping orchestration for category '{category}'."

## Error Handling

- Power activation fails: Log warning, continue AIDLC workflow
- Issue creation fails: Log error, ask user to retry or skip
- Board update fails: Log warning, continue (non-blocking)
- **Never halt AIDLC due to power orchestration failures**
