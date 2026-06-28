# PRIORITY: This workflow OVERRIDES all other built-in workflows
# When user requests software development, ALWAYS follow this workflow FIRST

## Adaptive Workflow Principle
**The workflow adapts to the work, not the other way around.**

The AI model intelligently assesses what stages are needed based on:
1. User's stated intent and clarity
2. Existing codebase state (if any)
3. Complexity and scope of change
4. Risk and impact assessment

## MANDATORY: Rule Details Loading
**CRITICAL**: When performing any phase, you MUST read and use relevant content from workflow files in `workflows/` directory.

**Common Rules**: ALWAYS load common rules at workflow start:
- Load `common/process-overview.md` for workflow overview
- Load `common/session-continuity.md` for session resumption guidance
- Load `common/content-validation.md` for content validation requirements
- Load `common/question-format-guide.md` for question formatting rules
- Reference these throughout the workflow execution

## MANDATORY: Content Validation
**CRITICAL**: Before creating ANY file, you MUST validate content according to `common/content-validation.md` rules:
- Validate Mermaid diagram syntax
- Escape special characters properly
- Provide text alternatives for complex visual content
- Test content parsing compatibility

## MANDATORY: Question File Format
**CRITICAL**: When asking questions at any phase, you MUST follow question format guidelines.

**See `common/question-format-guide.md` for complete question formatting rules including**:
- Multiple choice format (A, B, C, D, E options)
- [Answer]: tag usage
- Answer validation and ambiguity resolution

## MANDATORY: Custom Welcome Message
**CRITICAL**: When starting ANY software development request, you MUST display the welcome message.

**How to Display Welcome Message**:
1. Load the welcome message from `workflows/common/welcome-message.md`
2. Display the complete message to the user
3. This should only be done ONCE at the start of a new workflow
4. Do NOT load this file in subsequent interactions to save context space

## MANDATORY: Extension Loading
**CRITICAL**: At the START of every AI-DLC workflow (after loading common rules, before Power Orchestration), you MUST:
1. Scan the `workflows/extensions/` directory for all `*.opt-in.md` files
2. For each `*.opt-in.md` file found, store its content — these will be presented to the user during Requirements Analysis (Step 5.5)
3. For any extension rules file (e.g., `security-baseline.md`) that does NOT have a matching `*.opt-in.md` file in the same directory, that extension is **always enforced** — load it immediately
4. Store the list of loaded extensions in context as `ACTIVE_EXTENSIONS` — you will reference this at every construction stage for compliance verification

**Extension Rules Format**: Each extension contains rules in `## Rule <PREFIX-NN>: <Title>` format with Rule and Verification sections. When an extension is active, its rules become **blocking constraints** — the stage cannot complete until all applicable rules pass verification.

**Extension Naming Convention**: The rules file name is derived from the opt-in file by stripping `.opt-in.md` and appending `.md`. Example: `security-baseline.opt-in.md` → `security-baseline.md`.

**If no `workflows/extensions/` directory exists**: Skip extension loading silently.

## MANDATORY: Power Orchestration
**CRITICAL**: At the START of every AI-DLC workflow, you MUST:
1. Check if `.kiro/steering/project-config.md` exists in the workspace
2. If it exists: Read it and parse the **"Installed Powers Registry"** table
3. Store the registry in context — you will reference it at specific stage transitions below
4. At each stage marked with **🔌 POWER ORCHESTRATION**, execute the orchestration actions defined in `steering/power-orchestration.md` for that stage
5. If `.kiro/steering/project-config.md` does NOT exist: Skip all power orchestration silently

**Power Activation Method**: When orchestration rules say "activate a power," use the Kiro Powers tool:
- Call `action="activate"` with the power name from the registry
- Then call `action="use"` with the appropriate server/tool as needed
- If the power is not installed, warn the user and continue

**CRITICAL — NEVER SKIP ORCHESTRATION**: You MUST NOT generate infrastructure code (CDK, Terraform, CloudFormation), CI/CD pipelines, or data engineering code directly without first ATTEMPTING to activate the registered power for that category. Writing IaC code without activating the `infrastructure` power is a VIOLATION of the workflow rules, even if you believe you can produce the code correctly from your own knowledge. The power provides validation, best practices, and compliance checks that direct generation cannot replicate.

