# StartTech Core Application Architecture Design

This document details the architectural layout, data pipelines, and operational topographies governing the production instance of the StartTech Full-Stack platform.

---

## 🗺️ High-Availability System Topography

The platform is engineered around a decoupled, highly available multi-tier system distributed across multiple AWS Availability Zones (AZs) for maximum fault tolerance.

### 1. Edge & Presentation Layer (Decoupled Frontend)
* **Hosting Environment:** Static React production build assets are housed securely inside an isolated Amazon S3 bucket (`aws_s3_bucket_public_access_block` active).
* **Content Delivery Network:** An Amazon CloudFront distribution handles edge delivery globally.
* **Access Control:** Direct public access to the S3 bucket is completely blocked. CloudFront signs upstream requests dynamically using **Origin Access Control (OAC)** via AWS Signature Version 4.

### 2. Compute Proxy Layer (Three-Tier Backend API)
* **Ingress Traffic Routing:** Public traffic is intercepted exclusively by an external Application Load Balancer (ALB) tracking health targets across public subnets.
* **Elastic Processing Fleet:** The Golang API runtime engine is executed on an EC2-driven Auto Scaling Group (ASG) deployed entirely within private subnets.
* **Network Isolation:** Compute nodes accept traffic exclusively on port `8080` originating from the security boundary of the ALB proxy.

### 3. State & Persistence Storage Layer (Data Tier)
* **Session Cache Matrix:** High-velocity caching and transient session tracking run inside a multi-AZ Amazon ElastiCache Redis cluster deployed across isolated database subnets.
* **Data Persistence Core:** Transaction records and operational logs persist inside a distributed MongoDB Atlas cluster, decoupled from the localized VPC state.

---

## 🔄 End-to-End Data Traffic Flow

```text
[ Global User Access ] 
         │
         ├──► (Static Assets / Web App UI) ──► [ Amazon CloudFront CDN ] ──► [ Secure S3 Bucket via OAC ]
         │
         └──► (Dynamic API Requests) ───────► [ Application Load Balancer ]
                                                         │ (Port 8080 Routing via Public Subnets)
                                                         ▼
                                             [ Auto Scaling Group Fleet ] (Private Compute Subnets)
                                                   │              │
                                                   │ (Port 6379)  │ (Port 27017 Outbound TLS)
                                                   ▼              ▼
                                            [ Amazon Redis ]   [ MongoDB Atlas Cloud Core ]




🔒 Security Infrastructure Matrix
Least-Privilege Networking: Subnet layers enforce a rigid unidirectional outbound flow. Compute nodes have zero direct public IP mapping.

Vulnerability Guardrails: Code bases pass through static analysis scanning (npm audit for frontend, gosec for Golang) prior to containerization or edge distribution.

State Verification: All cross-tier authentication strings, MongoDB connection tokens, and AWS execution keys reside inside secure environment variables managed natively via GitHub Secrets and runtime task definitions.
