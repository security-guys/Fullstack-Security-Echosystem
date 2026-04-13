# Cybersecurity Portfolio Plan

### Target: SOC Analyst / Cloud Security Engineer / DevSecOps Roles

> **Budget**: ~$10–20/month | **Foundation**: Existing `board-service` (React + Node.js + Kubernetes) | **Timeline**: ~5–6 months total

---

## What You Already Have ✅

Your existing `board-service` project is a strong foundation:

| Component                   | Status  | What it shows                  |
| --------------------------- | ------- | ------------------------------ |
| React + Node.js app         | ✅ Done | Full-stack development ability |
| Dockerized (multi-stage)    | ✅ Done | Container best practices       |
| Kubernetes manifests (k8s/) | ✅ Done | EKS-migration-ready            |
| Kafka docker-compose        | ✅ Done | Event streaming foundation     |
| Prometheus + Grafana        | ✅ Done | Metrics monitoring baseline    |
| Vector DaemonSet config     | ✅ Done | Log collection agent ready     |

> [!IMPORTANT]
> All phases below **build on top of** the existing project. You are NOT starting from scratch.

---

## Phase 1 — Application & Security Infrastructure

**Goal**: Deploy `board-service` on real AWS EKS with security controls in place.
**Interviewer Takeaway**: _"You can deploy and secure a real cloud-native application."_

### Architecture

```
Internet → Route53 → ALB (AWS WAF) → EKS Ingress → board-service pods
                                        └── MongoDB Atlas (free tier)
AWS Security: GuardDuty + CloudTrail + WAF → S3 bucket (raw logs)
```

### Steps

#### 1.1 AWS EKS Cluster Setup

- Create EKS cluster using `eksctl` (1 node group, `t3.medium` × 2 nodes)
- Migrate existing `k8s/` manifests — they are already EKS-compatible
- Set up ALB Ingress Controller (replaces minikube ingress)
- Configure `kubectl` context for EKS

#### 1.2 CI/CD Pipeline (GitHub Actions → ECR → EKS)

```
GitHub Push → GitHub Actions:
  1. Run lint/tests
  2. Build Docker image
  3. Push to Amazon ECR
  4. kubectl apply to EKS (using IRSA)
```

- Use **GitHub Actions** (free tier, 2000 min/month)
- Use **Amazon ECR** for image registry (~$0.10/GB storage)
- Use **IRSA** (IAM Roles for Service Accounts) — no static credentials

#### 1.3 AWS Security Controls

| Service    | Configuration                                 | Monthly Cost              |
| ---------- | --------------------------------------------- | ------------------------- |
| AWS WAF    | Core Rule Set + Rate limiting                 | ~$5/month                 |
| GuardDuty  | Enable on account level                       | ~$1–2/month (low traffic) |
| CloudTrail | Management events to S3                       | ~$0 (first trail free)    |
| S3         | Log storage (lifecycle policy: 30-day delete) | <$1/month                 |

#### 1.4 Optional: Terraform

- Use Terraform to provision: EKS cluster, VPC, WAF, GuardDuty, S3 log bucket
- Store state in S3 + DynamoDB (both free tier)
- Demonstrates IaC skills that are highly valued in DevSecOps roles

### Cost Estimate: ~$8–12/month (EKS control plane $0.10/hr = ~$72/month)

> [!CAUTION]
> EKS control plane alone costs **~$72/month**. To stay under budget, use **EKS for demo periods only** (spin up → demo → spin down). Use Minikube locally for daily development. Consider using k3s on a free-tier EC2 or **EKS with Fargate spot** to reduce cost.

**Cost-Saving Strategy**: Use `eksctl delete cluster` when not actively demoing. Export your kubectl commands and architecture diagrams as proof of work.

---

## Phase 2 — Log Pipeline

