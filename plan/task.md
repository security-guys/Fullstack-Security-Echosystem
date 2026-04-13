# Portfolio Implementation Tasks

## Phase 1 — Application & Security Infrastructure

- [x] Create `eksctl` cluster config (`cluster.yaml`)
- [x] Create GitHub Actions CI/CD workflow (lint → build → ECR → EKS)
- [x] Update `k8s/` manifests for EKS (ALB ingress, ECR image refs)
- [x] Create AWS security setup script (GuardDuty, CloudTrail, WAF)
- [x] Create ECR repository setup script
- [ ] Push to new GitHub repo (user action)
- [ ] Run `eksctl create cluster` in AWS (user action)
- [ ] Verify all pods running on EKS (user action)
- [ ] Verify WAF/GuardDuty enabled (user action)

## Phase 2 — Log Pipeline

- [ ] Update Vector DaemonSet config → route to Kafka
- [ ] Define Kafka topics (one per log source)
- [ ] Create Lambda functions for AWS native log routing
- [ ] Create Vector aggregator config (Kafka → Elastic)
- [ ] Define log enrichment schema

## Phase 3 — Monitoring System (ELK)

- [ ] Elastic stack docker-compose for EC2
- [ ] Kibana dashboards (Application Security, WAF, GuardDuty, UBA)
- [ ] Okta integration setup
- [ ] Enable Elastic Security XDR

## Phase 4 — Threat Detection & Alerting

- [ ] Enable MITRE ATT&CK rule pack in Elastic
- [ ] Write custom detection rules (brute force, kubectl exec, etc.)
- [ ] Configure Slack webhook alerting
- [ ] Configure JIRA auto-ticketing

## Phase 5 — Active Threat Detection

- [ ] Set up Windows + Linux EC2 endpoints with Elastic Agent
- [ ] Install Atomic Red Team on endpoints
- [ ] Run test scenarios and document detections
- [ ] Write custom EKS detection rules

## Phase 6 — AI/ML

- [ ] Enable Elastic ML jobs
- [ ] Configure Elastic AI Assistant with Bedrock backend
- [ ] Build GuardDuty → Bedrock → JIRA Lambda pipeline
- [ ] Add Bedrock Guardrails + ingest violation logs

## Phase 7 — Vulnerability Management (DevSecOps)

- [ ] Add Trivy container scan to GitHub Actions
- [ ] Add CodeQL SAST to GitHub Actions
- [ ] Add Checkov IaC scan (when Terraform added)
- [ ] Add SBOM generation with syft
