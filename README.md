# kiro-powers-aidlc

**AI-Driven Development Lifecycle + Power Orchestration** — a Kiro Power that combines the official AI-DLC methodology with automated GitHub sync, multi-power coordination, and zero-config setup.

## Quick Start (30 seconds)

```bash
# From your project root (must have a git remote):
git clone https://github.com/intraedge-services/kiro-powers-aidlc.git /tmp/aidlc
/tmp/aidlc/scripts/setup-aidlc.sh
rm -rf /tmp/aidlc
```

That's it. No questions asked — it auto-detects everything from your git remote, package files, and `gh` CLI.

Then open the project in Kiro and say:

> "Using AI-DLC, build me ..."

## What Gets Installed

After running the setup script, your project gets:

```
your-project/
├── .kiro/
│   ├── steering/              # Auto-loaded context for Kiro
│   │   ├── project-config.md  # Your project identity + preferences
│   │   ├── core-workflow.md   # Full AIDLC stage rules
│   │   ├── power-orchestration.md
│   │   └── github-integration.md
│   ├── hooks/                 # Automated triggers
│   │   ├── spec-to-issues.json     # Stories → GitHub issues
│   │   ├── aidlc-board-sync.json   # Close issues on completion
│   │   └── pre-code-gen.json       # Activate powers at stage transitions
│   └── aws-aidlc-rule-details/     # 24 workflow rule files
└── aidlc-docs/                # AIDLC artifacts (state, audit log)
```

## Team Setup

**One person runs setup. Everyone else just clones.**

```bash
# Person 1 (you):
/tmp/aidlc/scripts/setup-aidlc.sh
git add .kiro/ aidlc-docs/
git commit -m "chore: add AIDLC workflow config"
git push

# Person 2, 3, ... (teammates):
git clone git@github.com:your-org/your-repo.git
# Done. .kiro/ is already there. Open in Kiro and go.
```

To add team members, edit `.kiro/steering/project-config.md`:

```markdown
## Team

- **Lead**: your-username
- **Developers**: teammate1, teammate2
- **Reviewers**: teammate3
```

## Prerequisites

| Tool | Required? | Purpose |
|------|-----------|---------|
| Kiro IDE | Yes | AI-powered development environment |
| `gh` CLI | Recommended | GitHub issue sync ([install](https://cli.github.com/)) |
| Git remote | Recommended | Auto-detection of org/repo/branch |

Run `gh auth login` once for GitHub sync to work. If `gh` isn't available, the workflow still works — it just skips issue creation.

## Setup Script Options

The script auto-detects everything, but you can override:

```bash
# Override specific values:
./setup-aidlc.sh --board 7 --lead "username"

# Force interactive mode (asks all questions):
./setup-aidlc.sh --interactive

# All flags:
./setup-aidlc.sh --org NAME --repo NAME --board NUMBER --lead USER --lang LANGUAGE
```

### What Gets Auto-Detected

| Value | Source |
|-------|--------|
| GitHub Org | `git remote get-url origin` |
| GitHub Repo | `git remote get-url origin` |
| Default Branch | `git symbolic-ref` |
| Team Lead | `gh api user` (current authenticated user) |
| Project Board | `gh project list --owner ORG` (first board found) |
| Language | `package.json` → JS/TS, `pyproject.toml` → Python, `pom.xml` → Java, etc. |
| Framework | `cdk.json` → AWS CDK, `*.tf` → Terraform, etc. |

## GitHub Sync (via `gh` CLI)

No MCP power needed for GitHub integration. The workflow uses `gh` CLI directly:

| Event | What Happens |
|-------|-------------|
| User stories approved | Creates GitHub issues with `aidlc:story` label |
| Code generation starts | Comments on issue: "🔄 Code Generation Started" |
| Code generation approved | Closes issue: "✅ Complete" |

**Config required in `project-config.md`:**
```markdown
- **GitHub Org**: your-org
- **GitHub Repo**: your-repo
- **Project Board Number**: 7

## AIDLC Preferences
- **Auto-create Issues**: yes
- **Auto-sync Board**: yes
```

Set `Auto-create Issues: no` to disable sync entirely.

## Optional Powers

Register additional powers in `project-config.md` for enhanced validation:

```markdown
## Installed Powers Registry

| Category | Power Name | Activate During |
|----------|-----------|------------------|
| infrastructure | kiro-powers-aws-cdk-python | Infrastructure design, code gen |
| diagrams | kiro-powers-diagrams | Architecture docs |
| ci-cd | kiro-powers-circleci | Pipeline validation |
| data-engineering | kiro-powers-aws-data-engineering | Glue/EMR/Athena workloads |
```

**The workflow works fine with an empty powers table.** Powers add validation and best-practice guidance but never block progress. If a power isn't installed, the workflow warns and continues.

## The AIDLC Workflow

When you say "Using AI-DLC, build me X", the workflow guides you through:

**Inception** (What to build)
1. Workspace Detection → brownfield vs greenfield
2. Requirements Analysis → adaptive depth
3. User Stories → personas + acceptance criteria
4. Workflow Planning → which stages to execute

**Construction** (How to build it)
5. Functional Design → business logic, domain entities
6. Infrastructure Design → cloud resources
7. Code Generation → plan then implement
8. Build and Test → verification instructions

Each stage has quality gates — you approve before moving forward.

## Extensions

Opt-in rule sets that enforce constraints during construction:

| Extension | What It Enforces |
|-----------|-----------------|
| security-baseline | OWASP input validation, auth, secrets, encryption |
| property-based-testing | Hypothesis/fast-check test generation |
| resiliency-baseline | AWS Well-Architected reliability patterns |

Extensions are presented during Requirements Analysis. You choose which to enable.

## Explore & Analyze Modes

Two thinking-partner modes available anytime:

- **Analyze** (`/aidlc:analyze`) — Deep-dive before starting. Understand domain, constraints, risks.
- **Explore** (`/aidlc:explore`) — Mid-workflow investigation. Compare approaches, clarify decisions.

## Project Structure

```
kiro-powers-aidlc/
├── scripts/
│   └── setup-aidlc.sh           # Zero-prompt bootstrap
├── steering/                     # Loaded by Kiro as context
├── workflows/                    # 24 rule-detail files
│   ├── common/                   # Shared rules (10 files)
│   ├── inception/                # Planning stages (7 files)
│   ├── construction/             # Build stages (6 files)
│   └── extensions/               # Opt-in blocking rules
├── hooks/                        # Automated triggers (3 files)
├── templates/
│   └── project-config.md        # Template for manual setup
├── POWER.md                      # Power manifest
└── package.json
```

## Credits

- Core AI-DLC methodology: [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows) (MIT-0)
- Sample Kiro Power: [aws-samples/sample-aidlc-kiro-power](https://github.com/aws-samples/sample-aidlc-kiro-power) (MIT-0)
- Power orchestration & GitHub integration: [IntraEdge](https://github.com/intraedge-services)

## License

MIT
