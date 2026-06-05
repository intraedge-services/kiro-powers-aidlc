---
inclusion: always
---
# Project Configuration — Sample Data Pipeline

## Project Identity

- **Name**: Sample Data Pipeline
- **GitHub Org**: intraedge-services
- **GitHub Repo**: aws-data-pipeline
- **Project Board Number**: 7
- **Default Branch**: main

## Team

- **Lead**: team-lead
- **Developers**: developer1, developer2
- **Reviewers**: team-lead

## Tech Stack

- **Language**: Python
- **Framework**: AWS CDK (infrastructure), PySpark (data processing)
- **Runtime**: AWS Glue 4.0, Step Functions
- **Storage**: S3 (Bronze/Silver/Gold), Apache Iceberg
- **Database**: Glue Catalog, Athena
- **Monitoring**: CloudWatch, SNS

## AIDLC Preferences

- **Default Depth**: standard
- **Auto-create Issues**: yes
- **Auto-sync Board**: yes
- **Generate Diagrams**: yes

## Installed Powers Registry

| Category | Power Name | Activate During |
|----------|-----------|------------------|
| project-management | kiro-powers-github | After user stories, board sync on stage transitions |
| data-engineering | kiro-powers-aws-data-engineering | Code gen for Glue jobs, Athena queries, EMR clusters |
| infrastructure | kiro-powers-aws-cdk-python | Infrastructure design, CDK construct generation, template validation |
| diagrams | kiro-powers-diagrams | Architecture docs, pipeline flow diagrams |
| ci-cd | kiro-powers-circleci | Build & test validation, pipeline templates |

## Extensions

| Extension | Enabled | Notes |
|-----------|---------|-------|
| security-baseline | yes | Lake Formation, IAM least-privilege |
| compliance | no | Enable for regulated industries |
