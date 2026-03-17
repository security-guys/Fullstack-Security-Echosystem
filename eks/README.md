# Phase 1 — Application & Security Infrastructure

> **Status**: 🚧 In Progress  
> **Goal**: Deploy `board-service` on AWS EKS with WAF, GuardDuty, CloudTrail protection and automated CI/CD pipeline.

---

## Architecture

```
Developer Push
      │
      ▼
GitHub Actions (.github/workflows/deploy.yml)
  ├── Lint & Test
  ├── Security Scan (CodeQL + Trivy)
  ├── Build & Push → Amazon ECR
  └── Deploy → Amazon EKS
                    │
                    ▼
           AWS EKS Cluster (board-service-cluster)
           ┌──────────────────────────┐
           │  Namespace: board-service │
           │  ┌────────────────┐       │
           │  │ Frontend Pod × 2│       │
           │  │ (React/Nginx)  │       │
           │  └────────────────┘       │
           │  ┌────────────────┐       │
           │  │ Backend Pod × 2 │       │
           │  │ (Node.js)      │       │
           │  └────────────────┘       │
           └──────────────────────────┘
                    │
              ALB (with WAF)
                    │
                 Internet

AWS Security Controls:
  ├── WAF: CRS + Rate Limit → ALB
  ├── GuardDuty: EKS + S3 + Runtime monitoring
  └── CloudTrail: All APIs → S3 (30-day retention)
```

---

## Prerequisites