**Goal**: Collect all log sources and feed them into a central pipeline.
**Interviewer Takeaway**: _"You can build and operate a production-grade SIEM data pipeline."_

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Log Sources                            │
│  EKS Pods ──► Vector DaemonSet ──┐                      │
│  Nginx logs ──► Vector sidecar ──┤                      │
│  Node.js logs ──────────────────►├──► Kafka ────────────┤
│  AWS WAF logs ──► S3 ───────────►│    (Topic per source)│
│  GuardDuty ──► EventBridge ─────►│                      │
│  CloudTrail ──► S3 ──────────────┘                      │
└─────────────────────┬───────────────────────────────────┘
                       │
              Vector Aggregator (EC2 t3.micro)
                       │
              Elastic Cloud (free 14-day → paid $16/mo)
```

### Steps

#### 2.1 EKS Pod & App Logs (Vector DaemonSet)

- You already have `k8s/vector-daemonset.yaml` and `vector-daemonset-config.yaml`
- Update Vector config to route to Kafka instead of stdout
- Add fields: `source`, `cluster`, `namespace`, `pod_name`

#### 2.2 Kafka Topics Design

```
Topics:
  - board-service.app.nodejs     ← Node.js application logs
  - board-service.app.nginx      ← Nginx access/error logs
  - aws.waf                      ← WAF logs (via Firehose → S3 → Lambda → Kafka)
  - aws.guardduty                ← GuardDuty findings (EventBridge → Lambda → Kafka)
  - aws.cloudtrail               ← CloudTrail events (S3 → Lambda → Kafka)
  - endpoints.windows            ← Windows Sysmon/Event logs
  - endpoints.linux              ← Linux auditd logs
```

#### 2.3 AWS Native Log Routing

- **WAF logs**: Enable WAF logging → Kinesis Firehose → S3 → Lambda trigger → Kafka
- **GuardDuty**: EventBridge rule → Lambda → Kafka topic
- **CloudTrail**: S3 trigger → Lambda → Kafka topic
- Lambda functions can run within free tier (1M invocations/month free)

#### 2.4 Vector Aggregator (Kafka → Elastic)

- Deploy on EC2 `t3.micro` (free tier eligible for 12 months)
- Pull from all Kafka topics, parse/enrich, push to Elastic Cloud

#### 2.5 Log Enrichment / Parsing

Add metadata to every log event:

```json
{
  "source": "aws.guardduty",
  "environment": "production",
  "cluster": "board-service-eks",
  "geo_ip": "...",          ← Enrich source IPs
  "threat_intel": "...",    ← Optional: match against threat feeds
  "@timestamp": "..."
}
```

### Cost Estimate: ~$0–3/month (Lambda free tier + t3.micro free tier year 1)

---

## Phase 3 — Monitoring System (ELK/SIEM)

**Goal**: Centralized visibility into all logs with dashboards and alerting.
**Interviewer Takeaway**: _"You can operate an enterprise SIEM and build detection dashboards."_

### ELK Deployment Options (Cost Comparison)

| Option                   | Cost                          | Pros                 | Cons              |
| ------------------------ | ----------------------------- | -------------------- | ----------------- |
| Elastic Cloud (Trial)    | Free 14 days, then ~$16/mo    | Managed, ML features | Cost after trial  |
| Elastic on EC2 t3.medium | ~$0–3/mo (1st year free tier) | Full control         | Manual management |
| OpenSearch on EC2        | Free                          | Compatible with ELK  | No ML features    |

**Recommendation**: Start with Elastic Cloud trial for demos and screenshots, then migrate to self-hosted EC2 for ongoing costs.

### Steps

#### 3.1 Elastic Stack Setup

- Deploy Elasticsearch + Kibana (Docker on EC2 or Elastic Cloud)
- Create Index Lifecycle Management (ILM) policies: hot(7d) → warm(14d) → delete
- Set up index templates per log source with correct field mappings

#### 3.2 Okta SIEM Integration

- Sign up for [Okta Developer Account](https://developer.okta.com/signup/) (free)
- Enable Okta System Log → forward to Elastic via Filebeat or direct API polling
- Create Elastic dashboard: failed logins, MFA events, user lifecycle changes
- **Why it matters**: Shows IAM/Identity monitoring skills — very relevant for enterprise security roles

#### 3.3 Kibana Dashboards to Build

| Dashboard            | Signals                                                    |
| -------------------- | ---------------------------------------------------------- |
| Application Security | Failed logins, JWT errors, rate limit triggers             |
| AWS Security Posture | WAF blocked requests, GuardDuty findings by severity       |
| Network Activity     | Top source IPs, geolocation maps, port scanning detection  |
| User Behavior (UBA)  | Okta logins, after-hours activity, impossible travel       |
| Kubernetes Security  | Pod crashloops, privileged container access, image changes |

#### 3.4 XDR with ELK (Elastic Security)

- Enable **Elastic Security** app in Kibana (included in Elastic)
- Configure `elastic-agent` on your endpoint VMs for EDR-like telemetry
- Enable built-in detection rules (MITRE ATT&CK mapped)

### Cost Estimate: ~$3–16/month

---

## Phase 4 — Threat Detection & Alerting

**Goal**: Active alerting on real detections with ticketing workflow.
**Interviewer Takeaway**: _"You have end-to-end SOC analyst workflow experience."_

### Architecture

```
Elastic Detection Rules
        │
        ▼
   Alert fired
   ├──► Slack notification (Elastic webhook action)
   └──► JIRA ticket created (Elastic webhook → JIRA REST API)
              │
              ▼
         SOC Analyst reviews → closes ticket
