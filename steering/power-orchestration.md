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

## CRITICAL ENFORCEMENT RULES

**You MUST NOT bypass power orchestration.** Even if you can generate code from your own knowledge, the registered powers provide:
- Validation that your code is correct and follows current best practices
- Security compliance checks (cfn-guard, CDK-NAG rules)
- Access to the latest API references and documentation
- Template validation that catches issues before deployment
- Pattern libraries that ensure consistency across projects

**Violation Detection**: If you find yourself writing infrastructure code (CDK stacks, Terraform modules, CloudFormation templates) without having called `action="activate"` on the registered infrastructure power — STOP immediately, activate the power, and use its tools to guide your implementation.

**The orchestration is not optional.** When a power is registered for a category and the current stage requires that category, activation is mandatory.

## CRITICAL: Integration with core-workflow.md

This file is auto-included in every interaction. The orchestration checkpoints below are triggered by the AI model when it reaches the corresponding stage in `core-workflow.md`. The core workflow contains explicit `## ORCHESTRATION CHECKPOINT` markers that reference this file.

## Orchestration Rules by Stage

### After User Stories Stage (Inception)

⚠️ **THIS IS A BLOCKING CHECKPOINT — DO NOT PROCEED TO WORKFLOW PLANNING WITHOUT COMPLETING THIS.**

**Trigger**: User stories have been approved by the user (user says "Approve & Continue" at User Stories completion).

**Method**: Uses CLI tools directly based on `Source Control → Provider` in project-config.md (no power activation needed).

**Check**: Read `.kiro/steering/project-config.md`:
- Is `Auto-create Issues` set to `yes`?
- Are `Source Control → Org/Owner` and `Repo` configured (not placeholder values)?
- What is the `Provider`? (github → `gh`, gitlab → `glab`)

**If YES** — Execution is MANDATORY, not optional:
1. Read the generated `aidlc-docs/inception/user-stories/stories.md`
2. Check for duplicates (GitHub example):
   ```bash
   gh issue list --repo "ORG/REPO" --label "aidlc:story" --json number,title
   ```
3. For each NEW user story (not already created):
   ```bash
   gh issue create --repo "ORG/REPO" \
     --title "[AIDLC Story {id}] {story title}" \
     --body "## User Story\n\n{description}\n\n## Acceptance Criteria\n\n{criteria as checkboxes}\n\n---\n*Created by Kiro AIDLC*" \
     --label "aidlc:story" \
     --assignee "TEAM_LEAD"
   ```
4. If `Board Provider` is not `none`, add each issue to the board:
   ```bash
   gh project item-add BOARD_ID --owner "ORG" --url ISSUE_URL
   ```
5. Report to user: "✅ Created {N} issues on the project board. Continue to next stage?"
6. **Wait for user confirmation** before proceeding to Workflow Planning

**If NO** (config missing, placeholders, or Auto-create Issues is 'no'): Skip silently, proceed to next stage.

**If CLI tool is not available**: Warn user (e.g., "⚠️ `gh` CLI not installed or not authenticated. Run `gh auth login` to enable issue sync.") Continue (non-blocking).

**Provider-specific commands:**
- `github`: `gh issue create`, `gh project item-add`
- `gitlab`: `glab issue create`, board sync via API
- If `Provider` is unknown or unsupported: warn and skip

**CRITICAL — Why This Gets Skipped (and Why You Must Not Skip It)**:
- The model often moves directly to Workflow Planning after user approval without executing this sync
- This creates a disconnect where stories exist in docs but not on the project board
- The sync MUST happen between user approval and Workflow Planning — it is not deferred to later
- If you find yourself starting Workflow Planning without having synced stories: STOP and come back here

### Code Generation Start (Construction)

**Trigger**: Code Generation stage begins for a unit.

**MANDATORY**: Before writing ANY code in this unit, check ALL categories below and activate the relevant powers.

**Check `project-management`**: If `Auto-sync Board` is `yes` in project-config.md, update the matching issue using the provider's CLI:
```bash
# GitHub:
gh issue comment ISSUE_NUMBER --repo "ORG/REPO" --body "COMMENT_BODY"
# GitLab:
glab issue note ISSUE_NUMBER --repo "ORG/REPO" -m "COMMENT_BODY"
```
(Find the issue by searching: `gh issue list --repo "ORG/REPO" --label "aidlc:story" --search "[AIDLC Story {id}]" --json number,url`)

