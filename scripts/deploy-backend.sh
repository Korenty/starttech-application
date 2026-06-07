#!/bin/bash
set -e

# --- SAFETY CHECK ---
if [ -z "$AWS_ASG_NAME" ]; then
  echo "ERROR: AWS_ASG_NAME is not set! Check your GitHub Secrets."
  exit 1
fi
# --------------------

# ... rest of your script ...

#!/bin/bash
# ------------------------------------------------------------------------------
# StartTech Automation Script: Backend Multi-Stage Build & ASG Rolling Update
# ------------------------------------------------------------------------------
set -e

# Configuration Definitions
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID:-"123456789012"}
AWS_REGION=${AWS_REGION:-"us-east-1"}
ECR_REPO=${AWS_ECR_REPOSITORY:-"starttech-backend-api"}
ASG_NAME=${AWS_ASG_NAME:-"starttech-production-asg"}
IMAGE_TAG=$(date +%Y%m%d%H%M%S)
BACKEND_DIR="$(dirname "$0")/../backend"

echo "====== [STARTTECH CD] Initializing Containerized Backend Layer ======"
cd "$BACKEND_DIR"

# Step 1: Securely authenticate Docker with remote AWS ECR Registry
echo "[1/4] Authenticating with AWS ECR Registry at port ${AWS_REGION}..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID".dkr.ecr."$AWS_REGION".amazonaws.com

# Step 2: Assemble localized container image trees
echo "[2/4] Assembling production multi-stage compilation image tag: ${IMAGE_TAG}..."
docker build -t "$ECR_REPO":"$IMAGE_TAG" .
docker tag "$ECR_REPO":"$IMAGE_TAG" "$AWS_ACCOUNT_ID".dkr.ecr."$AWS_REGION".amazonaws.com/"$ECR_REPO":"$IMAGE_TAG"
docker tag "$ECR_REPO":"$IMAGE_TAG" "$AWS_ACCOUNT_ID".dkr.ecr."$AWS_REGION".amazonaws.com/"$ECR_REPO":latest

# Step 3: Ship finalized images upstream
echo "[3/4] Shipping compiled images to remote ECR registry target pool..."
docker push "$AWS_ACCOUNT_ID".dkr.ecr."$AWS_REGION".amazonaws.com/"$ECR_REPO":"$IMAGE_TAG"
docker push "$AWS_ACCOUNT_ID".dkr.ecr."$AWS_REGION".amazonaws.com/"$ECR_REPO":latest

# Step 4: Force a zero-downtime rolling update via ASG Instance Refresh
echo "[4/4] Executing zero-downtime rolling update across active fleet: ${ASG_NAME}..."
aws autoscaling start-instance-refresh \
    --auto-scaling-group-name "$ASG_NAME" \
    --preferences '{"MinHealthyPercentage": 50, "InstanceWarmup": 300}'

echo "====== [SUCCESS] Backend image push and fleet rotation sequence deployed! ======"
