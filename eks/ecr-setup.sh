#!/usr/bin/env bash
# =============================================================================
# ECR Repository Setup for board-service
# Creates repositories for backend and frontend images
#
# Usage: bash eks/ecr-setup.sh
# =============================================================================
set -euo pipefail

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

REPOS=("board-backend" "board-frontend")

echo "🐳 Setting up ECR repositories..."
echo "   Account: $ACCOUNT_ID | Region: $REGION"
echo ""

for REPO in "${REPOS[@]}"; do
  echo "Creating repository: $REPO"
  aws ecr create-repository \
    --repository-name "$REPO" \
    --region "$REGION" \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256 \
    --image-tag-mutability MUTABLE \
    --no-cli-pager 2>/dev/null \
    || echo "   Repository $REPO already exists, skipping."

  # Apply lifecycle policy: keep only last 10 images to save cost
  aws ecr put-lifecycle-policy \
    --repository-name "$REPO" \
    --region "$REGION" \
    --lifecycle-policy-text '{
      "rules": [
        {
          "rulePriority": 1,
          "description": "Keep last 10 images",
          "selection": {
            "tagStatus": "any",
            "countType": "imageCountMoreThan",
            "countNumber": 10
          },
          "action": {"type": "expire"}
        }
      ]
    }' \
    --no-cli-pager

  echo "   ✅ ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ECR repositories ready!"
echo ""
echo "Image URIs:"
for REPO in "${REPOS[@]}"; do
  echo "  ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:latest"
done
echo ""
echo "Add to GitHub Secrets:"
echo "  AWS_ACCOUNT_ID = $ACCOUNT_ID"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
