#!/bin/bash
# ------------------------------------------------------------------------------
# StartTech Automation Script: Frontend S3 & CloudFront Edge Sync Execution
# ------------------------------------------------------------------------------
set -e

# Configuration Definitions (Parsed dynamically or falling back to defaults)
BUCKET_NAME=${AWS_S3_FRONTEND_BUCKET:-"starttech-production-frontend-vault"}
DISTRIBUTION_ID=${AWS_CLOUDFRONT_DIST_ID:-"EXXXXXXXEXAMPLE"}
FRONTEND_DIR="$(dirname "$0")/../frontend"

echo "====== [STARTTECH CD] Initializing Frontend Compilation Layer ======"
cd "$FRONTEND_DIR"

# Step 1: Clean build environment and compile assets
echo "[1/3] Fetching runtime dependencies & compiling static distribution..."
npm install
npm run build # Vite compiles assets directly to the 'dist/' folder

# Step 2: Push static build outputs directly to S3
echo "[2/3] Executing absolute mirror sync to AWS S3 Bucket: ${BUCKET_NAME}..."
aws s3 sync dist/ s3://"$BUCKET_NAME"/ --delete

# Step 3: Evict Edge caches across CloudFront distribution network
echo "[3/3] Triggering Edge cache invalidation on CloudFront: ${DISTRIBUTION_ID}..."
aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*"

echo "====== [SUCCESS] Frontend application sync complete! ======"
