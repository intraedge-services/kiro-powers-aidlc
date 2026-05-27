# Power Orchestration Rules

This steering file defines when and how the AIDLC workflow activates other installed powers based on the project's `project-config.md` registry.

## How Orchestration Works

1. At workflow start, read the project's `.kiro/steering/project-config.md`
2. Parse the "Installed Powers Registry" table
3. At each AIDLC stage, check if any registered power should be activated
4. If yes, activate the power and execute the defined action

## Orchestration Rules by Stage

### After User Stories Stage (Inception)

**Trigger**: User stories have been approved by the user.

**Check**: Is there a power registered with category `project-management`?

**If YES**:
1. Activate the registered project-management power
2. Read the generated `aidlc-docs/inception/user-stories/stories.md`
3. For each user story:
   - Create a GitHub issue with title `[AIDLC Story {id}] {story title}`
   - Body: Story description + acceptance criteria as checkboxes + traceability
   - Labels: `aidlc:story` + feature-area label
   - Assignees: From project-config team list
   - Add the issue to the configured project board
   - Set status to "Todo"
4. Ask user: "Created {N} issues on the project board. Continue to next stage?"

**If NO**: Skip, proceed to next stage.

### Code Generation Start (Construction)

**Trigger**: Code Generation stage begins for a unit.

**Check**: Is there a power registered with category `project-management`?

**If YES**:
1. Find the GitHub issue matching the current unit/story
2. Move the issue to "In Progress" on the project board
3. Add comment: "🔄 AIDLC Stage: Code Generation Started"

**Check**: Is there a power registered with category `data-engineering`?

**If YES** and the unit involves Glue/EMR/Athena/Spark:
1. Activate the data-engineering power
2. Use it for code patterns, best practices, and API references

**Check**: Is there a power registered with category `infrastructure`?

**If YES** and the unit involves CDK/Terraform/CloudFormation:
1. Activate the infrastructure power
2. Use it for IaC patterns, resource configuration, and validation

### Code Generation Complete (Construction)

**Trigger**: Code Generation stage approved by user.

**Check**: Is there a power registered with category `project-management`?

**If YES**:
1. Find the GitHub issue matching the current unit/story
2. Move the issue to "Done" on the project board
3. Add comment with implementation summary
4. Close the issue with state_reason "completed"

### Infrastructure Design Stage (Construction)

**Trigger**: Infrastructure Design stage begins.

**Check category `infrastructure`**: Activate for IaC guidance and validation.

**Check category `diagrams`**: Generate deployment architecture diagram.

### Reverse Engineering Stage (Inception)

**Trigger**: Reverse Engineering stage begins (brownfield projects).

**Check category `diagrams`**: Generate system architecture and component interaction diagrams.

### Functional Design Stage (Construction)

**Trigger**: Functional Design stage begins.

**Check category `diagrams`**: Generate ERD or class diagrams after domain entities are defined.

## Registry Parsing Rules

The project-config.md contains a table:
```
| Category | Power Name | Activate During |
```

- `Category`: Used to match orchestration rules above
- `Power Name`: The exact power name to pass to `activate`
- `Activate During`: Human-readable (for documentation only)

**If a category has no registered power**: Skip silently.
**If a registered power is not installed**: Warn user and skip.

## Error Handling

- Power activation fails: Log warning, continue AIDLC
- Issue creation fails: Log error, ask user to retry or skip
- Board update fails: Log warning, continue (non-blocking)
- Never halt AIDLC due to power orchestration failures
