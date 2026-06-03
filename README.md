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
| GitHub issue creation from stories | ❌ | ✅ |
| Project board sync (Todo → In Progress → Done) | ❌ | ✅ |
| Auto-activate Data Engineering power | ❌ | ✅ |
| Auto-activate Infrastructure power | ❌ | ✅ |
| Auto-activate Diagrams power | ❌ | ✅ |
| Per-project config via steering | ❌ | ✅ |
| Hooks for stage transitions | ❌ | ✅ |
| Auto-activate CI/CD power (CircleCI) | ❌ | ✅ |

## Prerequisites

**Required:**
- Kiro IDE with Powers support

**Recommended:**
- [kiro-powers-github](https://github.com/intraedge-services/kiro-powers-github) — for issue creation and board sync
- A `.kiro/steering/project-config.md` in your workspace (see `templates/project-config.md`)

**Optional (activated automatically when registered):**
- `kiro-powers-aws-data-engineering` — Glue/EMR/Athena patterns during code generation
- `aws-infrastructure-as-code` — CDK/Terraform/CloudFormation guidance during infrastructure design
- `kiro-powers-diagrams` — Architecture and component diagrams
- `kiro-powers-circleci` — CI/CD pipeline validation and templates during build & test

## Installation

### Option 1: Install from GitHub URL (recommended)

Kiro supports installing custom powers directly from a public GitHub URL:

1. Open the **Powers panel** → click **"Add power from GitHub"**
2. Enter the repository URL: `https://github.com/intraedge-services/kiro-powers-aidlc`
3. Click **Install**

That's it — Kiro handles the rest. The power will be available immediately.

### Option 2: Copy to your project (for teams needing local control)

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

### Option 3: Git submodule

```bash
mkdir -p .kiro/powers
git submodule add https://github.com/intraedge-services/kiro-powers-aidlc.git .kiro/powers/kiro-powers-aidlc

# Initialize workspace (copies hooks + project config template)
.kiro/powers/kiro-powers-aidlc/scripts/init-workspace.sh
```

### Post-Installation: Initialize your workspace

Edit `.kiro/steering/project-config.md` with your project's details (GitHub org, repo, board number, team, tech stack, and which powers you have installed).

See `examples/` for a real-world example.

## Usage

Once installed, start any development request and the AI-DLC workflow activates automatically. Say something like:

> "Using AI-DLC, build me a data ingestion pipeline for CSV files"

The workflow will:
1. Detect your workspace (greenfield vs brownfield)
2. Gather requirements with adaptive depth
3. Plan which stages to execute
4. Guide you through design and implementation
5. Sync progress to your GitHub board (if configured)

### Manual Triggers

The `spec-to-issues` hook is user-triggered — after AIDLC generates user stories and you approve them, trigger it manually to create GitHub issues from the stories.

### Automatic Triggers

- `pre-code-gen` fires before each task execution to move board items and activate relevant powers
- `aidlc-board-sync` fires after task completion to update board status

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  kiro-powers-aidlc                        │
│              (Orchestrator Power)                         │
├─────────────────────────────────────────────────────────┤
│  Steering:                                               │
│  • core-workflow.md          → Full AIDLC stage rules    │
│  • power-orchestration.md   → When to call other powers  │
│  • github-integration.md    → Spec→Issues, board sync    │
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
│ GitHub   │ Data Eng │ Infra (IaC)  │ Diagrams │ CircleCI│
│ Power    │ Power    │ Power        │ Power    │ Power   │
└──────────┴──────────┴──────────────┴──────────┴─────────┘
```

## Directory Structure

```
kiro-powers-aidlc/
├── POWER.md                          # Power manifest & documentation
├── package.json                      # Power metadata (v2.0.0)
├── LICENSE                           # MIT
├── README.md                         # This file
├── scripts/
│   └── init-workspace.sh            # Run after install to set up workspace
├── steering/
│   ├── core-workflow.md              # Full AIDLC workflow rules
│   ├── power-orchestration.md        # Multi-power coordination
│   ├── github-integration.md         # GitHub issue/board integration
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

## Credits

- Core AI-DLC methodology: [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows) (MIT-0)
- Sample Kiro Power structure: [aws-samples/sample-aidlc-kiro-power](https://github.com/aws-samples/sample-aidlc-kiro-power) (MIT-0)
- Power orchestration & GitHub integration: [IntraEdge](https://github.com/intraedge-services)

## License

MIT — see [LICENSE](LICENSE)