```

### Steps

#### 4.1 Detection Rules

- **Native ELK rules**: Enable MITRE ATT&CK rule pack (500+ rules)
- **Custom rules** to write:
  - `POST /api/users/login` failures > 5 in 60s → Brute Force
  - GuardDuty `HIGH` severity finding → Immediate alert
  - CloudTrail: `ConsoleLogin` from new IP → Suspicious access
  - WAF: >100 blocked requests from same IP in 5 min → DDoS attempt
  - Kubernetes: Pod exec into running container (`kubectl exec`)

#### 4.2 Slack Integration

- Create Slack App, generate Webhook URL
- Configure Elastic Alerting → webhook connector → Slack channel `#security-alerts`
- Alert format includes: severity, rule name, affected resource, timestamp, Kibana link

#### 4.3 JIRA Integration

- Sign up for JIRA Cloud (free, up to 10 users)
- Configure Elastic → JIRA connector
- Auto-create tickets with: priority mapping (Critical/High/Medium), MITRE ATT&CK technique, raw log evidence

### Cost Estimate: ~$0/month (Slack free + JIRA free + Elastic alerting included)

---

## Phase 5 — Active Threat Detection (EDR + Red Team Simulation)

**Goal**: Prove you can detect attacks and tune detection rules using real adversary simulation.
**Interviewer Takeaway**: _"You think like an attacker AND a defender."_

### Steps

#### 5.1 Endpoint Setup

- Spin up 2 EC2 instances (t2.micro free tier):
  - `Windows Server 2022` — install Sysmon + Elastic Agent
  - `Amazon Linux 2` — install auditd + Elastic Agent
- Configure both to forward to your Elastic stack

#### 5.2 Elastic Agent EDR

- Deploy `elastic-agent` with **Endpoint Security** integration (requires Elastic license)
- Alternative (free): Use **Wazuh** (open-source EDR) + forward alerts to Elastic
- Monitor: process execution, network connections, file writes, registry changes (Windows)

#### 5.3 Atomic Red Team Simulations

```bash
# On Windows endpoint
Install-Module -Name invoke-atomicredteam
Invoke-AtomicTest T1059.001   # PowerShell execution
Invoke-AtomicTest T1003.001   # OS Credential Dumping (LSASS)
Invoke-AtomicTest T1071.001   # C2 over HTTP

# On Linux endpoint
Invoke-AtomicTest T1548.001   # Setuid/Setgid
Invoke-AtomicTest T1070.004   # File Deletion
```

