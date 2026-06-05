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
  - **AWS CDK Python specifics** (`kiro-powers-aws-cdk-python`): When the unit involves Python CDK constructs:
    1. Use `search_cdk_documentation` to find relevant CDK API references for resources being generated
    2. Use `search_cdk_samples_and_constructs` with `language: "python"` to find reference implementations
    3. Use `cdk_best_practices` to validate the generated code follows AWS best practices
    4. After code generation, use `validate_cloudformation_template` on the synthesized template (if available)
    5. Use `check_cloudformation_template_compliance` for security compliance validation

### Code Generation Complete (Construction)

**Trigger**: Code Generation stage approved by user.

**Check `project-management`**: If registered, find the matching GitHub issue, move to "Done", add completion comment, close the issue.

### Infrastructure Design Stage (Construction)

**Trigger**: Infrastructure Design stage begins.

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

- Power activation fails: Log warning, continue AIDLC workflow
- Issue creation fails: Log error, ask user to retry or skip
- Board update fails: Log warning, continue (non-blocking)
- **Never halt AIDLC due to power orchestration failures**

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
