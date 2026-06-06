# StartTech Infrastructure Operations & Incident Mitigation Runbook

This manual serves as the standard operational directive for maintaining, debugging, and scaling the StartTech multi-tier application ecosystem.

---

## 🚨 Incident Management Protocols

### 1. Handling Automated CloudWatch CPU or Health Alarms
* **Symptom:** CloudWatch metric alarms trip on compute tier stress metrics (`CPUUtilization >= 80%`) or ALB Target Group drops beneath the minimum healthy node capacity.
* **Triage Procedures:**
  1. Authenticate into the AWS Console and navigate to **CloudWatch Logs Insights**.
  2. Run the diagnostic log query string to isolate backend panics or application loop errors:
     ```text
     fields @timestamp, @message
     | filter @message like /FATAL/ or @message like /ERROR/
     | sort @timestamp desc
     | limit 50
     ```
  3. Inspect the active Auto Scaling Group instances to verify that scaling cooling profiles are spinning up remediation nodes successfully.

### 2. Emergency Post-Deployment Application Outage
* **Symptom:** A fresh deployment triggers high-velocity `502 Bad Gateway` or `504 Gateway Timeout` errors on the load balancer, or the automated pipeline fails during smoke tests.
* **Mitigation / Rollback Execution:**
  If the automated GitHub Action pipeline doesn't catch the failure or if manual rollback intervention is required, run the local recovery shell from your terminal:
  ```bash
  cd /home/fanuel/projects/starttech-application
  ./scripts/rollback.sh

This immediately stops any pending rolling updates and shifts the fleet back to a known stable operating baseline.

⚙️ Standard Routine Maintenance
1. Manual Secrets Rotation Lifecycle
When security requirements demand a rotation of your system tokens (e.g., MongoDB Atlas keys, AWS access profiles):

Navigate to your repository page on GitHub.

Select Settings -> Secrets and variables -> Actions.

Update the required secret values (AWS_SECRET_ACCESS_KEY, etc.).

To apply the new credentials without altering code, run a manual workflow dispatch or commit an empty change to re-trigger the deployment:

Bash
git commit --allow-empty -m "ops: manual pipeline trigger for credentials rotation"
git push origin main
2. Manual Frontend Cache Purging
If a critical patch needs to bypass CloudFront edge caching timelines and push immediately to live users, run the standalone edge eviction loop:

Bash
export AWS_CLOUDFRONT_DIST_ID="YOUR_LIVE_DISTRIBUTION_ID"
export AWS_S3_FRONTEND_BUCKET="YOUR_LIVE_S3_BUCKET_NAME"
./scripts/deploy-frontend.sh