#### 5.4 Detection Tuning Workflow

For each Atomic test:

1. Run the test
2. Check if Elastic alert fired
3. If NO → write a new custom detection rule
4. If YES → document that the existing rule works
5. Reduce false positives by adding exception conditions
6. Document everything in JIRA tickets (as if it's a real incident)

#### 5.5 Custom EKS Detection Rules

- `kubectl exec` into running pods → alert
- New privileged pod deployed → alert
- Unexpected image pulled from non-ECR registry → alert
- CPU spike anomaly on pods (potential crypto-mining) → ML rule

### Cost Estimate: ~$0/month (EC2 free tier for 2 instances year 1)

> [!IMPORTANT]
> Run Atomic Red Team tests **only on your own infrastructure**. Never run on AWS accounts without authorization. GuardDuty will detect some of these and generate findings — that's actually a good thing for the demo!

---

## Phase 6 — AI/ML (LLM + ML Detection)

**Goal**: Showcase cutting-edge AI-powered security capabilities.
**Interviewer Takeaway**: _"You can leverage AI for security operations — a highly sought skill in 2025."_

### Steps

#### 6.1 Elastic ML Detection Rules

- Enable **Elastic ML jobs** (requires at least Basic license):
  - `Unusual Process for a Windows Host`
  - `Unusual Network Activity`
  - `Rare User Agent` detection
  - `High-Count Network Connections`
- Document which ML rules trigger during Atomic Red Team tests

#### 6.2 Elastic LLM / AI Assistant

- Elastic 8.x includes **AI Assistant** for security analysts
- Configure with an LLM backend (OpenAI API or AWS Bedrock)
- Use cases: `Explain this alert`, `Summarize this incident timeline`, `Suggest remediation`
- RAG pipeline: Elastic itself becomes the RAG data store (your logs = context)

#### 6.3 AWS Bedrock Integration (Independent LLM Pipeline)

```
Architecture:
GuardDuty Finding → EventBridge → Lambda
                                      │
                                      ▼
                              AWS Bedrock (Claude/Titan)
                              "Analyze this GuardDuty finding and
                               suggest remediation steps"
                                      │
                                      ▼
                              Response → JIRA ticket comment
                                       → Slack notification
```

- Use **Claude 3 Haiku** on Bedrock (cheapest, ~$0.00025/1K input tokens)
- Add **Bedrock Guardrails** to prevent prompt injection attacks
- Ingest guardrail violation logs into Elastic — this demonstrates AI security awareness

#### 6.4 RAG for Threat Intelligence

- Store your internal playbooks and detection rules as documents in Elastic
- Use Elastic's built-in vector search (kNN) for semantic search
- Query: _"What is our playbook for GuardDuty PortScan findings?"_

### Cost Estimate: ~$1–3/month (Bedrock pay-per-use at low volume)

---

## Phase 7 — Vulnerability Management (DevSecOps)

**Goal**: Shift security left into the CI/CD pipeline.
**Interviewer Takeaway**: _"You understand DevSecOps and can secure software supply chains."_

### Steps

#### 7.1 Pipeline Security Gates (GitHub Actions)

Add to existing CI/CD pipeline:

```yaml
# SAST: Static Analysis
- uses: github/codeql-action/analyze@v3 # Code vulnerabilities

# SCA: Software Composition Analysis
- uses: aquasecurity/trivy-action@master # Container + dependency scan
  with:
    scan-type: "fs"
    exit-code: "1" # Block pipeline if CRITICAL found

# Container Image Scan
- uses: aquasecurity/trivy-action@master
  with:
    image-ref: "${{ env.ECR_IMAGE }}"
    severity: "CRITICAL,HIGH"

# IaC Scan (if using Terraform)
- uses: bridgecrewio/checkov-action@master
```

#### 7.2 SBOM Generation

- Generate Software Bill of Materials with `syft`
- Attach SBOM to each GitHub release
- Demonstrates supply chain security awareness

#### 7.3 Runtime Vulnerability Tracking (Optional Advanced)

- Use **AWS Inspector** (integrates with ECR — free trial)
- Auto-scan ECR images for CVEs
- Forward findings to Elastic via EventBridge → Lambda

### Cost Estimate: ~$0/month (all free tools)

---

## Total Budget Summary

| Phase                    | Services                       | Monthly Cost   |
| ------------------------ | ------------------------------ | -------------- |
| Phase 1 (App + Security) | WAF + GuardDuty + CloudTrail   | ~$7–8/mo       |
| Phase 2 (Log Pipeline)   | Lambda + t3.micro (free yr1)   | ~$0–2/mo       |
| Phase 3 (ELK)            | EC2 t3.medium or Elastic Cloud | ~$3–16/mo      |
| Phase 4 (Alerting)       | Slack + JIRA (free tiers)      | ~$0/mo         |
| Phase 5 (EDR/Red Team)   | EC2 t2.micro × 2 (free yr1)    | ~$0/mo         |
| Phase 6 (AI/ML)          | Bedrock (low usage)            | ~$1–3/mo       |
| Phase 7 (DevSecOps)      | GitHub Actions (free tier)     | ~$0/mo         |
| **Total**                |                                | **~$11–29/mo** |

> [!TIP]
> **Critical cost tip**: EKS control plane is $0.10/hr ($72/mo). **Turn it off when not demoing**. Keep screenshots, architecture diagrams, and a video walkthrough as proof of work. On demo days, spin it back up with Terraform in ~10 minutes.

---

## Portfolio Presentation Strategy

### GitHub Repository Structure

```
board-service/           ← existing (continue here)
├── .github/workflows/   NEW: CI/CD pipelines
├── terraform/           NEW: Infrastructure as Code
├── k8s/                 existing + add EDR manifests
├── kafka/               existing
├── monitoring/          existing + add Elastic config
├── detection-rules/     NEW: Custom Kibana rules (JSON)
├── atomic-red-team/     NEW: Test scripts + results
├── ai-pipeline/         NEW: Bedrock Lambda functions
└── docs/
    ├── architecture/    Architecture diagrams
    ├── incidents/        Sample incident reports
    └── runbooks/         SOC playbooks
```

### What to Show in Interviews

| Role                    | Lead With                                                                           |
| ----------------------- | ----------------------------------------------------------------------------------- |
| SOC Analyst             | Phase 3-4: Kibana dashboards, alert workflow, JIRA tickets, Atomic Red Team results |
| Cloud Security Engineer | Phase 1-2: EKS + WAF + GuardDuty + CI/CD pipeline architecture                      |
| DevSecOps Engineer      | Phase 7: Pipeline security gates, SBOM, Trivy scan results                          |
| Security Engineer       | Phase 5-6: Custom detection rules, ML anomaly detection, Bedrock integration        |

### Documentation to Produce (Per Phase)

- **Architecture diagram** (draw.io or Mermaid)
- **README** with setup steps
- **Screenshot gallery**: dashboards, alerts, detections
- **1 sample incident report** (from Atomic Red Team test)
- **Demo video** (5–10 min Loom recording of each phase)

---

## Recommended Timeline

| Month   | Focus                                               |
| ------- | --------------------------------------------------- |
| Month 1 | Phase 1: EKS deployment + WAF/GuardDuty + Terraform |
| Month 2 | Phase 2: Log pipeline (Vector → Kafka → Elastic)    |
| Month 3 | Phase 3: ELK SIEM dashboards + Okta integration     |
| Month 4 | Phase 4 + 5: Detection rules + Atomic Red Team      |
| Month 5 | Phase 6: AI/ML detection + Bedrock                  |
| Month 6 | Phase 7: DevSecOps pipeline + portfolio polish      |
