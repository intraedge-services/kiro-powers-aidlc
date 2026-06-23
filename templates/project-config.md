---
inclusion: always
---
# Project Configuration

> Copy this to `.kiro/steering/project-config.md` in your project, or run `setup-aidlc.sh` (auto-fills from git).

## Project Identity

- **Name**: {Project Name}
- **GitHub Org**: {org-name}
- **GitHub Repo**: {repo-name}
- **Project Board Number**: {number or "none"}
- **Default Branch**: main

## Team

- **Lead**: {github-username}

## Tech Stack

- **Language**: {Python / TypeScript / Java / etc.}
- **Framework**: {AWS CDK / Terraform / Next.js / etc.}

## AIDLC Preferences

- **Auto-create Issues**: yes
- **Auto-sync Board**: yes

## Installed Powers Registry

> Add rows for powers you have installed. Remove rows you don't use.
> GitHub project management uses `gh` CLI directly — no power needed for that.

| Category | Power Name | Activate During |
|----------|-----------|------------------|

> **Examples:**
>
> | Category | Power Name | Activate During |
> |----------|-----------|------------------|
> | infrastructure | kiro-powers-aws-cdk-python | Infrastructure design, code generation |
> | diagrams | kiro-powers-diagrams | Architecture docs, infra design |
> | ci-cd | kiro-powers-circleci | Build & test validation |
> | data-engineering | kiro-powers-aws-data-engineering | Glue/EMR/Athena workloads |
