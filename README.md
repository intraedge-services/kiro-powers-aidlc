# kiro-powers-aidlc

**AI-Driven Development Lifecycle + Power Orchestration** — a Kiro Power that combines the official AI-DLC methodology with automated GitHub sync, multi-power coordination, security extensions, traceability enforcement, and zero-config setup.

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
│   │   ├── git-signing.md    # Commit signing enforcement
│   │   ├── power-orchestration.md
│   │   └── github-integration.md
│   ├── hooks/                 # Automated triggers
│   │   ├── spec-to-issues.json     # Stories → GitHub issues
│   │   ├── aidlc-board-sync.json   # Close issues on completion
│   │   ├── pr-review-check.json    # PR review validation
│   │   └── pre-code-gen.json       # Activate powers at stage transitions
│   └── aws-aidlc-rule-details/     # Workflow rule files + extensions
├── aidlc-docs/                # AIDLC artifacts (state, audit log)
└── .aidlc-version             # Installed power version (for upgrades)
```

## Upgrade Detection

The setup script is safe to re-run:

```bash
# Already installed and current:
$ ./setup-aidlc.sh
✓ AIDLC already up to date (v1.1.0)

# Installed but outdated:
$ ./setup-aidlc.sh
  Installed: v1.0.0
  Available: v1.1.0
  Upgrade from v1.0.0 to v1.1.0? (y/n):

# Skip prompt:
$ ./setup-aidlc.sh --force
```

Existing steering files are never silently overwritten — backups are created if content differs.

## Team Setup

**One person runs setup. Everyone else just clones.**

```bash
# Person 1 (you):
/tmp/aidlc/scripts/setup-aidlc.sh
git add .kiro/ aidlc-docs/ .aidlc-version
git commit -S -m "chore: add AIDLC workflow config"
git push

# Person 2, 3, ... (teammates):
git clone git@github.com:your-org/your-repo.git
# Done. .kiro/ is already there. Open in Kiro and go.
```

## Prerequisites

| Tool | Required? | Purpose |
|------|-----------|---------|
| Kiro IDE | Yes | AI-powered development environment |
| `gh` CLI | Recommended | GitHub issue sync ([install](https://cli.github.com/)) |
| Git remote | Recommended | Auto-detection of org/repo/branch |
| GPG key | Recommended | Commit signing ([setup guide](https://docs.github.com/en/authentication/managing-commit-signature-verification)) |

Run `gh auth login` once for GitHub sync to work. If `gh` isn't available, the workflow still works — it just skips issue creation.

## Setup Script Options

```bash
# Override specific values:
./setup-aidlc.sh --board 7 --lead "username"

# Force interactive mode:
./setup-aidlc.sh --interactive

# Skip upgrade prompt:
./setup-aidlc.sh --force

# All flags:
./setup-aidlc.sh --org NAME --repo NAME --board NUMBER --lead USER --lang LANGUAGE --force
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
| GPG Signing | `git config --get user.signingkey` |

### Windows / WSL Compatibility

Every platform-specific command in the setup script includes inline comments with Windows equivalents:

```bash
# Mac/Linux:
brew install gh

# Windows (WSL): sudo apt install gh
# Windows (native): winget install GitHub.cli
```

## The AIDLC Workflow

When you say "Using AI-DLC, build me X", the workflow guides you through:

### Inception Phase (What to build)

| Stage | Always? | Purpose |
|-------|---------|---------|
| Workspace Detection | Yes | Brownfield vs greenfield, feature slug confirmation |
| Reverse Engineering | Brownfield only | Architecture docs, component inventory |
| Requirements Analysis | Yes | Adaptive depth based on complexity |
| User Stories | Conditional | Personas + acceptance criteria |
| Application Design | Conditional | Components, services, dependencies |
| Units Generation | Conditional | Decomposition for complex systems |
| Workflow Planning | Yes | Which stages to execute |

### Construction Phase (How to build it)

| Stage | Always? | Purpose |
|-------|---------|---------|
| Functional Design | Conditional | Business logic, domain entities, rules |
| NFR Requirements | Conditional | Performance, security, scalability |
| NFR Design | Conditional | Patterns for non-functional requirements |
| Infrastructure Design | Conditional | Cloud resources, deployment architecture |
| Code Generation | Yes | Plan → implement → verify |
| Build and Test | Yes | Verification instructions |

Each stage has quality gates — you approve before moving forward.

## Feature-Scoped Traceability

Every AIDLC cycle creates a feature-scoped directory. Previous artifacts are never overwritten:

```
aidlc-docs/
├── setup-aidlc/               # Feature 1
│   ├── inception/
│   └── construction/
├── user-auth/                 # Feature 2
│   ├── inception/
│   └── construction/
├── aidlc-state.md             # Shared (current feature context)
├── audit.md                   # Shared (append-only)
└── requirements-index.md      # Consolidated index of all features
```

At Workspace Detection, the agent proposes a feature slug and waits for your confirmation before creating directories.

## Extensions

Rule sets that enforce constraints during construction stages:

### Always Enforced (no opt-in needed)

| Extension | Rules | What It Enforces |
|-----------|-------|-----------------|
| Requirement Versioning | REQ-VER-01–05 | Feature-scoped directories, requirements index, no-overwrite protection, slug confirmation |
| Git Commit Signing | GIT-SIGN-01–04 | GPG/SSH signed commits, guided setup if missing |

