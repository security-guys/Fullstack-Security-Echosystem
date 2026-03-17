#!/usr/bin/env bash
# =============================================================================
# GitHub Actions OIDC Trust Setup for AWS
#
# This replaces static AWS_ACCESS_KEY_ID/SECRET in GitHub Actions with
# short-lived OIDC tokens — a security best practice.
#
# Usage: bash eks/github-oidc-setup.sh <github-org> <github-repo>
# Example: bash eks/github-oidc-setup.sh security-guys board-service
# =============================================================================
set -euo pipefail

GITHUB_ORG="${1:-your-github-org}"
GITHUB_REPO="${2:-board-service}"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ROLE_NAME="board-service-github-actions-role"

echo "🔑 Setting up GitHub Actions OIDC for AWS"
echo "   GitHub: ${GITHUB_ORG}/${GITHUB_REPO}"
echo "   AWS Account: $ACCOUNT_ID"
echo ""

# ── 1. Create OIDC Provider ───────────────────────────────────────────────────
echo "[1/3] Creating GitHub OIDC provider..."

# Get GitHub OIDC thumbprint
THUMBPRINT=$(openssl s_client -servername token.actions.githubusercontent.com \
  -showcerts -connect token.actions.githubusercontent.com:443 < /dev/null 2>/dev/null \
  | openssl x509 -fingerprint -noout \
  | sed 's/://g' | sed 's/SHA1 Fingerprint=//' | tr '[:upper:]' '[:lower:]' \
  2>/dev/null || echo "6938fd4d98bab03faadb97b34396831e3780aea1")

aws iam create-open-id-connect-provider \
  --url "https://token.actions.githubusercontent.com" \
  --client-id-list "sts.amazonaws.com" \
  --thumbprint-list "$THUMBPRINT" \
  --no-cli-pager 2>/dev/null \
  || echo "   OIDC provider already exists, continuing..."

OIDC_PROVIDER_ARN="arn:aws:iam::${ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
echo "   ✅ OIDC Provider: $OIDC_PROVIDER_ARN"

# ── 2. Create IAM Role with Trust Policy ─────────────────────────────────────
echo ""
echo "[2/3] Creating IAM role with OIDC trust policy..."

TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${OIDC_PROVIDER_ARN}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${GITHUB_ORG}/${GITHUB_REPO}:ref:refs/heads/main"
        },
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF
)

# Create role
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document "$TRUST_POLICY" \
  --description "GitHub Actions OIDC role for board-service CI/CD" \
  --tags Key=Project,Value=board-service Key=ManagedBy,Value=script \
  --no-cli-pager 2>/dev/null \
  || echo "   Role already exists, updating trust policy..."

# ── 3. Attach Required Permissions ───────────────────────────────────────────
echo ""
echo "[3/3] Attaching IAM policies to role..."

# ECR: push images
aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"

# EKS: update kubeconfig + deploy
aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

# Create custom policy for minimal EKS deployment permissions
aws iam put-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-name "EKSDeployPolicy" \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Effect\": \"Allow\",
        \"Action\": [
          \"eks:DescribeCluster\",
          \"eks:ListClusters\"
        ],
        \"Resource\": \"arn:aws:eks:${REGION}:${ACCOUNT_ID}:cluster/*\"
      }
    ]
  }"

ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ GitHub Actions OIDC setup complete!"
echo ""
echo "Add these secrets to your GitHub repository:"
echo "  GitHub Repo → Settings → Secrets → Actions → New secret"
echo ""
echo "  Secret Name         | Value"
echo "  --------------------|----------------------------------------"
echo "  AWS_DEPLOY_ROLE_ARN | ${ROLE_ARN}"
echo "  AWS_ACCOUNT_ID      | ${ACCOUNT_ID}"
echo ""
echo "⚠️  Also add this to your EKS aws-auth ConfigMap:"
echo "   eksctl create iamidentitymapping \\"
echo "     --cluster board-service-cluster \\"
echo "     --region $REGION \\"
echo "     --arn $ROLE_ARN \\"
echo "     --group system:masters \\"
echo "     --username github-actions"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
