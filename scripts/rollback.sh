#!/bin/bash
echo "🚨 ====== [CRITICAL WARNING] Initializing Fleet Rollback Mitigation Actions ====== 🚨"
echo "Target Auto Scaling Group Fleet: $AWS_ASG_NAME"

echo "[1/2] Terminating active instance refresh pipelines currently executing..."
aws autoscaling cancel-instance-refresh --auto-scaling-group-name "$AWS_ASG_NAME" || true

echo "Waiting 30 seconds for AWS to finalize cancellation..."
sleep 30

echo "[2/2] Launching emergency rollback recovery sequence across compute fleet..."
aws autoscaling start-instance-refresh --auto-scaling-group-name "$AWS_ASG_NAME" --strategy Rollback
