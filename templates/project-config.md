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

> **IMPORTANT**: Powers listed here are MANDATORY to activate during the stages listed in "Activate During".
> The AIDLC workflow MUST activate these powers at the specified stages — it is NOT optional.
> **Remove a row entirely** if you do NOT use that power. Do NOT leave rows with placeholder values.
> If a power is listed here but NOT installed in Kiro, the workflow will warn you and continue without it.

| Category | Power Name | Activate During |
|----------|-----------|------------------|
| project-management | kiro-powers-github | After user stories, board sync on stage transitions |
| data-engineering | kiro-powers-aws-data-engineering | Code gen for Glue, EMR, Athena workloads ONLY (not general Python/ML) |
| infrastructure | kiro-powers-aws-cdk-python | Infrastructure design (MUST activate BEFORE designing), CDK/Python code generation, template validation |
| diagrams | kiro-powers-diagrams | Architecture docs, infra design, functional design |
| ci-cd | kiro-powers-circleci | Build & test validation, code gen pipeline templates |

> **Examples of valid minimal registries:**
>
> _Project using only GitHub + CDK (no diagrams, no data engineering, no CI/CD):_
> | Category | Power Name | Activate During |
> |----------|-----------|------------------|
> | project-management | kiro-powers-github | After user stories, board sync |
> | infrastructure | kiro-powers-aws-cdk-python | Infrastructure design, code generation |
>
> _Project using only Terraform (no GitHub, no diagrams):_
> | Category | Power Name | Activate During |
> |----------|-----------|------------------|
> | infrastructure | terraform | Infrastructure design, Terraform code generation |

## Extensions

> Extensions are opt-in rule sets that enforce additional constraints during the AIDLC workflow.
> They are scanned from `workflows/extensions/` and presented during Requirements Analysis.
> Extensions listed here with `enabled: yes` will be PRE-SELECTED (user still confirms during workflow).
> Remove a row or set `enabled: no` to skip the opt-in prompt for that extension.

| Extension | Enabled | Notes |
|-----------|---------|-------|
| security-baseline | yes | OWASP-aligned security rules — blocking constraints during NFR and Code Gen stages |
| property-based-testing | no | Property-based testing with Hypothesis/fast-check — enable for data-heavy projects |
| resiliency-baseline | no | AWS Well-Architected Reliability Pillar — enable for business-critical workloads |

## Power Activation Clarifications

> These notes help the AI model understand when to activate vs skip powers:

- **data-engineering**: Only activates for AWS data services (Glue, EMR, Athena, Spark on EMR). Does NOT activate for general Python ML code (scikit-learn, pandas, numpy, PyTorch, TensorFlow) or local data processing.
- **infrastructure**: Activates for ANY IaC code — CDK, Terraform, CloudFormation, Pulumi. Must be activated BEFORE designing infrastructure, not just after.
- **ci-cd**: Activates when new services are created that need pipelines, or during Build & Test to validate existing CI configs.
- **diagrams**: Activates at multiple stages (reverse engineering, functional design, infrastructure design) for visual documentation.