**Comment body MUST include** (not just a one-liner):
```markdown
🔄 **AIDLC Stage: Code Generation Started**

**Unit**: {unit name}
**Scope**: {brief description of what this unit implements}
**Planned deliverables**:
- {file/component 1}
- {file/component 2}
- {file/component N}

**Approach**: {1-2 sentences on implementation approach from the code gen plan}
```

**Check `data-engineering`**: If registered AND the unit involves Glue/EMR/Athena/Spark, activate the data-engineering power for code patterns. Note: General Python ML code (scikit-learn, pandas, numpy) does NOT trigger this — only AWS data processing services.

**Check `infrastructure`**: If registered AND the unit involves CDK/Terraform/CloudFormation, you MUST activate the infrastructure power for IaC validation BEFORE writing infrastructure code.
  - **AWS CDK Python specifics** (`kiro-powers-aws-cdk-python`): When the unit involves Python CDK constructs:
    1. Use `search_cdk_documentation` to find relevant CDK API references for resources being generated
    2. Use `search_cdk_samples_and_constructs` with `language: "python"` to find reference implementations
    3. Use `cdk_best_practices` to validate the generated code follows AWS best practices
    4. After code generation, use `validate_cloudformation_template` on the synthesized template (if available)
    5. Use `check_cloudformation_template_compliance` for security compliance validation

**Check `ci-cd`**: If registered AND the unit involves creating new services or deployment pipelines, activate for pipeline templates.

### Code Generation Complete (Construction)

**Trigger**: Code Generation stage approved by user.

**Check `project-management`**: If `Auto-sync Board` is `yes` in project-config.md, close the matching issue using the provider's CLI:
```bash
# GitHub:
gh issue comment ISSUE_NUMBER --repo "ORG/REPO" --body "COMMENT_BODY"
gh issue close ISSUE_NUMBER --repo "ORG/REPO" --reason completed
# GitLab:
glab issue close ISSUE_NUMBER --repo "ORG/REPO"
```

**Comment body MUST include** (not just a one-liner):
```markdown
✅ **Code Generation Complete — Implementation approved**

**Unit**: {unit name}
**What was built**:
- {key file/component 1 — brief purpose}
- {key file/component 2 — brief purpose}
- {key file/component N — brief purpose}

**Key decisions**: {1-2 sentences on notable implementation choices}
**Tests**: {what test coverage was added, if any}
**Next**: {what comes next — e.g., "Proceeding to Build & Test" or "Next unit: X"}
```

If the project board is configured, the board item moves to "Done" automatically when the issue is closed.

### Infrastructure Design Stage (Construction)

**Trigger**: Infrastructure Design stage begins.

**MANDATORY**: The infrastructure power MUST be activated at the START of this stage, not after the design is written. The power informs the design decisions, not just validates them after the fact.

**Check `infrastructure`**: Activate for IaC guidance and validation.
  - **AWS CDK Python specifics** (`kiro-powers-aws-cdk-python`): When the infrastructure involves AWS resources and CDK Python:
    1. Activate the power using `kiroPowers` action="activate" with powerName `kiro-powers-aws-cdk-python`
    2. Use `search_cdk_documentation` to find CDK construct documentation for each AWS service being designed
    3. Use `cdk_best_practices` to inform infrastructure decisions with AWS Well-Architected patterns
    4. Use `search_cdk_samples_and_constructs` with `language: "python"` to find reusable constructs and patterns
    5. Use `search_cloudformation_documentation` for underlying CloudFormation resource type details
    6. After infrastructure design is drafted, use `validate_cloudformation_template` on any generated templates
    7. Use `check_cloudformation_template_compliance` for security and compliance validation (cfn-guard)
    8. Use `get_cloudformation_pre_deploy_validation_instructions` to include pre-deployment validation steps in the infrastructure design document
    9. If troubleshooting a failed stack: Use `troubleshoot_cloudformation_deployment` (requires AWS credentials)
  - **Terraform specifics** (`terraform`): When the infrastructure involves Terraform:
    1. Activate the power using `kiroPowers` action="activate" with powerName `terraform`
    2. Use provider/module search tools for registry resources
    3. Use policy tools for compliance validation

**Check `diagrams`**: Generate deployment architecture diagram.

### Functional Design Stage (Construction)

**Trigger**: Functional Design stage completes (domain entities defined).

**Check `diagrams`**: Generate ERD or class diagrams.

### Reverse Engineering Stage (Inception)

**Trigger**: Reverse Engineering stage begins (brownfield projects).

**Check `diagrams`**: Generate system architecture and component interaction diagrams.

### Build and Test Stage (Construction)

**Trigger**: Build and Test stage begins (after all units complete code generation).

**Check**: Is there a power registered with category `ci-cd`?