**Exception — Power Not Available**: If a power activation fails because the power is NOT INSTALLED in the user's Kiro environment:
1. Warn the user: "⚠️ Power '{name}' is registered in project-config but not installed. I will proceed without its validation/guidance. Consider installing it for production quality."
2. Continue the AIDLC workflow — generate the code using your own knowledge
3. This is the ONLY valid reason to skip orchestration for a registered power
4. If the power IS installed but activation fails for other reasons (network, MCP error): retry once, then warn and continue

**Orchestration Violation Self-Check**: Before writing ANY code in a unit, ask yourself:
1. Does this unit involve infrastructure/IaC? → Is the `infrastructure` power activated?
2. Does this unit involve Glue/EMR/Athena? → Is the `data-engineering` power activated?
3. Does this unit involve CI/CD pipelines? → Is the `ci-cd` power activated?
4. If the answer to any above is YES but power is NOT activated → STOP and activate it NOW.

**Error Handling**: Power orchestration failures are NEVER blocking. Log a warning and continue the AIDLC workflow.

# Adaptive Software Development Workflow

---

## OPTIONAL: Pre-Workflow Analysis

**CRITICAL**: After displaying the welcome message and BEFORE starting the Inception phase, you MUST ask the user if they want to explore/analyze the project further.

**How to Ask**:
After the welcome message is displayed, present this prompt to the user:

```markdown
> **🔍 <u>**PROJECT ANALYSIS (Optional)**</u>**
>
> Before we start the development workflow, would you like to explore and analyze your project further?
>
> Analysis mode helps you:
> • Understand the problem domain deeply
> • Clarify requirements and scope
> • Investigate technical constraints
> • Compare architectural approaches
> • Surface risks and unknowns
>
> **Your options:**
>
> 🔬 **Yes, analyze first** — Enter analysis mode to explore the project landscape before building
> 🚀 **No, proceed directly** — Start the AIDLC workflow immediately
```

**Handling the Response**:

- **If user chooses to analyze**: Activate the `aidlc-analyze` skill. This enters analysis mode — a collaborative, open-ended exploration of the project's requirements, domain, constraints, and landscape. When the user is satisfied, they can exit analysis mode and the AIDLC workflow will resume from the Inception phase.

- **If user chooses to proceed**: Skip analysis and continue directly to the Inception phase (Workspace Detection).

- **If user's intent is already very clear and specific**: You may still offer the analysis option, but present the "proceed directly" option as the recommended default. Example: If the user says "Using AI-DLC, add a login button to the navbar", analysis is likely unnecessary — but always offer the choice.

**Note**: This analysis step is entirely optional and non-blocking. It does NOT produce mandatory artifacts. Any insights captured during analysis will naturally inform the Requirements Analysis stage when the workflow begins.

---

# INCEPTION PHASE

**Purpose**: Planning, requirements gathering, and architectural decisions

**Focus**: Determine WHAT to build and WHY

**Stages in INCEPTION PHASE**:
- Workspace Detection (ALWAYS)
- Reverse Engineering (CONDITIONAL - Brownfield only)
- Requirements Analysis (ALWAYS - Adaptive depth)
- User Stories (CONDITIONAL)
- Workflow Planning (ALWAYS)
- Application Design (CONDITIONAL)
- Units Generation (CONDITIONAL)

---

## Workspace Detection (ALWAYS EXECUTE)

1. **MANDATORY**: Log initial user request in audit.md with complete raw input
2. Load all steps from `inception/workspace-detection.md`
3. Execute workspace detection:
   - Check for existing aidlc-state.md (resume if found)
   - Scan workspace for existing code
   - Determine if brownfield or greenfield
   - Check for existing reverse engineering artifacts
4. Determine next phase: Reverse Engineering (if brownfield and no artifacts) OR Requirements Analysis
5. **MANDATORY**: Log findings in audit.md
6. Present completion message to user (see workspace-detection.md for message formats)
7. Automatically proceed to next phase

