#!/usr/bin/env bash
# =============================================================================
# AWS Security Controls Setup
# Enables: GuardDuty, CloudTrail, WAF (with Core Rule Set), S3 log bucket
#
# Usage: bash eks/security-setup.sh
# Prerequisites: AWS CLI configured, sufficient IAM permissions
# =============================================================================
set -euo pipefail

REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
LOG_BUCKET="board-service-security-logs-${ACCOUNT_ID}"
WAF_SCOPE="REGIONAL"  # Use CLOUDFRONT for CloudFront distributions

echo "🔐 AWS Security Controls Setup"
echo "   Account: $ACCOUNT_ID | Region: $REGION"
echo ""

# ── 1. S3 Bucket for Security Logs ───────────────────────────────────────────
echo "📦 [1/5] Creating S3 log bucket..."

# Create bucket (us-east-1 doesn't need LocationConstraint)
aws s3api create-bucket \
  --bucket "$LOG_BUCKET" \
  --region "$REGION" \
  --no-cli-pager 2>/dev/null || echo "   Bucket already exists, skipping."

# Block all public access
aws s3api put-public-access-block \
  --bucket "$LOG_BUCKET" \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket "$LOG_BUCKET" \
  --versioning-configuration Status=Enabled

# Enable encryption at rest
aws s3api put-bucket-encryption \
  --bucket "$LOG_BUCKET" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# 30-day lifecycle policy (keeps costs at ~$0)
aws s3api put-bucket-lifecycle-configuration \
  --bucket "$LOG_BUCKET" \
  --lifecycle-configuration '{
    "Rules": [{
      "ID": "delete-after-30-days",
      "Status": "Enabled",
      "Expiration": {"Days": 30},
      "Filter": {"Prefix": ""}
    }]
  }'

echo "   ✅ S3 bucket: s3://$LOG_BUCKET"

# ── 2. CloudTrail ─────────────────────────────────────────────────────────────
echo ""
echo "📋 [2/5] Enabling CloudTrail..."

TRAIL_NAME="board-service-trail"

# Apply bucket policy required by CloudTrail
aws s3api put-bucket-policy \
  --bucket "$LOG_BUCKET" \
  --policy "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Sid\": \"AWSCloudTrailAclCheck\",
        \"Effect\": \"Allow\",
        \"Principal\": {\"Service\": \"cloudtrail.amazonaws.com\"},
        \"Action\": \"s3:GetBucketAcl\",
        \"Resource\": \"arn:aws:s3:::${LOG_BUCKET}\"
      },
      {
        \"Sid\": \"AWSCloudTrailWrite\",
        \"Effect\": \"Allow\",
        \"Principal\": {\"Service\": \"cloudtrail.amazonaws.com\"},
        \"Action\": \"s3:PutObject\",
        \"Resource\": \"arn:aws:s3:::${LOG_BUCKET}/cloudtrail/AWSLogs/${ACCOUNT_ID}/*\",
        \"Condition\": {\"StringEquals\": {\"s3:x-amz-acl\": \"bucket-owner-full-control\"}}
      }
    ]
  }"

# Create or update trail
aws cloudtrail create-trail \
  --name "$TRAIL_NAME" \
  --s3-bucket-name "$LOG_BUCKET" \
  --s3-key-prefix "cloudtrail" \
  --include-global-service-events \
  --is-multi-region-trail \
  --enable-log-file-validation \
  --no-cli-pager 2>/dev/null \
  || echo "   Trail already exists, updating..."

# Start logging
aws cloudtrail start-logging --name "$TRAIL_NAME"

echo "   ✅ CloudTrail enabled → s3://$LOG_BUCKET/cloudtrail/"

# ── 3. GuardDuty ──────────────────────────────────────────────────────────────
echo ""
echo "🛡️  [3/5] Enabling GuardDuty..."

DETECTOR_ID=$(aws guardduty list-detectors \
  --region "$REGION" \
  --query 'DetectorIds[0]' \
  --output text 2>/dev/null || echo "")

if [ -z "$DETECTOR_ID" ] || [ "$DETECTOR_ID" == "None" ]; then
  DETECTOR_ID=$(aws guardduty create-detector \
    --enable \
    --region "$REGION" \
    --finding-publishing-frequency FIFTEEN_MINUTES \
    --features '[
      {"Name":"S3_DATA_EVENTS","Status":"ENABLED"},
      {"Name":"EKS_AUDIT_LOGS","Status":"ENABLED"},
      {"Name":"RUNTIME_MONITORING","Status":"ENABLED"}
    ]' \
    --query 'DetectorId' \
    --output text)
  echo "   Created new detector: $DETECTOR_ID"
else
  # Update existing detector to ensure all features enabled
  aws guardduty update-detector \
    --detector-id "$DETECTOR_ID" \
    --enable \
    --finding-publishing-frequency FIFTEEN_MINUTES \
    --features '[
      {"Name":"S3_DATA_EVENTS","Status":"ENABLED"},
      {"Name":"EKS_AUDIT_LOGS","Status":"ENABLED"},
      {"Name":"RUNTIME_MONITORING","Status":"ENABLED"}
    ]' \
    --no-cli-pager
  echo "   Updated existing detector: $DETECTOR_ID"
