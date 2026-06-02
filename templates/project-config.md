---
inclusion: always
---
# Project Configuration

> Copy this file to `.kiro/steering/project-config.md` in your project repo.
> Fill in the values below for your specific project.

## Project Identity

- **Name**: {Project Name}
- **GitHub Org**: {org-name}
- **GitHub Repo**: {repo-name}
- **Project Board Number**: {number}
- **Default Branch**: main

## Team

- **Lead**: {github-username}
- **Developers**: {username1}, {username2}
- **Reviewers**: {username3}

## Tech Stack

- **Language**: {Python / TypeScript / Java / etc.}
- **Framework**: {AWS CDK / Terraform / etc.}
- **Runtime**: {PySpark on Glue / Lambda / ECS / etc.}
- **Database**: {DynamoDB / RDS / Iceberg / etc.}

## AIDLC Preferences

- **Default Depth**: standard
- **Auto-create Issues**: yes
- **Auto-sync Board**: yes
- **Generate Diagrams**: yes

## Installed Powers Registry

| Category | Power Name | Activate During |
|----------|-----------|------------------|
| project-management | kiro-powers-github | After user stories, board sync on stage transitions |
| data-engineering | kiro-powers-aws-data-engineering | Code gen for Glue, EMR, Athena workloads |
| infrastructure | aws-infrastructure-as-code | Infrastructure design, CDK/TF code generation |
| diagrams | kiro-powers-diagrams | Architecture docs, infra design, functional design |
| ci-cd | kiro-powers-circleci | Build & test validation, code gen pipeline templates |

## Extensions

| Extension | Enabled | Notes |
|-----------|---------|-------|
| security-baseline | yes | Enforces security checks during NFR stages |
| compliance | no | Enable for regulated industries |