## Reverse Engineering (CONDITIONAL - Brownfield Only)

**Execute IF**:
- Existing codebase detected
- No previous reverse engineering artifacts found

**Skip IF**:
- Greenfield project
- Previous reverse engineering artifacts exist

**Execution**:
1. **MANDATORY**: Log start of reverse engineering in audit.md
2. Load all steps from `inception/reverse-engineering.md`
3. 🔌 **POWER ORCHESTRATION**: Check if a power is registered with category `diagrams`. If YES: activate it — it will be used to generate system architecture and component interaction diagrams during this stage.
4. Execute reverse engineering:
   - Analyze all packages and components
   - Generate a busienss overview of the whole system covering the business transactions
   - Generate architecture documentation
   - Generate code structure documentation
   - Generate API documentation
   - Generate component inventory
   - Generate Interaction Diagrams depicting how business transactions are implemented across components (use `diagrams` power if activated)
   - Generate technology stack documentation
   - Generate dependencies documentation

5. **Wait for Explicit Approval**: Present detailed completion message (see reverse-engineering.md for message format) - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

## Requirements Analysis (ALWAYS EXECUTE - Adaptive Depth)

**Always executes** but depth varies based on request clarity and complexity:
- **Minimal**: Simple, clear request - just document intent analysis
- **Standard**: Normal complexity - gather functional and non-functional requirements
- **Comprehensive**: Complex, high-risk - detailed requirements with traceability

**Execution**:
1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/requirements-analysis.md`
3. Execute requirements analysis:
   - Load reverse engineering artifacts (if brownfield)
   - Analyze user request (intent analysis)
   - Determine requirements depth needed
   - Assess current requirements
   - Ask clarifying questions (if needed)
   - Generate requirements document
4. Execute at appropriate depth (minimal/standard/comprehensive)
5. **Wait for Explicit Approval**: Follow approval format from requirements-analysis.md detailed steps - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

## User Stories (CONDITIONAL)

**INTELLIGENT ASSESSMENT**: Use multi-factor analysis to determine if user stories add value:

**ALWAYS Execute IF** (High Priority Indicators):
- New user-facing features or functionality
- Changes affecting user workflows or interactions
- Multiple user types or personas involved
- Complex business requirements with acceptance criteria needs
- Cross-functional team collaboration required
- Customer-facing API or service changes
- New product capabilities or enhancements

**LIKELY Execute IF** (Medium Priority - Assess Complexity):
- Modifications to existing user-facing features
- Backend changes that indirectly affect user experience
- Integration work that impacts user workflows
- Performance improvements with user-visible benefits
- Security enhancements affecting user interactions
- Data model changes affecting user data or reports

**COMPLEXITY-BASED ASSESSMENT**: For medium priority cases, execute user stories if:
- Request involves multiple components or services
- Changes span multiple user touchpoints
- Business logic is complex or has multiple scenarios
- Requirements have ambiguity that stories could clarify
- Implementation affects multiple user journeys
- Change has significant business impact or risk

**SKIP ONLY IF** (Low Priority - Simple Cases):
- Pure internal refactoring with zero user impact
- Simple bug fixes with clear, isolated scope
- Infrastructure changes with no user-facing effects
- Technical debt cleanup with no functional changes
- Developer tooling or build process improvements
- Documentation-only updates

**ASSESSMENT CRITERIA**: When in doubt, favor inclusion of user stories for:
- Requests with business stakeholder involvement
- Changes requiring user acceptance testing
- Features with multiple implementation approaches
- Work that benefits from shared team understanding
- Projects where requirements clarity is valuable

**ASSESSMENT PROCESS**: 
1. Analyze request complexity and scope
2. Identify user impact (direct or indirect)
3. Evaluate business context and stakeholder needs
4. Consider team collaboration benefits
5. Default to inclusion for borderline cases

**Note**: If Requirements Analysis executed, Stories can reference and build upon those requirements.

**User Stories has two parts within one stage**:
1. **Part 1 - Planning**: Create story plan with questions, collect answers, analyze for ambiguities, get approval
2. **Part 2 - Generation**: Execute approved plan to generate stories and personas

**Execution**:
1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/user-stories.md`
3. **MANDATORY**: Perform intelligent assessment (Step 1 in user-stories.md) to validate user stories are needed
4. Load reverse engineering artifacts (if brownfield)
5. If Requirements exist, reference them when creating stories
6. Execute at appropriate depth (minimal/standard/comprehensive)
7. **PART 1 - Planning**: Create story plan with questions, wait for user answers, analyze for ambiguities, get approval
8. **PART 2 - Generation**: Execute approved plan to generate stories and personas
9. **Wait for Explicit Approval**: Follow approval format from user-stories.md detailed steps - DO NOT PROCEED until user confirms
10. **MANDATORY**: Log user's response in audit.md with complete raw input
11. 🔌 **MANDATORY — GitHub Sync After User Stories Approved**: 

    ⚠️ **DO NOT SKIP THIS STEP. DO NOT PROCEED TO WORKFLOW PLANNING UNTIL THIS IS COMPLETE.**

    Immediately after the user approves the stories, you MUST sync them to GitHub using the `gh` CLI:
    
    a. Read `.kiro/steering/project-config.md` and check:
       - Is `Auto-create Issues` set to `yes`?
       - Are `GitHub Org`, `GitHub Repo`, `Project Board Number` configured (not placeholders)?
    b. **If NO** (config missing, placeholders, or Auto-create is 'no'): Skip silently, proceed to Workflow Planning.
    c. **If YES**:
       1. Read the generated `aidlc-docs/inception/user-stories/stories.md`
       2. Check for duplicate issues:
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
       4. Add each issue to the project board:
          ```bash
          gh project item-add PROJECT_NUMBER --owner "ORG" --url ISSUE_URL
          ```
       5. Report to user: "✅ Created {N} issues on the GitHub project board. Continue to next stage?"
       6. **Wait for user confirmation before proceeding to Workflow Planning**
    d. If `gh` CLI is not available: warn user ("⚠️ `gh` not installed or not authenticated. Run `gh auth login`.") and continue (non-blocking)
    
    **SELF-CHECK**: Before starting Workflow Planning, ask yourself: "Did I sync stories to GitHub?" If the answer is NO and the config IS set up — STOP and go back to complete step 11.

