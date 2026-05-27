---
inclusion: always
---
# Project Configuration — City of Scottsdale Data Pipeline

## Project Identity

- **Name**: COS Data Pipeline
- **GitHub Org**: intraedge-services
- **GitHub Repo**: aws-cos-data-pipeline
- **Project Board Number**: 7
- **Default Branch**: main

## Team

- **Lead**: sukrit007
- **Developers**: NileshDeshmukh27, Sangram
- **Reviewers**: sukrit007

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
| infrastructure | aws-infrastructure-as-code | Infrastructure design, CDK construct generation |
| diagrams | kiro-powers-diagrams | Architecture docs, pipeline flow diagrams |

## Extensions

| Extension | Enabled | Notes |
|-----------|---------|-------|
| security-baseline | yes | Lake Formation, IAM least-privilege |
| compliance | no | Not required for COS |
