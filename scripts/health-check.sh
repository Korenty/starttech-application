#!/bin/bash
# ------------------------------------------------------------------------------
# StartTech Automation Script: Fleet Health Probe Verification
# ------------------------------------------------------------------------------
set -e

ALB_ENDPOINT=${STARTTECH_ALB_URL:-"http://localhost:8080/health"}
MAX_ATTEMPTS=5
WAIT_INTERVAL=10

echo "====== [STARTTECH DIAGNOSTICS] Commencing Health Check Routing Checks ======"
echo "Target ALB Probe Endpoint: ${ALB_ENDPOINT}"

for ((attempt=1; attempt<=MAX_ATTEMPTS; attempt++)); do
    echo "Probing application health (Attempt ${attempt}/${MAX_ATTEMPTS})..."
    
    # Extract HTTP status response code directly from target headers
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$ALB_ENDPOINT" || echo "000")
    
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "🎉 [SUCCESS] Live application cluster verified healthy! Received HTTP status 200."
        exit 0
    fi
    
    echo "⚠️ [WARN] Response mapping returned standard error code: ${HTTP_STATUS}. Retrying in ${WAIT_INTERVAL}s..."
    sleep "$WAIT_INTERVAL"
done

echo "❌ [FATAL] Critical system outage detected! Health target failed validation after ${MAX_ATTEMPTS} execution loops."
exit 1