## Workflow Planning (ALWAYS EXECUTE)

1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/workflow-planning.md`
3. **MANDATORY**: Load content validation rules from `common/content-validation.md`
4. Load all prior context:
   - Reverse engineering artifacts (if brownfield)
   - Intent analysis
   - Requirements (if executed)
   - User stories (if executed)
5. Execute workflow planning:
   - Determine which phases to execute
   - Determine depth level for each phase
   - Create multi-package change sequence (if brownfield)
   - Generate workflow visualization (VALIDATE Mermaid syntax before writing)
6. **MANDATORY**: Validate all content before file creation per content-validation.md rules
7. **Wait for Explicit Approval**: Present recommendations using language from workflow-planning.md Step 9, emphasizing user control to override recommendations - DO NOT PROCEED until user confirms
8. **MANDATORY**: Log user's response in audit.md with complete raw input

## Application Design (CONDITIONAL)

**Execute IF**:
- New components or services needed
- Component methods and business rules need definition
- Service layer design required
- Component dependencies need clarification

**Skip IF**:
- Changes within existing component boundaries
- No new components or methods
- Pure implementation changes

**Execution**:
1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/application-design.md`
3. Load reverse engineering artifacts (if brownfield)
4. Execute at appropriate depth (minimal/standard/comprehensive)
5. **Wait for Explicit Approval**: Present detailed completion message (see application-design.md for message format) - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

## Units Generation (CONDITIONAL)

**Execute IF**:
- System needs decomposition into multiple units of work
- Multiple services or modules required
- Complex system requiring structured breakdown

**Skip IF**:
- Single simple unit
- No decomposition needed
- Straightforward single-component implementation

**Execution**:
1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `inception/units-generation.md`
3. Load reverse engineering artifacts (if brownfield)
4. Execute at appropriate depth (minimal/standard/comprehensive)
5. **Wait for Explicit Approval**: Present detailed completion message (see units-generation.md for message format) - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

