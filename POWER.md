# AIDLC Power — Adaptive AI Development Lifecycle

An orchestrator power for Kiro that provides a structured, adaptive software development workflow with integrated project management, infrastructure, and documentation capabilities.

## What This Power Does

AIDLC (Adaptive AI Development Lifecycle) guides AI-assisted software development through structured phases while orchestrating other installed powers at the right moments:

- **Inception Phase** — Requirements, user stories, architecture decisions
- **Construction Phase** — Functional design, infrastructure design, code generation, testing
- **Operations Phase** — Deployment, monitoring (future)

## Key Features

- **Adaptive Workflow** — Stages execute only when they add value. Simple changes skip unnecessary ceremony.
- **Power Orchestration** — Automatically activates GitHub, Data Engineering, Diagrams, or Infrastructure powers at the right AIDLC stage based on your project config.
- **Project Management Integration** — AIDLC stories become GitHub issues on your project board, with status synced as work progresses.
- **Audit Trail** — Every decision, approval, and user input is logged with timestamps.
- **Reusable Across Projects** — One power installation, per-project config via `project-config.md`.

## Quick Start

### 1. Install dependent powers

Install the powers you need for your project:
- `kiro-powers-github` — Project management, issues, PRs
- `kiro-powers-aws-data-engineering` — Glue, EMR, Athena patterns (if applicable)
- `aws-infrastructure-as-code` — CDK, CloudFormation, Terraform (if applicable)
- `kiro-powers-diagrams` — Architecture diagrams (if applicable)

### 2. Add project config

Create `.kiro/steering/project-config.md` in your repo (see `templates/project-config.md` for the template).

### 3. Start working

Just tell Kiro what you want to build. The AIDLC workflow activates automatically based on the steering rules.

## Power Orchestration Points

| AIDLC Stage | Category Activated | What Happens |
|-------------|-------------------|--------------|
| After User Stories | `project-management` | Create GitHub issues, add to board in "Todo" |
| Code Gen starts | `project-management` | Move issue to "In Progress" |
| Code Gen completes | `project-management` | Move issue to "Done", close issue |
| Infrastructure Design | `infrastructure` | Activate IaC power for CDK/TF guidance |
| Infrastructure Design | `diagrams` | Generate deployment architecture diagrams |
| Reverse Engineering | `diagrams` | Generate architecture diagrams from analysis |
| Code Gen (data jobs) | `data-engineering` | Activate for Glue/EMR/Athena patterns |

## Adding New Powers

To integrate a new power with AIDLC:
1. Install the power in Kiro
2. Add a row to the "Installed Powers Registry" table in your `project-config.md`
3. Specify which AIDLC stages should activate it

No changes to this power are needed.

## Steering Files

- `aidlc-core-workflow.md` — Main workflow orchestration rules
- `power-orchestration.md` — When and how to activate registered powers
- `github-integration.md` — Spec-to-issues and board sync logic
- `project-config-template.md` — Template for per-project configuration