| Tool       | Installation                                                      |
| ---------- | ----------------------------------------------------------------- |
| AWS CLI v2 | `brew install awscli`                                             |
| eksctl     | `brew tap weaveworks/tap && brew install eksctl`                  |
| kubectl    | `brew install kubectl`                                            |
| Helm       | `brew install helm`                                               |
| Docker     | [Docker Desktop](https://www.docker.com/products/docker-desktop/) |

```bash
# Verify all tools
aws --version
eksctl version
kubectl version --client
helm version
```

---

## Step-by-Step Deployment

### Step 1: Configure AWS CLI

```bash
aws configure
# AWS Access Key ID: <your key>
# AWS Secret Access Key: <your secret>
# Default region: us-east-1
# Default output format: json

# Verify
aws sts get-caller-identity
```

### Step 2: Set Up ECR Repositories

```bash
bash eks/ecr-setup.sh
```

This creates:

- `board-backend` ECR repository (with image scanning)
- `board-frontend` ECR repository (with image scanning)
- 10-image lifecycle policy to control storage costs

### Step 3: Create EKS Cluster

> ⚠️ **Cost warning**: EKS control plane = ~$0.10/hr ($2.40/day). Delete when not demoing.

```bash
# Create cluster (takes ~15-20 minutes)
eksctl create cluster -f eks/cluster.yaml

# Verify
kubectl get nodes
kubectl get namespaces
```

### Step 4: Install ALB Ingress Controller

```bash
bash eks/alb-ingress-controller.sh

# Verify
kubectl get pods -n kube-system | grep aws-load-balancer
```

### Step 5: Enable Security Controls

```bash
bash eks/security-setup.sh
```

This enables:

- 📦 **S3 log bucket** — encrypted, 30-day lifecycle, public access blocked
- 📋 **CloudTrail** — multi-region, all API calls, log file validation
- 🛡️ **GuardDuty** — EKS audit logs, S3 data events, Runtime monitoring
- 📡 **EventBridge rule** — HIGH/CRITICAL findings → SNS → (Slack later)
- 🧱 **WAF** — Core Rule Set + Known Bad Inputs + 1000 req/IP rate limit

### Step 6: Configure GitHub Actions OIDC

```bash
# Replace with your GitHub org and repo name
bash eks/github-oidc-setup.sh security-guys board-service
```

Then add these to **GitHub → Settings → Secrets → Actions**:
| Secret Name | Value |
|---|---|
| `AWS_DEPLOY_ROLE_ARN` | Output from script above |
| `AWS_ACCOUNT_ID` | Your AWS account ID |

Also grant GitHub Actions role access to EKS:

```bash
eksctl create iamidentitymapping \
  --cluster board-service-cluster \
  --region us-east-1 \
  --arn <ROLE_ARN_FROM_SCRIPT> \
  --group system:masters \
  --username github-actions
```

### Step 7: Create Kubernetes Secrets

```bash
# Create the Kubernetes secret with your real values
kubectl create secret generic board-service-secrets \
  --namespace board-service \
  --from-literal=MONGODB_URI="mongodb+srv://..." \
  --from-literal=JWT_SECRET="your-jwt-secret-here"
```

> 💡 **Note**: Do NOT commit `k8s/secret.yaml` with real values. The CI/CD pipeline uses IRSA and AWS Secrets Manager (future enhancement).

### Step 8: Deploy the Application

Push to the `main` branch to trigger the pipeline, **OR** deploy manually:

```bash
# Manual deploy (for initial setup)
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
kubectl apply -f k8s/ingress-eks.yaml

# Check status
kubectl get all -n board-service

# Get the ALB URL (takes ~2-3 minutes to provision)
kubectl get ingress -n board-service
```

### Step 9: Associate WAF with ALB

```bash
# Get ALB ARN
ALB_ARN=$(aws elbv2 describe-load-balancers \
  --query "LoadBalancers[?contains(DNSName, 'board-service')].LoadBalancerArn" \
  --output text)

# Get WAF ACL ARN
WAF_ARN=$(aws wafv2 list-web-acls \
  --scope REGIONAL --region us-east-1 \
  --query "WebACLs[?Name=='board-service-waf'].ARN" \
  --output text)

# Associate
aws wafv2 associate-web-acl \
  --web-acl-arn "$WAF_ARN" \
  --resource-arn "$ALB_ARN"

echo "✅ WAF associated with ALB"
```

---

## Verify Security Controls

```bash
# Check GuardDuty is active
aws guardduty list-detectors --region us-east-1

# Check CloudTrail is logging
aws cloudtrail get-trail-status --name board-service-trail

# Check WAF rules
aws wafv2 list-web-acls --scope REGIONAL --region us-east-1

# Generate a test GuardDuty finding (safe test)
aws guardduty create-sample-findings \
  --detector-id <DETECTOR_ID> \
  --finding-types "UnauthorizedAccess:EC2/SSHBruteForce"
```

---

## Cost Management

### Shut Down When Not Demoing

```bash
# Scale nodes to 0 (saves ~$0.08/hr per node)
eksctl scale nodegroup \
  --cluster board-service-cluster \
  --name board-service-nodes \
  --nodes 0

# Or delete cluster entirely
eksctl delete cluster -f eks/cluster.yaml
```

### Re-create Cluster for Demos

```bash
# Recreate in ~15 minutes
eksctl create cluster -f eks/cluster.yaml
bash eks/alb-ingress-controller.sh
kubectl apply -k k8s/
```

### Estimated Monthly Cost (Active Demo)

| Resource                      | Cost                 |
| ----------------------------- | -------------------- |
| EKS Control Plane             | ~$72/month           |
| t3.medium × 2 nodes           | ~$60/month           |
| WAF                           | ~$5/month            |
| GuardDuty                     | ~$1-2/month          |
| CloudTrail                    | ~$0 (1st trail free) |
| S3 logs                       | <$1/month            |
| **Total (active)**            | ~$138/month          |
| **Total (scaled to 0 nodes)** | ~$8/month            |

> 💡 **Strategy**: Scale to 0 nodes daily, spin up only for demos/interviews.

---

## What This Demonstrates to Interviewers

- ✅ **Cloud-native deployment**: EKS, ECR, ALB — real AWS production stack
- ✅ **Security-first**: WAF, GuardDuty, CloudTrail configured before app goes live
- ✅ **CI/CD best practices**: OIDC (no static keys), image scanning, rollout verification
- ✅ **DevSecOps**: Trivy + CodeQL scanned in pipeline, blocks on CRITICAL CVEs
- ✅ **Cost awareness**: Auto-scaling 0→2, lifecycle policies, 30-day log retention

---

## Files Created in This Phase

```
board-service/
├── .github/
│   └── workflows/
│       └── deploy.yml           ← 4-stage CI/CD pipeline
├── eks/
│   ├── cluster.yaml             ← eksctl cluster configuration
│   ├── alb-ingress-controller.sh← ALB Ingress Controller setup
│   ├── ecr-setup.sh             ← ECR repository creation
│   ├── security-setup.sh        ← GuardDuty + CloudTrail + WAF
│   └── github-oidc-setup.sh     ← OIDC trust (no static keys)
└── k8s/
    └── ingress-eks.yaml         ← ALB ingress (replaces nginx ingress)
```