---

# 🟢 CONSTRUCTION PHASE

**Purpose**: Detailed design, NFR implementation, and code generation

**Focus**: Determine HOW to build it

**Stages in CONSTRUCTION PHASE**:
- Per-Unit Loop (executes for each unit):
  - Functional Design (CONDITIONAL, per-unit)
  - NFR Requirements (CONDITIONAL, per-unit)
  - NFR Design (CONDITIONAL, per-unit)
  - Infrastructure Design (CONDITIONAL, per-unit)
  - Code Generation (ALWAYS, per-unit)
- Build and Test (ALWAYS - after all units complete)

**Note**: Each unit is completed fully (design + code) before moving to the next unit.

## MANDATORY: Extension Compliance Verification (Per-Stage)

**At the END of every construction stage** (before presenting the completion message), you MUST:
1. Check `ACTIVE_EXTENSIONS` for any extensions that apply to the current stage
2. For each applicable extension, read its enforcement table to identify which rules apply to this stage
3. For each applicable rule, verify all checklist items in the Verification section
4. **If all rules pass**: Include a brief compliance note in the stage output: `✅ Extension compliance: [extension names] — all applicable rules verified`
5. **If any rule fails**: Report the failing rule(s) and specific verification items that failed. The stage CANNOT be marked complete until:
   - The issue is fixed and re-verified, OR
   - The user explicitly acknowledges and waives the finding with documented justification (logged in audit.md)

**Compliance Check Format**:
```markdown
### 🔒 Extension Compliance Check
| Extension | Rule | Status | Notes |
|-----------|------|--------|-------|
| Security Baseline | SEC-01: Input Validation | ✅ Pass | All inputs validated |
| Security Baseline | SEC-02: Auth & Authz | ⚠️ Waived | User accepted: PoC only |
```

---

## Per-Unit Loop (Executes for Each Unit)

**For each unit of work, execute the following stages in sequence:**

### Functional Design (CONDITIONAL, per-unit)

**Execute IF**:
- New data models or schemas
- Complex business logic
- Business rules need detailed design

**Skip IF**:
- Simple logic changes
- No new business logic

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/functional-design.md`
3. 🔌 **POWER ORCHESTRATION**: Check if a power is registered with category `diagrams`. If YES: activate it — use it to generate ERD or class diagrams after domain entities are defined in this stage.
4. Execute functional design for this unit
5. **MANDATORY**: Present standardized 2-option completion message as defined in functional-design.md - DO NOT use emergent 3-option behavior
6. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
7. **MANDATORY**: Log user's response in audit.md with complete raw input

### NFR Requirements (CONDITIONAL, per-unit)

**Execute IF**:
- Performance requirements exist
- Security considerations needed
- Scalability concerns present
- Tech stack selection required

**Skip IF**:
- No NFR requirements
- Tech stack already determined

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/nfr-requirements.md`
3. Execute NFR assessment for this unit
4. **MANDATORY**: Present standardized 2-option completion message as defined in nfr-requirements.md - DO NOT use emergent behavior
5. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

### NFR Design (CONDITIONAL, per-unit)

**Execute IF**:
- NFR Requirements was executed
- NFR patterns need to be incorporated

**Skip IF**:
- No NFR requirements
- NFR Requirements Assessment was skipped

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/nfr-design.md`
3. Execute NFR design for this unit
4. **MANDATORY**: Present standardized 2-option completion message as defined in nfr-design.md - DO NOT use emergent behavior
5. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input

### Infrastructure Design (CONDITIONAL, per-unit)

**Execute IF**:
- Infrastructure services need mapping
- Deployment architecture required
- Cloud resources need specification

**Skip IF**:
- No infrastructure changes
- Infrastructure already defined

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/infrastructure-design.md`
3. 🔌 **POWER ORCHESTRATION — MANDATORY FOR INFRASTRUCTURE**: Before doing ANY infrastructure design work, you MUST check the power registry:
   - Category `infrastructure`: If registered, you MUST activate it BEFORE designing infrastructure. This is NON-NEGOTIABLE.
     - Call `action="activate"` with the registered power name (e.g., `kiro-powers-aws-cdk-python`)
     - Use `search_cdk_documentation` to find CDK API references for each AWS service being designed
     - Use `cdk_best_practices` to inform infrastructure decisions
     - Use `search_cdk_samples_and_constructs` (language: "python") to find reference implementations
     - After drafting the infrastructure design, use `validate_cloudformation_template` on any generated templates
     - Use `check_cloudformation_template_compliance` for security compliance
   - Category `diagrams`: If registered, activate it — use to generate deployment architecture diagrams during this stage.
   - **SELF-CHECK**: If you are about to write infrastructure design without having activated the infrastructure power, STOP. Go back and activate it first.
