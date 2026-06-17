# kiro-powers-aidlc

**AI-Driven Development Lifecycle + Power Orchestration** — a complete Kiro Power that combines the official AI-DLC methodology with automated project management, multi-power coordination, and GitHub board sync.

## What This Is

This power packages two things into one installable unit:

1. **The full official AI-DLC methodology** — the complete adaptive software development workflow from [aws-samples/sample-aidlc-kiro-power](https://github.com/aws-samples/sample-aidlc-kiro-power), including all 24 workflow files across Inception, Construction, and Operations phases.

2. **Power orchestration add-ons** — automated GitHub issue creation from specs, board status sync as work progresses, and intelligent activation of other installed powers (Data Engineering, Infrastructure, Diagrams) at the right AIDLC stage.

## How It Differs from Vanilla AI-DLC

| Feature | Official AI-DLC | This Power |
|---------|----------------|------------|
| Adaptive 3-phase workflow | ✅ | ✅ |
| Quality gates & approvals | ✅ | ✅ |
| Full audit trail | ✅ | ✅ |
| Content validation | ✅ | ✅ |
| Pre-workflow analysis mode (`/aidlc:analyze`) | ❌ | ✅ |
| In-workflow explore mode (`/aidlc:explore`) | ❌ | ✅ |
| GitHub issue creation from stories | ❌ | ✅ |
| Project board sync (Todo → In Progress → Done) | ❌ | ✅ |
| Auto-activate Data Engineering power | ❌ | ✅ |
| Auto-activate Infrastructure power (AWS CDK Python) | ❌ | ✅ |
| Auto-activate Diagrams power | ❌ | ✅ |
| Per-project config via steering | ❌ | ✅ |
| Hooks for stage transitions | ❌ | ✅ |
| Auto-activate CI/CD power (CircleCI) | ❌ | ✅ |
| Python quality gates (testing, linting, security) | ❌ | ✅ |
| Extension framework (opt-in blocking rules) | ✅ | ✅ |
| Built-in extensions (security, testing, resiliency) | ✅ | ✅ |
| Custom extension support | ✅ | ✅ |

## Prerequisites

**Required:**
- Kiro IDE with Powers support

**Recommended:**
- [kiro-powers-github](https://github.com/intraedge-services/kiro-powers-github) — for issue creation and board sync
- A `.kiro/steering/project-config.md` in your workspace (see `templates/project-config.md`)

**Optional (activated automatically when registered):**
- `kiro-powers-aws-data-engineering` — Glue/EMR/Athena patterns during code generation
- `kiro-powers-aws-cdk-python` ([kiro-powers-aws-iaac](https://github.com/intraedge-services/kiro-powers-aws-iaac)) — CDK/Python infrastructure guidance, template validation, compliance checks during infrastructure design and code generation
- `kiro-powers-diagrams` — Architecture and component diagrams
- `kiro-powers-circleci` — CI/CD pipeline validation and templates during build & test

## Installation

### Quick Start (Recommended — Interactive Setup)

```bash
# Clone the power
git clone https://github.com/intraedge-services/kiro-powers-aidlc.git /tmp/aidlc-power

# Run the interactive bootstrap from your project root
cd /path/to/your-project
/tmp/aidlc-power/scripts/setup-aidlc.sh
```

The `setup-aidlc.sh` utility handles everything:
- **Detects** if AIDLC is already configured (offers repair/re-run/exit)
- **Prompts** for project identity, team, tech stack, powers, and extensions
- **Generates** a fully populated `project-config.md` (no placeholder editing needed)
- **Creates** the complete `.kiro/` and `aidlc-docs/` folder structure
- **Installs** steering files, workflow rule-details, and hooks

### Option 1: Copy to your project (for teams)

```bash
git clone https://github.com/intraedge-services/kiro-powers-aidlc.git /tmp/aidlc-power
mkdir -p .kiro/powers
cp -R /tmp/aidlc-power .kiro/powers/kiro-powers-aidlc

# Run interactive setup
.kiro/powers/kiro-powers-aidlc/scripts/setup-aidlc.sh

rm -rf /tmp/aidlc-power
```

### Option 2: Git submodule

```bash
mkdir -p .kiro/powers
git submodule add https://github.com/intraedge-services/kiro-powers-aidlc.git .kiro/powers/kiro-powers-aidlc

# Run interactive setup
.kiro/powers/kiro-powers-aidlc/scripts/setup-aidlc.sh
```

### Legacy: Non-Interactive Install

For CI/automation where interactive prompts aren't available:

```bash
.kiro/powers/kiro-powers-aidlc/scripts/init-workspace.sh
# Then manually edit .kiro/steering/project-config.md
```

## Usage

Once installed, start any development request and the AI-DLC workflow activates automatically. Say something like:

> "Using AI-DLC, build me a data ingestion pipeline for CSV files"

The workflow will:
1. Display the welcome message
2. **Offer optional project analysis** — explore requirements, domain, and constraints before building
3. Detect your workspace (greenfield vs brownfield)
4. Gather requirements with adaptive depth
5. Plan which stages to execute
6. Guide you through design and implementation
7. Sync progress to your GitHub board (if configured)

### Explore & Analyze Modes

The power includes two thinking-partner modes that can be invoked at any time:

| Mode | Command | Purpose |
|------|---------|---------|
| **Analyze** | `/aidlc:analyze` | Pre-workflow deep-dive into project requirements, domain, and constraints. Offered automatically before the AIDLC cycle begins. |
| **Explore** | `/aidlc:explore` | In-workflow thinking partner for investigating problems, comparing approaches, or clarifying decisions during or between AIDLC phases. |

**Analysis mode** (`/aidlc:analyze`) is an optional pre-workflow step that helps you:
- Understand the problem domain deeply
- Clarify requirements and scope before committing
- Investigate technical constraints and landscape
- Compare architectural approaches
- Surface risks and unknowns

When you start the AIDLC workflow, you'll be asked:
> 🔬 **Yes, analyze first** — Enter analysis mode to explore the project landscape  
> 🚀 **No, proceed directly** — Start the AIDLC workflow immediately

**Explore mode** (`/aidlc:explore`) can be used anytime during the lifecycle:
- Stuck between phases? Explore to clarify the next step
- Rethinking a decision mid-construction? Explore alternatives
- Unsure if a phase should be included? Think it through
- Want to compare technology options? Brainstorm visually

Both modes are for **thinking, not implementing** — they use ASCII diagrams, investigate the codebase, and help map the landscape without writing application code.

### Manual Triggers

The `spec-to-issues` hook is user-triggered — after AIDLC generates user stories and you approve them, trigger it manually to create GitHub issues from the stories.

### Automatic Triggers

- `pre-code-gen` fires before each task execution to move board items and activate relevant powers
- `aidlc-board-sync` fires after task completion to update board status

## Python Quality Gates

When working on Python projects, the power automatically enforces quality gates during Code Generation and Build & Test stages. This is activated conditionally — only when `*.py` files are in context.

| Gate | Tool | What It Enforces |
|------|------|-----------------|
| Unit Testing | pytest + pytest-cov | Test structure, fixtures, 80% coverage minimum |
| Linting & Formatting | Ruff | Style, imports, naming, auto-fix, consistent formatting |
| Security — Static | Bandit | SQL injection, hardcoded secrets, insecure API usage |
| Security — Dependencies | pip-audit | Known CVEs in installed packages |
| Type Checking | mypy | Type annotations, strict mode for new code |

The steering file also provides:
- `pyproject.toml` configuration blocks ready to paste
- CI pipeline template snippet for quality gate jobs
- Pre-commit hook configuration
- Dev dependency list
- Failure policy (what blocks vs. what warns)

See `steering/python-quality-gates.md` for full details.

## AWS CDK Python Infrastructure Power

When working with AWS infrastructure using Python CDK, the orchestrator automatically integrates the [kiro-powers-aws-iaac](https://github.com/intraedge-services/kiro-powers-aws-iaac) power. This power wraps the official `awslabs.aws-iac-mcp-server` and provides Python CDK-specific tools, validation, and best practices.

### What It Provides

| Capability | Description |
|------------|-------------|
| 9 MCP Tools | CDK docs search, Python code samples, best practices, cfn-lint validation, cfn-guard compliance, deployment troubleshooting |
| Python CDK Steering | Conventions, project structure, construct patterns, anti-patterns |
| Validation Workflow | synth → cfn-lint → cfn-guard → deploy pipeline |
| Security Checklist | IAM, encryption, network, data protection, CDK-NAG integration |
| Project Template | Production-ready scaffold with cdk-nag, pytest, multi-env config |

### Available Tools (via awslabs.aws-iac-mcp-server)

| Tool | Purpose | Credentials |
|------|---------|-------------|
| `search_cdk_documentation` | Search CDK API Reference, Best Practices, CDK-NAG rules | No |
| `search_cdk_samples_and_constructs` | Find Python CDK code samples and constructs | No |
| `cdk_best_practices` | Get comprehensive CDK best practices guide | No |
| `search_cloudformation_documentation` | Search CloudFormation resource types and properties | No |
| `validate_cloudformation_template` | Validate template syntax/schema via cfn-lint | No |
| `check_cloudformation_template_compliance` | Security compliance check via cfn-guard | No |
| `read_iac_documentation_page` | Read full AWS documentation pages | No |
| `get_cloudformation_pre_deploy_validation_instructions` | Pre-deployment change set guidance | No |
| `troubleshoot_cloudformation_deployment` | Analyze failed stack deployments with CloudTrail | Yes |

### When the Orchestrator Activates It

| AIDLC Stage | What Happens |
|---|---|
| Infrastructure Design | Searches CDK docs and samples; provides best practices; validates templates with cfn-lint and cfn-guard |
| Code Generation (CDK units) | Finds Python CDK reference implementations; validates generated constructs against best practices |
| Build and Test | Validates synthesized templates; checks compliance; provides pre-deployment validation instructions |

### Registration

Add to your `.kiro/steering/project-config.md` Installed Powers Registry:

```
| infrastructure | kiro-powers-aws-cdk-python | Infrastructure design, CDK/Python code generation, template validation |
```

### Prerequisites

| Prerequisite | Purpose | Install |
|---|---|---|
| `uv` | Runs the MCP server via `uvx` | https://docs.astral.sh/uv/getting-started/installation/ |
| Python 3.10+ | CDK application code | `uv python install 3.10` |
| AWS CDK CLI | Synthesize and deploy stacks | `npm install -g aws-cdk` |
| AWS Credentials | Only for troubleshooting failed stacks | `aws configure` |

### Installing the Power

```bash
# Clone the AWS IaC power
git clone https://github.com/intraedge-services/kiro-powers-aws-iaac.git

# Add to Kiro IDE → Powers panel → "Add power from Local Path"
# Or copy into your project:
cp -R kiro-powers-aws-iaac .kiro/powers/kiro-powers-aws-cdk-python
```

Once installed and registered, the AIDLC orchestrator activates it automatically at the right stages — no manual intervention needed.

## Extensions Framework

AI-DLC supports an extension system that layers additional blocking rules on top of the core workflow. Extensions are opt-in during Requirements Analysis.

### How It Works

1. At workflow start, the agent scans `workflows/extensions/` for `*.opt-in.md` files
2. During Requirements Analysis, opt-in questions are presented to the user
3. When opted in, the extension's rules become **blocking constraints** — verified at each construction stage
4. If verification fails, the stage cannot complete until the issue is resolved or explicitly waived

### Built-in Extensions

| Extension | Category | Rules | Description |
|-----------|----------|-------|-------------|
| `security-baseline` | security | SEC-01 through SEC-08 | Input validation, auth, secrets, encryption, logging, dependencies, error handling |
| `property-based-testing` | testing | TEST-01 through TEST-05 | Property identification, input generation, shrinking, coverage targets, CI integration |
| `resiliency-baseline` | resiliency | RES-01 through RES-10 | Availability targets, failure modes, retries, graceful degradation, health checks, observability, data durability, capacity planning, deployment safety, blast radius |

### Adding Custom Extensions

Create a directory under `workflows/extensions/<category>/<name>/` with:
- `<name>.md` — Rules file with `## Rule PREFIX-NN: Title` + Rule + Verification sections
- `<name>.opt-in.md` — User prompt for Requirements Analysis (omit for always-enforced)

See `workflows/extensions/README.md` for the full specification.

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  kiro-powers-aidlc                        │
│              (Orchestrator Power)                         │
├─────────────────────────────────────────────────────────┤
│  Skills & Prompts:                                       │
│  • aidlc-analyze             → Pre-workflow analysis     │
│  • aidlc-explore             → In-workflow exploration   │
│                                                          │
│  Steering:                                               │
│  • core-workflow.md          → Full AIDLC stage rules    │
│  • power-orchestration.md   → When to call other powers  │
│  • github-integration.md    → Spec→Issues, board sync    │
│  • python-quality-gates.md  → Python testing/lint/sec    │
│  • project-config-template  → Setup guide                │
│                                                          │
│  Workflows (24 files):                                   │
│  • common/     (10 files)   → Shared rules & templates   │
│  • inception/  (7 files)    → Planning & architecture    │
│  • construction/ (6 files)  → Design & implementation    │
│  • operations/ (1 file)     → Deployment (placeholder)   │
│                                                          │
│  Hooks:                                                  │
│  • spec-to-issues.json      → Manual: stories → issues   │
│  • pre-code-gen.json        → Auto: activate powers      │
│  • aidlc-board-sync.json    → Auto: sync board status    │
├─────────────────────────────────────────────────────────┤
│                    Orchestrates                           │
├──────────┬──────────┬──────────────┬──────────┬─────────┤
│ GitHub   │ Data Eng │ AWS CDK      │ Diagrams │ CircleCI│
│ Power    │ Power    │ Python Power │ Power    │ Power   │
└──────────┴──────────┴──────────────┴──────────┴─────────┘
```

## Directory Structure

```
kiro-powers-aidlc/
├── POWER.md                          # Power manifest & documentation
├── package.json                      # Power metadata (v2.0.0)
├── LICENSE                           # MIT
├── README.md                         # This file
├── .kiro/
│   ├── prompts/
│   │   ├── aidlc-analyze.prompt.md   # Pre-workflow analysis prompt
│   │   └── aidlc-explore.prompt.md   # In-workflow explore prompt
│   └── skills/
│       ├── aidlc-analyze/SKILL.md    # Analysis mode skill (optional pre-step)
│       └── aidlc-explore/SKILL.md    # Explore mode skill (during workflow)
├── scripts/
│   ├── setup-aidlc.sh               # Interactive bootstrap/setup utility (recommended)
│   └── init-workspace.sh            # Legacy non-interactive setup (for CI/automation)
├── steering/
│   ├── core-workflow.md              # Full AIDLC workflow rules
│   ├── power-orchestration.md        # Multi-power coordination
│   ├── github-integration.md         # GitHub issue/board integration
│   ├── python-quality-gates.md       # Python: pytest, ruff, bandit, pip-audit, mypy
│   └── project-config-template.md    # Config setup guide
├── workflows/
│   ├── common/                       # Shared workflow rules
│   │   ├── process-overview.md
│   │   ├── terminology.md
│   │   ├── content-validation.md
│   │   ├── question-format-guide.md
│   │   ├── session-continuity.md
│   │   ├── welcome-message.md
│   │   ├── depth-levels.md
│   │   ├── error-handling.md
│   │   ├── overconfidence-prevention.md
│   │   └── workflow-changes.md
│   ├── extensions/                   # Opt-in blocking rule extensions
│   │   ├── README.md
│   │   ├── security/baseline/
│   │   │   ├── security-baseline.md
│   │   │   └── security-baseline.opt-in.md
│   │   ├── testing/property-based/
│   │   │   ├── property-based-testing.md
│   │   │   └── property-based-testing.opt-in.md
│   │   └── resiliency/baseline/
│   │       ├── resiliency-baseline.md
│   │       └── resiliency-baseline.opt-in.md
│   ├── inception/                    # Planning & architecture
│   │   ├── workspace-detection.md
│   │   ├── reverse-engineering.md
│   │   ├── requirements-analysis.md
│   │   ├── user-stories.md
│   │   ├── workflow-planning.md
│   │   ├── application-design.md
│   │   └── units-generation.md
│   ├── construction/                 # Design & implementation
│   │   ├── functional-design.md
│   │   ├── nfr-requirements.md
│   │   ├── nfr-design.md
│   │   ├── infrastructure-design.md
│   │   ├── code-generation.md
│   │   └── build-and-test.md
│   └── operations/                   # Deployment (placeholder)
│       └── operations.md
├── hooks/
│   ├── spec-to-issues.json
│   ├── pre-code-gen.json
│   └── aidlc-board-sync.json
├── templates/
│   └── project-config.md            # Copy to .kiro/steering/
└── examples/
    └── sample-project-config.md      # Real-world example config
```

## Configuration

This is a pure methodology + steering power. No MCP servers required.

All project-specific configuration lives in `.kiro/steering/project-config.md` in your workspace. The power reads this at workflow start to determine which powers to orchestrate and where to sync issues.

## Power Orchestration Behavior

### How it works

At the start of every AIDLC workflow, the model reads your `.kiro/steering/project-config.md` and parses the **Installed Powers Registry** table. At each AIDLC stage transition, it checks which registered powers need to be activated and uses their tools for guidance, validation, and compliance.

### When powers are NOT configured or NOT installed

| Situation | Behavior | Impact on Workflow |
|-----------|----------|--------------------|
| **Row removed from project-config** (you don't use that category) | Skip silently. No warning, no error. | AIDLC runs normally. Code is generated using the model's own knowledge without external validation. |
| **Row exists but power NOT installed in Kiro** | Warns: "⚠️ Power '{name}' is registered but not installed. Proceeding without it." | AIDLC continues without that power's validation/guidance. User is nudged to install. |
| **Row exists, power installed, but activation fails** (MCP error, timeout) | Retries once. If still fails, warns and continues. | Non-blocking. That specific validation step is skipped. |
| **No project-config.md file at all** | All power orchestration skipped silently. | AIDLC runs as a pure methodology with no power integrations. |

### Key principle

**The AIDLC workflow is always completable regardless of which powers are installed.** Powers enhance quality (validation, compliance checks, best practices, diagrams) but never block progress. The workflow degrades gracefully:

- No `diagrams` power → no architecture diagrams generated, design documents are text-only
- No `infrastructure` power → CDK/Terraform code generated from model knowledge without cfn-lint/cfn-guard validation
- No `data-engineering` power → Glue/EMR/Athena code generated without AWS-specific pattern libraries
- No `project-management` power → no GitHub issues created, no board sync
- No `ci-cd` power → no pipeline validation, CI configs generated without tool-based verification

### Recommendations for production use

For production projects, we strongly recommend installing all powers you register:

| Category | Why It Matters |
|----------|---------------|
| `infrastructure` | Catches security misconfigurations, validates templates before deployment, ensures CDK best practices |
| `ci-cd` | Validates pipeline syntax, prevents broken deployments |
| `project-management` | Keeps team visibility into progress, auto-syncs work status |
| `diagrams` | Produces visual documentation that aids code review and onboarding |
| `data-engineering` | Provides AWS-specific patterns that reduce Glue/EMR debugging time |

### What to do if you don't need a power

Simply **remove the row** from the Installed Powers Registry table in your `project-config.md`. Don't leave placeholder rows — if the row exists, the workflow treats it as mandatory to activate.

```markdown
## Minimal example (only GitHub + CDK):

| Category | Power Name | Activate During |
|----------|-----------|------------------|
| project-management | kiro-powers-github | After user stories, board sync |
| infrastructure | kiro-powers-aws-cdk-python | Infrastructure design, code generation |
```

### Clarification: When does data-engineering power trigger?

The `data-engineering` power only activates for **AWS data processing services** (Glue, EMR, Athena, Spark on EMR). It does NOT trigger for:
- General Python ML code (scikit-learn, pandas, numpy, PyTorch)
- Local data processing scripts
- Non-AWS data pipelines

This is intentional — the power provides AWS-specific tools that are irrelevant for general Python work.

## Credits

- Core AI-DLC methodology: [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows) (MIT-0)
- Sample Kiro Power structure: [aws-samples/sample-aidlc-kiro-power](https://github.com/aws-samples/sample-aidlc-kiro-power) (MIT-0)
- Power orchestration & GitHub integration: [IntraEdge](https://github.com/intraedge-services)

## License

MIT — see [LICENSE](LICENSE)
