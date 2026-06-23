---
inclusion: always
---
# Project Configuration

> Run `setup-aidlc.sh` to auto-fill this, or copy to `.kiro/steering/project-config.md` and fill manually.

## Project Identity

- **Name**: {Project Name}
- **Default Branch**: main

## Source Control

- **Provider**: github
- **Org/Owner**: {org-or-username}
- **Repo**: {repo-name}

> Supported providers: `github`, `gitlab`, `bitbucket`, `azure-devops`
> For self-hosted: add `- **Host**: https://gitlab.company.com`

## Project Tracking

- **Board Provider**: github-projects
- **Board ID**: {number or "none"}

> Supported board providers: `github-projects`, `gitlab-boards`, `jira`, `linear`, `none`
> Set to `none` to skip all board sync.

## Team

- **Lead**: {username}
- **Developers**: {comma-separated usernames, optional}

## Tech Stack

- **Language**: {Python / TypeScript / Java / Go / Rust / etc.}
- **Framework**: {AWS CDK / Terraform / Next.js / Django / Spring / etc.}

## AIDLC Preferences

- **Auto-create Issues**: yes
- **Auto-sync Board**: yes

## Installed Powers Registry

> Add rows only for powers you have installed in Kiro. Leave empty if none.
> Issue tracking uses CLI tools directly (gh/glab/etc.) — no power needed.

| Category | Power Name | Activate During |
|----------|-----------|------------------|

> **Common configurations:**
>
> _AWS CDK project:_
> | infrastructure | kiro-powers-aws-cdk-python | Infrastructure design, code gen |
>
> _Terraform project:_
> | infrastructure | terraform | Infrastructure design, code gen |
>
> _Full stack with diagrams + CI:_
> | infrastructure | kiro-powers-aws-cdk-python | Infrastructure design |
> | diagrams | kiro-powers-diagrams | Architecture docs |
> | ci-cd | kiro-powers-circleci | Pipeline validation |
>
> _Data engineering:_
> | data-engineering | kiro-powers-aws-data-engineering | Glue/EMR/Athena workloads |