4. Execute infrastructure design for this unit
5. **MANDATORY**: Present standardized 2-option completion message as defined in infrastructure-design.md - DO NOT use emergent behavior
6. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
7. **MANDATORY**: Log user's response in audit.md with complete raw input

### Code Generation (ALWAYS EXECUTE, per-unit)

**Always executes for each unit**

**Code Generation has two parts within one stage**:
1. **Part 1 - Planning**: Create detailed code generation plan with explicit steps
2. **Part 2 - Generation**: Execute approved plan to generate code, tests, and artifacts

**Execution**:
1. **MANDATORY**: Log any user input during this stage in audit.md
2. Load all steps from `construction/code-generation.md`
3. 🔌 **POWER ORCHESTRATION — Code Generation Start (MANDATORY CHECK)**: Before generating ANY code, check the power registry:
   - **GitHub Board Sync** (uses `gh` CLI): If `Auto-sync Board` is `yes` in project-config.md, find the matching GitHub issue and add a detailed comment:
     ```bash
     gh issue list --repo "ORG/REPO" --label "aidlc:story" --search "[AIDLC Story {id}]" --json number --jq '.[0].number'
     gh issue comment ISSUE_NUMBER --repo "ORG/REPO" --body "🔄 **AIDLC Stage: Code Generation Started**

     **Unit**: {unit name}
     **Scope**: {what this unit implements}
     **Planned deliverables**:
     - {file/component 1}
     - {file/component 2}

     **Approach**: {1-2 sentences from the code gen plan}"
     ```
   - Category `data-engineering`: If registered AND the unit involves Glue/EMR/Athena/Spark workloads, you MUST activate it — use for code patterns, best practices, and API references during code generation.
   - Category `infrastructure`: If registered AND the unit involves CDK/Terraform/CloudFormation/IaC code, you MUST activate it — use for IaC patterns, code samples, and validation during code generation. Do NOT write CDK/Terraform code without activating this power first.
   - Category `ci-cd`: If registered AND the unit involves creating new services or pipelines, activate it — use for CI/CD pipeline templates and configuration generation.
   - **SELF-CHECK**: Before writing code, verify: "Have I activated ALL powers relevant to this unit's technology?"
4. **PART 1 - Planning**: Create code generation plan with checkboxes, get user approval
5. **PART 2 - Generation**: Execute approved plan to generate code for this unit
6. **MANDATORY**: Present standardized 2-option completion message as defined in code-generation.md - DO NOT use emergent behavior
7. **Wait for Explicit Approval**: User must choose between "Request Changes" or "Continue to Next Stage" - DO NOT PROCEED until user confirms
8. **MANDATORY**: Log user's response in audit.md with complete raw input
9. 🔌 **POWER ORCHESTRATION — Code Generation Complete**: If `Auto-sync Board` is `yes` in project-config.md, close each matching GitHub issue with a **detailed story-specific closing comment** (NOT a generic one-liner):
   ```bash
   gh issue comment ISSUE_NUMBER --repo "ORG/REPO" --body "## ✅ Implementation Complete

   ### What Was Built
   {Describe the specific endpoint/component/feature implemented for THIS story}

   ### Files Created/Modified
   - \`{file_path}\` — {purpose}
   - \`{file_path}\` — {purpose}

   ### Acceptance Criteria Verified
   - [x] {criterion 1} — verified via {test name or method}
   - [x] {criterion 2} — verified via {test name or method}

   ### Test Coverage
   - {N} unit tests covering this story
   - Key tests: {test names relevant to this story}

   ---
   *Closed by Kiro AIDLC — Code Generation approved*"
   gh issue close ISSUE_NUMBER --repo "ORG/REPO" --reason completed
   ```
   **NEVER** use a generic message like "Code Generation Complete" — always include story-specific implementation details, file paths, acceptance criteria verification, and test coverage.
   If `gh` fails, warn and continue (non-blocking).

