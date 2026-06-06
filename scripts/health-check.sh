#!/bin/bash
echo "====== [STARTTECH DIAGNOSTICS] Commencing Health Check Routing Checks ======"
echo "Target ALB Probe Endpoint: $STARTTECH_ALB_URL"

MAX_RETRIES=12
RETRY_INTERVAL=10

for ((i=1; i<=MAX_RETRIES; i++)); do
    echo "Probing application health (Attempt $i/$MAX_RETRIES)..."
    HTTP_STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" "$STARTTECH_ALB_URL")

    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "✅ [SUCCESS] Health target validated! System is operational."
        exit 0
    fi

    echo "⚠️ [WARN] Response mapping returned standard error code: $HTTP_STATUS. Retrying in ${RETRY_INTERVAL}s..."
    sleep $RETRY_INTERVAL
done

echo "❌ [FATAL] Critical system outage detected! Health target failed validation after $MAX_RETRIES execution loops."
exit 1
