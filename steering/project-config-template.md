# Project Config Template Guide

How to set up the per-project configuration that drives AIDLC power orchestration.

## Setup Instructions

1. Copy `templates/project-config.md` to your project's `.kiro/steering/project-config.md`
2. Fill in your project details
3. Remove power registry rows for powers you don't have installed

## Required Fields

| Field | Example | Purpose |
|-------|---------|--------|
| GitHub Org | `intraedge-services` | Target org for issue creation |
| GitHub Repo | `aws-cos-data-pipeline` | Target repo for issues |
| Project Board Number | `7` | GitHub Projects V2 board number |
| Default Branch | `main` | For PR creation |
| Lead | `sukrit007` | Default issue assignee |

## Power Categories

| Category | What It Does | Example Power |
|----------|-------------|---------------|
| `project-management` | Issues, board, PRs | `kiro-powers-github` |
| `data-engineering` | Glue/EMR/Athena patterns | `kiro-powers-aws-data-engineering` |
| `infrastructure` | CDK/TF/CFN guidance | `aws-infrastructure-as-code` |
| `diagrams` | Architecture visuals | `kiro-powers-diagrams` |
| `security` | Security scanning | (future) |
| `testing` | Test generation | (future) |

## Adding Custom Categories

You can define any category name. The AIDLC core workflow checks for built-in categories at specific stages. Custom categories can be referenced in custom steering files you add to your project.

Example:
```
| documentation | kiro-powers-docs | After reverse engineering, after code gen |
```