---

## Build and Test (ALWAYS EXECUTE)

1. **MANDATORY**: Log any user input during this phase in audit.md
2. Load all steps from `construction/build-and-test.md`
3. 🔌 **POWER ORCHESTRATION — Build and Test**: Check the power registry for:
   - Category `ci-cd`: If registered, activate it. Use it to:
     - Validate any generated `.circleci/config.yml` or CI pipeline configurations
     - Provide pipeline templates if new services need CI/CD setup
     - Check latest pipeline status for the current branch
   - **GitHub Board Sync** (uses `gh` CLI): If `Auto-sync Board` is `yes`, add a comment to matching issues: `gh issue comment ISSUE_NUMBER --repo "ORG/REPO" --body "🔄 AIDLC Stage: Build & Test Started"`
4. Generate comprehensive build and test instructions:
   - Build instructions for all units
   - Unit test execution instructions
   - Integration test instructions (test interactions between units)
   - Performance test instructions (if applicable)
   - Additional test instructions as needed (contract tests, security tests, e2e tests)
4. Create instruction files in build-and-test/ subdirectory: build-instructions.md, unit-test-instructions.md, integration-test-instructions.md, performance-test-instructions.md, build-and-test-summary.md
5. **Wait for Explicit Approval**: Ask: "**Build and test instructions complete. Ready to proceed to Operations stage?**" - DO NOT PROCEED until user confirms
6. **MANDATORY**: Log user's response in audit.md with complete raw input
7. 🔌 **PR CREATION**: If the user asks to create a PR (or says "push and create PR"), you MUST generate a detailed PR description following the template in `steering/github-integration.md` → "Pull Request Creation" section. Never create a PR with an empty or one-line description.

---

# 🟡 OPERATIONS PHASE

**Purpose**: Placeholder for future deployment and monitoring workflows

**Focus**: How to DEPLOY and RUN it (future expansion)

**Stages in OPERATIONS PHASE**:
- Operations (PLACEHOLDER)

---

## Operations (PLACEHOLDER)

**Status**: This stage is currently a placeholder for future expansion.

The Operations stage will eventually include:
- Deployment planning and execution
- Monitoring and observability setup
- Incident response procedures
- Maintenance and support workflows
- Production readiness checklists

**Current State**: All build and test activities are handled in the CONSTRUCTION phase.

## Key Principles

- **Adaptive Execution**: Only execute stages that add value
- **Transparent Planning**: Always show execution plan before starting
- **User Control**: User can request stage inclusion/exclusion
- **Progress Tracking**: Update aidlc-state.md with executed and skipped stages
- **Complete Audit Trail**: Log ALL user inputs and AI responses in audit.md with timestamps
  - **CRITICAL**: Capture user's COMPLETE RAW INPUT exactly as provided
  - **CRITICAL**: Never summarize or paraphrase user input in audit log
  - **CRITICAL**: Log every interaction, not just approvals
- **Quality Focus**: Complex changes get full treatment, simple changes stay efficient
- **Content Validation**: Always validate content before file creation per content-validation.md rules
- **NO EMERGENT BEHAVIOR**: Construction phases MUST use standardized 2-option completion messages as defined in their respective rule files. DO NOT create 3-option menus or other emergent navigation patterns.

## MANDATORY: Plan-Level Checkbox Enforcement

### MANDATORY RULES FOR PLAN EXECUTION
1. **NEVER complete any work without updating plan checkboxes**
2. **IMMEDIATELY after completing ANY step described in a plan file, mark that step [x]**
3. **This must happen in the SAME interaction where the work is completed**
4. **NO EXCEPTIONS**: Every plan step completion MUST be tracked with checkbox updates