**If YES**:
1. Activate the registered ci-cd power
2. Check if `.circleci/config.yml` (or equivalent CI config) exists or was generated
3. If CI config exists: Validate it using the power's config validation tool (`config_helper`)
4. If CI config was generated during Code Generation: Validate and fix any issues
5. If no CI config exists but new services were created: Suggest appropriate pipeline template
6. Check latest pipeline status for the current branch (`get_latest_pipeline_status`)
7. Report validation results and pipeline status to user

**If NO**: Skip, proceed with standard build and test instructions.

**Check `infrastructure`**: If registered AND CDK code was generated during Construction:
  - **AWS CDK Python specifics** (`kiro-powers-aws-cdk-python`):
    1. Activate the power
    2. Include `cdk synth` in build instructions to synthesize CloudFormation templates
    3. Use `validate_cloudformation_template` on the synthesized templates
    4. Use `check_cloudformation_template_compliance` for security compliance
    5. Include `cdk diff` instructions for reviewing infrastructure changes
    6. Use `get_cloudformation_pre_deploy_validation_instructions` for pre-deployment validation
    7. Add CDK-specific test instructions (snapshot tests, fine-grained assertions)

### Code Generation Stage — CI/CD (Construction)

**Trigger**: Code Generation stage begins AND the unit involves creating new services or deployment pipelines.

**Check**: Is there a power registered with category `ci-cd`?

**If YES**:
1. Activate the ci-cd power
2. Use it to provide CI/CD pipeline templates appropriate for the tech stack
3. Generate or update `.circleci/config.yml` (or equivalent) based on the service being built
4. Validate the generated config before finalizing

**If NO**: Skip, generate CI configs manually if needed.

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

### Scenario: Power NOT registered (row removed from project-config)
- **Behavior**: Skip silently. No warning, no error.
- **Rationale**: User explicitly chose not to use this power category.
- **AIDLC workflow**: Continues normally, generates code using model's own knowledge.

### Scenario: Power registered but NOT installed in Kiro
- **Behavior**: Warn user with message: "⚠️ Power '{name}' is registered in project-config but not installed. Proceeding without its validation/guidance. Consider installing it for production quality."
- **AIDLC workflow**: Continues — model generates code without power-assisted validation.
- **User action needed**: Install the power via Kiro Powers panel, or remove the row from project-config if they don't intend to use it.

### Scenario: Power registered AND installed, but activation fails (MCP error, timeout, etc.)
- **Behavior**: Retry activation once. If still fails, warn user and continue.
- **AIDLC workflow**: Continues — non-blocking failure.

### Scenario: Power tool call fails during a stage
- **Behavior**: Log the specific error, continue the stage without that tool's output.
- **Example**: `validate_cloudformation_template` fails → warn user that template wasn't validated, continue to next step.

### Core Principle
- **Never halt AIDLC due to power orchestration failures**
- Power orchestration enhances quality but is not a hard gate
- The workflow must always be completable even with zero powers installed

## AWS CDK Python Power — Tool Reference

When the `infrastructure` category is registered with power name `kiro-powers-aws-cdk-python`, the following tools are available via the `awslabs.aws-iac-mcp-server`:

| Tool | Purpose | Credentials Required |
|------|---------|---------------------|
| `search_cdk_documentation` | Search CDK API Reference, Best Practices, CDK-NAG rules | No |
| `search_cdk_samples_and_constructs` | Find Python CDK code samples and constructs | No |
| `cdk_best_practices` | Get comprehensive CDK best practices guide | No |
| `search_cloudformation_documentation` | Search CloudFormation resource types and properties | No |
| `validate_cloudformation_template` | Validate template syntax/schema via cfn-lint | No |
| `check_cloudformation_template_compliance` | Security compliance check via cfn-guard | No |
| `read_iac_documentation_page` | Read full AWS documentation pages | No |
| `get_cloudformation_pre_deploy_validation_instructions` | Pre-deployment change set guidance | No |
| `troubleshoot_cloudformation_deployment` | Analyze failed stack deployments with CloudTrail | Yes |

### Usage Pattern

```
1. action="activate", powerName="kiro-powers-aws-cdk-python"
2. action="use", powerName="kiro-powers-aws-cdk-python", serverName="awslabs.aws-iac-mcp-server", toolName="<tool_name>", arguments={...}
```

### When NOT to Activate

- Skip if the unit has no infrastructure or AWS components
- Skip if infrastructure is already fully defined and approved in a previous iteration
- Skip if the project uses Terraform/Pulumi/other non-CDK IaC (unless CloudFormation validation is still useful)