fi

echo "   ✅ GuardDuty enabled (Detector ID: $DETECTOR_ID)"

# ── 4. EventBridge Rule: GuardDuty → SNS (for Slack later) ───────────────────
echo ""
echo "📡 [4/5] Creating EventBridge rule for GuardDuty HIGH/CRITICAL findings..."

# Create SNS topic for security alerts
SNS_TOPIC_ARN=$(aws sns create-topic \
  --name "board-service-security-alerts" \
  --region "$REGION" \
  --query 'TopicArn' \
  --output text)

# EventBridge rule: capture HIGH and CRITICAL GuardDuty findings
aws events put-rule \
  --name "guardduty-high-severity-findings" \
  --event-pattern '{
    "source": ["aws.guardduty"],
    "detail-type": ["GuardDuty Finding"],
    "detail": {
      "severity": [
        {"numeric": [">=", 7]}
      ]
    }
  }' \
  --state ENABLED \
  --description "Capture GuardDuty findings with severity >= 7 (HIGH/CRITICAL)" \
  --region "$REGION" \
  --no-cli-pager

# Point rule to SNS topic
aws events put-targets \
  --rule "guardduty-high-severity-findings" \
  --targets "[{\"Id\": \"SecurityAlertsSNS\", \"Arn\": \"${SNS_TOPIC_ARN}\"}]" \
  --region "$REGION" \
  --no-cli-pager

echo "   ✅ EventBridge rule created → SNS: $SNS_TOPIC_ARN"

# ── 5. AWS WAF ────────────────────────────────────────────────────────────────
echo ""
echo "🧱 [5/5] Creating WAF Web ACL with Core Rule Set..."

WAF_ACL_ID=$(aws wafv2 create-web-acl \
  --name "board-service-waf" \
  --scope "$WAF_SCOPE" \
  --region "$REGION" \
  --default-action '{"Allow":{}}' \
  --visibility-config '{
    "SampledRequestsEnabled": true,
    "CloudWatchMetricsEnabled": true,
    "MetricName": "BoardServiceWAF"
  }' \
  --rules '[
    {
      "Name": "AWSManagedRulesCommonRuleSet",
      "Priority": 1,
      "OverrideAction": {"None": {}},
      "Statement": {
        "ManagedRuleGroupStatement": {
          "VendorName": "AWS",
          "Name": "AWSManagedRulesCommonRuleSet"
        }
      },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "AWSManagedRulesCommonRuleSet"
      }
    },
    {
      "Name": "AWSManagedRulesKnownBadInputsRuleSet",
      "Priority": 2,
      "OverrideAction": {"None": {}},
      "Statement": {
        "ManagedRuleGroupStatement": {
          "VendorName": "AWS",
          "Name": "AWSManagedRulesKnownBadInputsRuleSet"
        }
      },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "AWSManagedRulesKnownBadInputs"
      }
    },
    {
      "Name": "RateLimitRule",
      "Priority": 3,
      "Action": {"Block": {}},
      "Statement": {
        "RateBasedStatement": {
          "Limit": 1000,
          "AggregateKeyType": "IP"
        }
      },
      "VisibilityConfig": {
        "SampledRequestsEnabled": true,
        "CloudWatchMetricsEnabled": true,
        "MetricName": "RateLimitRule"
      }
    }
  ]' \
  --query 'Summary.Id' \
  --output text \
  --no-cli-pager 2>/dev/null || echo "WAF ACL may already exist")

# Enable WAF logging to S3 (via Kinesis Firehose — required by WAF)
echo "   ℹ️  WAF logging requires Kinesis Firehose. Run eks/waf-logging-setup.sh after associating WAF with ALB."

echo "   ✅ WAF Web ACL created (ID: $WAF_ACL_ID)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Security setup complete!"
echo ""
echo "Summary:"
echo "  📦 S3 Log Bucket : s3://$LOG_BUCKET"
echo "  📋 CloudTrail    : $TRAIL_NAME (multi-region, all services)"
echo "  🛡️  GuardDuty     : Detector $DETECTOR_ID (EKS + S3 + Runtime)"
echo "  📡 EventBridge   : HIGH/CRITICAL findings → SNS"
echo "  🧱 WAF           : Core Rule Set + Known Bad Inputs + Rate Limit (1000 req/IP)"
echo ""
echo "Next steps:"
echo "  1. Associate WAF with your ALB: eks/waf-associate-alb.sh"
echo "  2. Subscribe email to SNS alerts:"
echo "     aws sns subscribe --topic-arn '$SNS_TOPIC_ARN' --protocol email --notification-endpoint your@email.com"
echo "  3. Run eks/github-oidc-setup.sh to configure GitHub Actions OIDC"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