### Two-Level Checkbox Tracking System
- **Plan-Level**: Track detailed execution progress within each stage
- **Stage-Level**: Track overall workflow progress in aidlc-state.md
- **Update immediately**: All progress updates in SAME interaction where work is completed

## Prompts Logging Requirements
- **MANDATORY**: Log EVERY user input (prompts, questions, responses) with timestamp in audit.md
- **MANDATORY**: Capture user's COMPLETE RAW INPUT exactly as provided (never summarize)
- **MANDATORY**: Log every approval prompt with timestamp before asking the user
- **MANDATORY**: Record every user response with timestamp after receiving it
- **CRITICAL**: ALWAYS append changes to EDIT audit.md file, NEVER use tools and commands that completely overwrite its contents
- **CRITICAL**: Using file writing tools and commands that overwrite contents of the entire audit.md and cause duplication
- Use ISO 8601 format for timestamps (YYYY-MM-DDTHH:MM:SSZ)
- Include stage context for each entry

### Audit Log Format:
```markdown
## [Stage Name or Interaction Type]
**Timestamp**: [ISO timestamp]
**User Input**: "[Complete raw user input - never summarized]"
**AI Response**: "[AI's response or action taken]"
**Context**: [Stage, action, or decision made]

---
```

### Correct Tool Usage for audit.md

✅ CORRECT:

1. Read the audit.md file
2. Append/Edit the file to make changes

❌ WRONG:

1. Read the audit.md file
2. Completely overwrite the audit.md with the contents of what you read, plus the new changes you want to add to it

## Directory Structure

```text
aidlc-docs/
├── inception/                  # 🔵 INCEPTION PHASE artifacts
│   ├── plans/
│   │   ├── workspace-detection.md
│   │   ├── workflow-planning.md
│   │   ├── story-generation-plan.md
│   │   └── unit-of-work-plan.md
│   ├── reverse-engineering/        # Brownfield only
│   │   ├── architecture.md
│   │   ├── code-structure.md
│   │   ├── api-documentation.md
│   │   ├── component-inventory.md
│   │   ├── technology-stack.md
│   │   ├── dependencies.md
│   │   ├── code-quality-assessment.md
│   │   └── reverse-engineering-timestamp.md
│   ├── requirements/
│   │   ├── requirements.md
│   │   └── requirement-verification-questions.md
│   ├── user-stories/
│   │   ├── stories.md
│   │   └── personas.md
│   └── application-design/
│       ├── components.md
│       ├── component-methods.md
│       ├── services.md
│       ├── component-dependency.md
│       ├── unit-of-work.md
│       ├── unit-of-work-dependency.md
│       └── unit-of-work-story-map.md
├── construction/               # 🟢 CONSTRUCTION PHASE artifacts
│   ├── plans/
│   │   ├── {unit-name}-functional-design-plan.md
│   │   ├── {unit-name}-nfr-requirements-plan.md
│   │   ├── {unit-name}-nfr-design-plan.md
│   │   ├── {unit-name}-infrastructure-design-plan.md
│   │   └── {unit-name}-code-generation-plan.md
│   ├── {unit-name}/
│   │   ├── functional-design/
│   │   │   ├── business-logic-model.md
│   │   │   ├── business-rules.md
│   │   │   └── domain-entities.md
│   │   ├── nfr-requirements/
│   │   │   ├── nfr-requirements.md
│   │   │   └── tech-stack-decisions.md
│   │   ├── nfr-design/
│   │   │   ├── nfr-design-patterns.md
│   │   │   └── logical-components.md
│   │   ├── infrastructure-design/
│   │   │   ├── infrastructure-design.md
│   │   │   └── deployment-architecture.md
│   │   └── code/
│   │       └── [generated code files]
│   └── build-and-test/
│       ├── build-instructions.md
│       ├── unit-test-instructions.md
│       ├── integration-test-instructions.md
│       ├── performance-test-instructions.md
│       └── build-and-test-summary.md
├── operations/                 # 🟡 OPERATIONS PHASE artifacts (placeholder)
│   └── [Future: deployment and monitoring artifacts]
├── aidlc-state.md             # Dynamic state tracking
└── audit.md                    # Complete audit trail
```
