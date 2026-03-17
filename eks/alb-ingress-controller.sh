#!/usr/bin/env bash
# =============================================================================
# ALB Ingress Controller Setup for EKS
# Run AFTER: eksctl create cluster -f eks/cluster.yaml
# =============================================================================
set -euo pipefail

CLUSTER_NAME="board-service-cluster"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "🚀 Setting up ALB Ingress Controller..."
echo "   Account: $ACCOUNT_ID | Region: $REGION | Cluster: $CLUSTER_NAME"

# ── 1. Download IAM policy for AWS Load Balancer Controller ──────────────────
echo "📥 Downloading IAM policy..."
curl -fsSL https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.1/docs/install/iam_policy.json \
  -o /tmp/alb-iam-policy.json

# Create the IAM policy (ignore if already exists)
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file:///tmp/alb-iam-policy.json \
  --no-cli-pager 2>/dev/null || echo "   Policy already exists, skipping."

# ── 2. Create IAM service account with IRSA ──────────────────────────────────
echo "🔑 Creating IRSA service account..."
eksctl create iamserviceaccount \
  --cluster="$CLUSTER_NAME" \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name=AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn="arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy" \
  --approve \
  --override-existing-serviceaccounts

# ── 3. Install via Helm ───────────────────────────────────────────────────────
echo "⛵ Installing ALB Ingress Controller via Helm..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName="$CLUSTER_NAME" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region="$REGION" \
  --set vpcId=$(aws eks describe-cluster \
    --name "$CLUSTER_NAME" \
    --query "cluster.resourcesVpcConfig.vpcId" \
    --output text)

# ── 4. Verify ─────────────────────────────────────────────────────────────────
echo "✅ Waiting for controller to be ready..."
kubectl rollout status deployment/aws-load-balancer-controller -n kube-system --timeout=120s

echo ""
echo "🎉 ALB Ingress Controller is ready!"
echo "   Next: apply k8s manifests with 'kubectl apply -k k8s/'"