### Opt-In (presented during Requirements Analysis)

| Extension | Rules | What It Enforces |
|-----------|-------|-----------------|
| Security Baseline | SEC-01–08 | OWASP input validation, auth, secrets, encryption, logging, dependencies |
| Resiliency Baseline | RES-* | AWS Well-Architected reliability patterns |
| Property-Based Testing | TEST-* | Hypothesis/fast-check property-based test generation |

Extensions follow the `## Rule PREFIX-NN:` format with verification checklists at each stage.

## GitHub Sync (via `gh` CLI)

No MCP power needed. The workflow uses `gh` CLI directly:

| Event | What Happens |
|-------|-------------|
| User stories approved | Creates GitHub issues with `aidlc:story` label |
| Code generation starts | Comments on issue: "🔄 Code Generation Started" |
| Code generation approved | Closes issue: "✅ Complete" |

**Config in `project-config.md`:**
```markdown
- **Auto-create Issues**: yes
- **Auto-sync Board**: yes
```

Set `Auto-create Issues: no` to disable sync entirely.

## Hooks

Pre-built event-driven automation:

| Hook | Trigger | What It Does |
|------|---------|-------------|
| `spec-to-issues.json` | `PostFileCreate` (stories.md) | Syncs approved stories to GitHub issues |
| `aidlc-board-sync.json` | `PostToolUse` | Updates board on stage transitions |
| `pr-review-check.json` | `PreToolUse` | Validates PR review requirements |
| `pre-code-gen.json` | `PreTaskExec` | Activates registered powers before code gen |

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

Powers add validation and best-practice guidance but never block progress. If a power isn't installed, the workflow warns and continues.

## Skills

Reusable skills bundled with the power:

| Skill | Purpose |
|-------|---------|
| `setup-aidlc` | Install/upgrade AI-DLC in any project — supports Kiro, Cursor, Cline, Q Developer, Copilot, Claude Code |
| `aidlc-analyze` | Pre-workflow analysis mode — explore domain, constraints, risks |
| `aidlc-explore` | Mid-workflow investigation — compare approaches, clarify decisions |

Skills follow the [Agent Skills standard](https://agentskills.io/specification). See `steering/skills-convention.md` for conventions when creating new skills.

## Explore & Analyze Modes

Two thinking-partner modes available anytime:

- **Analyze** — Deep-dive before starting. Understand domain, constraints, risks.
- **Explore** — Mid-workflow investigation. Compare approaches, clarify decisions.

## Project Structure

```
kiro-powers-aidlc/
├── scripts/
│   ├── setup-aidlc.sh           # Zero-prompt bootstrap (upgrade-aware)
│   ├── sync-stories-to-github.sh # Bulk story creation helper
│   └── init-workspace.sh        # Workspace initialization
├── steering/                     # Loaded by Kiro as context
│   ├── core-workflow.md          # Main AIDLC orchestration rules
│   ├── github-integration.md    # GitHub sync via gh CLI
│   ├── power-orchestration.md   # Multi-power coordination
│   ├── skills-convention.md     # Agent Skills standard for creating skills
│   └── project-config-template.md
├── workflows/                    # Rule-detail files
│   ├── common/                   # Shared utilities (10 files)
│   ├── inception/                # Planning stages (7 files)
│   ├── construction/             # Build stages (6 files)
│   ├── operations/               # Placeholder for future deployment workflows
│   └── extensions/               # Blocking rule extensions
│       ├── core/                 # Always-enforced (requirement versioning)
│       ├── security/             # Security baseline + git signing
│       ├── resiliency/           # AWS reliability patterns
│       └── testing/              # Property-based testing
├── hooks/                        # Event-driven automation (4 files)
├── skills/                       # Reusable AI skills
│   └── setup-aidlc/SKILL.md    # Multi-IDE AIDLC installer
├── templates/
│   └── project-config.md        # Template for manual setup
├── examples/
│   └── sample-project-config.md # Example configuration
├── POWER.md                      # Power manifest
├── package.json
└── README.md
```

## Relationship to `awslabs/aidlc-workflows`

This power is a **superset** of the official AWS AIDLC rules:

| Aspect | `awslabs/aidlc-workflows` | This power |
|--------|--------------------------|------------|
| **Scope** | Generic rules for any AI agent | Full Kiro-native orchestration |
| **Extensions** | None | 5 extensions with formal verification |
| **GitHub Sync** | None | Automated spec-to-issues + board updates |
| **Power Orchestration** | None | Multi-power coordination |
| **Hooks** | None | 4 pre-built event triggers |
| **Upgrade Detection** | None | Version-aware reinstall |
| **Multi-IDE Support** | Download zip | Skill with IDE auto-detection |

The `skills/setup-aidlc` skill can install the vanilla AWS rules for non-Kiro agents (Cursor, Cline, etc.). Our power's workflow engine is independent — no runtime dependency on the AWS release.

## Credits

- Core AI-DLC methodology: [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows) (MIT-0)
- Sample Kiro Power: [aws-samples/sample-aidlc-kiro-power](https://github.com/aws-samples/sample-aidlc-kiro-power) (MIT-0)
- Power orchestration, extensions & GitHub integration: [IntraEdge](https://github.com/intraedge-services)

## License

MIT
