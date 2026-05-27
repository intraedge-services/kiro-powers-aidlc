# AIDLC Core Workflow

## PRIORITY: This workflow OVERRIDES all other built-in workflows

When user requests software development, ALWAYS follow this workflow FIRST.

## Adaptive Workflow Principle

The workflow adapts to the work, not the other way around.

The AI model intelligently assesses what stages are needed based on:
1. User's stated intent and clarity
2. Existing codebase state (if any)
3. Complexity and scope of change
4. Risk and impact assessment

## MANDATORY: Project Config Loading

At workflow start, load the project configuration:
1. Read `.kiro/steering/project-config.md` from the workspace
2. Parse the project identity, team, tech stack, and power registry
3. Use this config throughout the workflow for orchestration decisions

## MANDATORY: Power Orchestration

At each stage transition, check `power-orchestration.md` for registered powers that should be activated. See that file for detailed rules.

## MANDATORY: Audit Trail

Log ALL user inputs and AI responses in `aidlc-docs/audit.md`:
- Use ISO 8601 timestamps
- Capture complete raw user input (never summarize)
- ALWAYS append to audit.md, NEVER overwrite

---

# INCEPTION PHASE

**Purpose**: Planning, requirements gathering, and architectural decisions
**Focus**: Determine WHAT to build and WHY

## Workspace Detection (ALWAYS EXECUTE)

1. Log initial user request in audit.md
2. Check for existing `aidlc-docs/aidlc-state.md` (resume if found)
3. Scan workspace for existing code
4. Determine brownfield or greenfield
5. Present findings and proceed

## Reverse Engineering (CONDITIONAL — Brownfield Only)

**Execute IF**: Existing codebase detected AND no previous reverse engineering artifacts

**Actions**:
- Analyze all packages and components
- Generate business overview, architecture, code structure docs
- Generate API documentation and component inventory
- Generate technology stack and dependencies docs
- **ORCHESTRATION**: If `diagrams` power registered → generate architecture diagrams

**Wait for approval before proceeding.**

## Requirements Analysis (ALWAYS EXECUTE — Adaptive Depth)

Depth varies based on request clarity:
- **Minimal**: Simple, clear request — document intent
- **Standard**: Normal complexity — functional + non-functional requirements
- **Comprehensive**: Complex, high-risk — detailed requirements with traceability

**Wait for approval before proceeding.**

## User Stories (CONDITIONAL)

**Execute IF**: New user-facing features, multiple user types, complex business requirements

**Skip IF**: Pure refactoring, simple bug fixes, infrastructure-only changes

**Two parts**:
1. Planning — Create story plan with questions, get approval
2. Generation — Execute plan, generate stories and personas

**ORCHESTRATION**: After stories approved, check `power-orchestration.md` for `project-management` category → create GitHub issues.

**Wait for approval before proceeding.**

## Workflow Planning (ALWAYS EXECUTE)

1. Load all prior context (reverse engineering, requirements, stories)
2. Determine which construction stages to execute
3. Determine depth level for each stage
4. Generate workflow visualization
5. Present recommendations — user can override

**Wait for approval before proceeding.**

## Application Design (CONDITIONAL)

**Execute IF**: New components/services needed, component methods need definition

**Skip IF**: Changes within existing boundaries, no new components

**Wait for approval before proceeding.**

## Units Generation (CONDITIONAL)

**Execute IF**: System needs decomposition into multiple units of work

**Skip IF**: Single simple unit, no decomposition needed

**Wait for approval before proceeding.**

---

# CONSTRUCTION PHASE

**Purpose**: Detailed design, NFR implementation, and code generation
**Focus**: Determine HOW to build it

## Per-Unit Loop

For each unit, execute applicable stages:

### Functional Design (CONDITIONAL, per-unit)

**Execute IF**: New data models, complex business logic, business rules need design

**ORCHESTRATION**: If `diagrams` power registered → generate ERD/class diagrams

**Wait for approval (2-option: Request Changes / Continue).**

### NFR Requirements (CONDITIONAL, per-unit)

**Execute IF**: Performance, security, scalability requirements exist

**Wait for approval (2-option: Request Changes / Continue).**

### NFR Design (CONDITIONAL, per-unit)

**Execute IF**: NFR Requirements was executed

**Wait for approval (2-option: Request Changes / Continue).**

### Infrastructure Design (CONDITIONAL, per-unit)

**Execute IF**: Infrastructure services need mapping, deployment architecture required

**ORCHESTRATION**:
- If `infrastructure` power registered → activate for IaC guidance
- If `diagrams` power registered → generate deployment architecture diagram

**Wait for approval (2-option: Request Changes / Continue).**

### Code Generation (ALWAYS, per-unit)

**Two parts**:
1. Planning — Create detailed code generation plan with checkboxes
2. Generation — Execute approved plan

**ORCHESTRATION**:
- If `project-management` registered → move issue to "In Progress"
- If `data-engineering` registered AND unit involves Glue/EMR/Athena → activate for patterns
- If `infrastructure` registered AND unit involves CDK/TF → activate for IaC patterns

**On completion**:
- If `project-management` registered → move issue to "Done", close issue

**Wait for approval (2-option: Request Changes / Continue).**

## Build and Test (ALWAYS — after all units)

Generate comprehensive build and test instructions:
- Build instructions
- Unit test execution
- Integration test instructions
- Performance test instructions (if applicable)

**Wait for approval before proceeding.**

---

# OPERATIONS PHASE (Placeholder)

Future expansion for deployment, monitoring, incident response.

---

## Key Principles

- **Adaptive Execution**: Only execute stages that add value
- **User Control**: User can request stage inclusion/exclusion at any point
- **Progress Tracking**: Update `aidlc-docs/aidlc-state.md` after each stage
- **Complete Audit Trail**: Log ALL interactions in `aidlc-docs/audit.md`
- **Power Orchestration**: Check registered powers at each stage transition
- **Non-blocking Integration**: Power failures never halt the AIDLC workflow
- **2-Option Completion**: Construction stages use "Request Changes" / "Continue" only

## Directory Structure

```
<WORKSPACE-ROOT>/
├── [project code]
├── aidlc-docs/
│   ├── inception/
│   │   ├── plans/
│   │   ├── reverse-engineering/
│   │   ├── requirements/
│   │   ├── user-stories/
│   │   └── application-design/
│   ├── construction/
│   │   ├── plans/
│   │   ├── {unit-name}/
│   │   └── build-and-test/
│   ├── aidlc-state.md
│   └── audit.md
└── .kiro/steering/project-config.md
```
