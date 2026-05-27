# kiro-powers-aidlc

Adaptive AI Development Lifecycle — an orchestrator power for Kiro.

## Overview

This power provides a structured, adaptive software development workflow that:
- Guides development through Inception → Construction → Operations phases
- Automatically orchestrates other installed powers at the right moments
- Integrates with GitHub for project management (issues, board, PRs)
- Works across any IntraEdge project with minimal per-project config

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  kiro-powers-aidlc                        │
│              (Orchestrator Power)                         │
├─────────────────────────────────────────────────────────┤
│  Steering:                                               │
│  • aidlc-core-workflow.md    → Stage definitions         │
│  • power-orchestration.md   → When to call other powers  │
│  • github-integration.md    → Spec→Issues, board sync    │
│                                                          │
│  Hooks:                                                  │
│  • spec-to-issues.json      → Manual: stories → issues   │
│  • aidlc-board-sync.json    → Auto: stage done → board   │
│  • pre-code-gen.json        → Auto: activate DE/IaC      │
├─────────────────────────────────────────────────────────┤
│                    Orchestrates                           │
├──────────┬──────────┬──────────────┬────────────────────┤
│ GitHub   │ Data Eng │ Infra (IaC)  │ Diagrams           │
│ Power    │ Power    │ Power        │ Power              │
└──────────┴──────────┴──────────────┴────────────────────┘
         ↑                                    ↑
         └── Registered in project-config.md ─┘
```

## Per-Project Setup

1. Install this power + any dependent powers you need
2. Add `.kiro/steering/project-config.md` to your repo (see `templates/`)
3. Start developing — AIDLC activates automatically

## Dependencies

| Power | Required? | Purpose |
|-------|-----------|--------|
| `kiro-powers-github` | Recommended | Project management, issues, PRs |
| `kiro-powers-aws-data-engineering` | Optional | Glue/EMR/Athena patterns |
| `aws-infrastructure-as-code` | Optional | CDK/TF/CFN guidance |
| `kiro-powers-diagrams` | Optional | Architecture diagrams |

## License

MIT
