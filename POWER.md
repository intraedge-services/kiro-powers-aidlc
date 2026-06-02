---
name: kiro-powers-aidlc
displayName: "AIDLC — AI-Driven Development Lifecycle + Power Orchestration"
description: "Complete AI-DLC methodology power with integrated project management orchestration. Includes the full adaptive workflow (Inception → Construction → Operations) plus automated GitHub board sync, multi-power coordination, and hooks for seamless team workflows."
keywords:
  - aidlc
  - ai-dlc
  - software development
  - workflow
  - lifecycle
  - requirements
  - user stories
  - code generation
  - project management
  - orchestrator
  - inception
  - construction
  - github
  - board sync
author: IntraEdge
---

# AIDLC — AI-Driven Development Lifecycle + Power Orchestration

## Overview

This power combines two things into one installable package:

1. **The official AI-DLC methodology** (from [aws-samples/sample-aidlc-kiro-power](https://github.com/aws-samples/sample-aidlc-kiro-power)) — the complete adaptive software development workflow with all stage rules
2. **Power orchestration add-ons** — automated GitHub board sync, multi-power coordination, and hooks that connect AIDLC stages to your project management tools

Once installed, saying "Using AI-DLC, build me X" activates the full workflow automatically. No manual file copying required.

## What You Get

### From the Official AI-DLC Methodology
- **Adaptive 3-phase workflow**: Inception → Construction → Operations
- **26 detailed workflow files** covering every stage (workspace detection, requirements, user stories, functional design, code generation, etc.)
- **Quality gates** at every stage with structured approval
- **Complete audit trail** of all decisions
- **Content validation** rules for generated artifacts

### From Our Orchestration Layer (the add-on)
- **Power orchestration** — Automatically activates GitHub, Data Engineering, Infrastructure, or Diagrams powers at the right AIDLC stage
- **GitHub board sync** — Stories become issues, status moves through Todo → In Progress → Done as work progresses
- **Hooks** — Automated triggers that fire at stage transitions
- **Project-config driven** — Per-project configuration via a single steering file

## Installation

### Option 1: Copy to your project (recommended for teams)

```bash
# Clone this repo
git clone https://github.com/intraedge-services/kiro-powers-aidlc.git /tmp/aidlc-power

# Copy into your project's .kiro/powers/ directory
mkdir -p .kiro/powers
cp -R /tmp/aidlc-power .kiro/powers/kiro-powers-aidlc

# Initialize workspace (copies hooks + project config template)
.kiro/powers/kiro-powers-aidlc/scripts/init-workspace.sh

# Clean up
rm -rf /tmp/aidlc-power
```

### Option 2: Reference as a Git submodule

```bash
mkdir -p .kiro/powers
git submodule add https://github.com/intraedge-services/kiro-powers-aidlc.git .kiro/powers/kiro-powers-aidlc

# Initialize workspace (copies hooks + project config template)
.kiro/powers/kiro-powers-aidlc/scripts/init-workspace.sh
```

### Post-Installation

Edit `.kiro/steering/project-config.md` with your project details (created by the init script).

## How It Works

### The AI-DLC Workflow

When you start a development request, the workflow guides you through:

**🔵 INCEPTION** (What to build & why)
1. Workspace Detection — Brownfield vs greenfield analysis
2. Reverse Engineering — Analyze existing code (brownfield only)
3. Requirements Analysis — Adaptive depth based on complexity
4. User Stories — Personas and acceptance criteria (conditional)
5. Workflow Planning — Execution plan with stage recommendations
6. Application Design — Component and service design (conditional)
7. Units Generation — Decompose into implementable units (conditional)

**🟢 CONSTRUCTION** (How to build it — per unit)
1. Functional Design — Business logic and data models (conditional)
2. NFR Requirements — Performance, security, scalability (conditional)
3. NFR Design — Patterns for NFR implementation (conditional)
4. Infrastructure Design — Cloud resource mapping (conditional)
5. Code Generation — Plan then generate (always)
6. Build and Test — Verification instructions (always)

**🟡 OPERATIONS** (Future — deployment & monitoring)

### Power Orchestration Points

| AIDLC Stage | Power Activated | What Happens |
|---|---|---|
| After User Stories | `project-management` | Create GitHub issues, add to board in "Todo" |
| Code Gen starts | `project-management` | Move issue to "In Progress" |
| Code Gen starts | `ci-cd` | Provide pipeline templates for new services |
| Code Gen completes | `project-management` | Move issue to "Done", close issue |
| Infrastructure Design | `infrastructure` | Activate IaC power for CDK/TF guidance |
| Infrastructure Design | `diagrams` | Generate deployment architecture diagrams |
| Build and Test | `ci-cd` | Validate CI configs, check pipeline status |
| Code Gen (data jobs) | `data-engineering` | Activate for Glue/EMR/Athena patterns |

## Available Steering Files

- `core-workflow.md` — Main workflow rules (always loaded)
- `power-orchestration.md` — When and how to activate registered powers
- `github-integration.md` — Spec-to-issues and board sync logic
- `project-config-template.md` — Template for per-project configuration

## Available Workflow Files

Loaded on-demand via `readFile` during workflow execution:

### Common
- `workflows/common/process-overview.md`
- `workflows/common/terminology.md`
- `workflows/common/content-validation.md`
- `workflows/common/question-format-guide.md`
- `workflows/common/session-continuity.md`
- `workflows/common/welcome-message.md`
- `workflows/common/depth-levels.md`
- `workflows/common/error-handling.md`
- `workflows/common/overconfidence-prevention.md`
- `workflows/common/workflow-changes.md`

### Inception
- `workflows/inception/workspace-detection.md`
- `workflows/inception/reverse-engineering.md`
- `workflows/inception/requirements-analysis.md`
- `workflows/inception/user-stories.md`
- `workflows/inception/workflow-planning.md`
- `workflows/inception/application-design.md`
- `workflows/inception/units-generation.md`

### Construction
- `workflows/construction/functional-design.md`
- `workflows/construction/nfr-requirements.md`
- `workflows/construction/nfr-design.md`
- `workflows/construction/infrastructure-design.md`
- `workflows/construction/code-generation.md`
- `workflows/construction/build-and-test.md`

### Operations
- `workflows/operations/operations.md`

## Hooks

| Hook | Trigger | Action |
|---|---|---|
| `spec-to-issues.json` | User-triggered | Creates GitHub issues from AIDLC user stories |
| `pre-code-gen.json` | preTaskExecution | Moves board item to "In Progress", activates relevant powers |
| `aidlc-board-sync.json` | postTaskExecution | Syncs board status after task completion |

## Configuration

No MCP servers required. This is a pure methodology + steering power.

All configuration is done via `.kiro/steering/project-config.md` in your workspace.

## Credits

- Core AI-DLC methodology: [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows) (MIT-0)
- Sample Kiro Power structure: [aws-samples/sample-aidlc-kiro-power](https://github.com/aws-samples/sample-aidlc-kiro-power) (MIT-0)
- Power orchestration & GitHub integration: [IntraEdge](https://github.com/intraedge-services)
