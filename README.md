# StartTech Application Deployment Platform (`starttech-application`)

Welcome to the central application source repository for the StartTech platform. This workspace houses the frontend interface engine, backend API components, system automation scripts, and GitHub Actions continuous integration pipelines.

---

## 📂 Repository Structure Alignment

This repository complies exactly with the mandated structural blueprint:

```text
starttech-application/
├── .github/
│   └── workflows/
│       ├── frontend-ci-cd.yml      # React compilation & S3 sync pipeline
│       └── backend-ci-cd.yml       # Go verification, Docker build, & ASG deploy
├── backend/                        # Golang core application API source
├── frontend/                       # Vite + TypeScript React web application
└── scripts/                        # Automated engineering operations shells
    ├── deploy-frontend.sh          # Frontend build and CDN eviction runner
    ├── deploy-backend.sh           # ECR image compilation and ASG refresh runner
    ├── health-check.sh             # Live ALB endpoint validation probe
    └── rollback.sh                 # Emergency disaster recovery rollback engine


🛠️ Local Development & Operations
1. Executing Local Automation Runners
Every automation script is located within the scripts/ directory and is pre-configured with executable file permissions. To execute deployments manually, pass the runtime context parameters as environment variables:

Bash
# Execute manual frontend builds and sync to S3
AWS_S3_FRONTEND_BUCKET="your-bucket-name" AWS_CLOUDFRONT_DIST_ID="your-dist-id" ./scripts/deploy-frontend.sh

# Trigger manual backend containerization and fleet rotation
AWS_ACCOUNT_ID="123456789012" AWS_ECR_REPOSITORY="your-repo" AWS_ASG_NAME="your-asg" ./scripts/deploy-backend.sh
2. Runtime Environment Declarations
Frontend: The React layer manages production configurations using environmental parameters inside frontend/.env.production.

Backend: The Golang application reads environmental parameters (PORT, ENV, MONGO_URI, REDIS_HOST) at initialization via container entry points.

🚀 CI/CD Automated Pipelines Control Plane
The repository features two independent, decoupled automation matrices mapping directly to structural code modifications:

Frontend Flow (frontend-ci-cd.yml)
Trigger Condition: Pushes or Pull Requests impacting files inside the frontend/ directory.

Quality Stage: Installs Node.js matrices, fetches dependencies via npm ci, and executes security risk reviews (npm audit).

Delivery Stage: Compiles production assets via Vite, streams artifacts to Amazon S3, and triggers an explicit global cache invalidation sweep across CloudFront edges.

Backend Flow (backend-ci-cd.yml)
Trigger Condition: Pushes or Pull Requests impacting files inside the backend/ directory.

Quality Stage: Initializes the Go development runtime, validates syntax mapping errors using go vet, and tracks security posture via gosec.

Delivery Stage: Packs application layers using an optimized multi-stage Dockerfile, authenticates against AWS ECR, ships container versions upstream, and kicks off an ASG instance refresh.

Verification Loop: Fires the live health check prober. If validation fails, it instantly triggers an emergency rollback configuration.
