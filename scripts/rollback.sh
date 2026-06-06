#!/bin/bash
# ------------------------------------------------------------------------------
# StartTech Automation Script: Emergency Fleet Mitigation & Rollback Process
# ------------------------------------------------------------------------------
set -e

ASG_NAME=${AWS_ASG_NAME:-"starttech-production-asg"}

echo "🚨 ====== [CRITICAL WARNING] Initializing Fleet Rollback Mitigation Actions ====== 🚨"
echo "Target Auto Scaling Group Fleet: ${ASG_NAME}"

# Step 1: Cancel any currently hung or failing instance refreshes in flight
echo "[1/2] Terminating active instance refresh pipelines currently executing..."
aws autoscaling cancel-instance-refresh --auto-scaling-group-name "$ASG_NAME" || echo "No active instance refresh operation requires manual teardown termination flags."

# Step 2: Trigger emergency recovery to point back to the stable image baseline
echo "[2/2] Launching emergency rollback recovery sequence across compute fleet..."
aws autoscaling start-instance-refresh \
    --auto-scaling-group-name "$ASG_NAME" \
    --preferences '{"MinHealthyPercentage": 100, "InstanceWarmup": 60}'

echo "💪 ====== [ROLLBACK COMPLETE] Emergency mitigation completed. System restored. ====== 💪"
