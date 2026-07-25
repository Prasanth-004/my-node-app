# 🚀 Production-Grade AWS ECS Fargate CI/CD Pipeline

![AWS](https://img.shields.io/badge/AWS-ECS%20Fargate-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Hardened%20Alpine-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-OIDC%20Auth-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![NodeJS](https://img.shields.io/badge/Node.js-18%20Alpine-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)
![Jest](https://img.shields.io/badge/Jest-Automated%20Tests-C21325?style=for-the-badge&logo=jest&logoColor=white)

A production-grade, zero-downtime automated CI/CD pipeline deploying containerized Node.js microservices to **Amazon ECS Fargate** using **Native Blue/Green Rolling Deployments**, OpenID Connect (**OIDC**) federated authentication, **Amazon ECR**, **Application Load Balancing (ALB)**, **CloudWatch Logs**, and **AWS SNS Notifications**.

---

## 🏛️ Master Architecture Diagram

```mermaid
flowchart TD
    subgraph Dev ["Developer Workspace"]
        A["Git Commit & Push to main"] --> B["GitHub Repository (Prasanth-004/my-node-app)"]
    end

    subgraph CI_CD ["GitHub Actions CI/CD Pipeline"]
        B --> C["Trigger Workflow (.github/workflows/deploy.yml)"]
        C --> D["Job 1: Run Automated Jest Tests"]
        D -->|Pass| E["Job 2: Authenticate via IAM OIDC (No Static Keys)"]
        E --> F["Build & Tag Docker Image (SHA & latest)"]
        F --> G["Push Container Image to Amazon ECR"]
        G --> H["Job 3: Register ECS Task Definition & Update Service"]
        H --> I["Native ECS Rolling Blue/Green Update"]
        I --> J["Automated ALB Health Verification Probe"]
        J --> K["Job 4: Publish Status Alert to AWS SNS"]
    end

    subgraph AWS ["AWS Cloud Infrastructure (ap-south-2)"]
        subgraph Registry ["Amazon ECR"]
            ECR["ECR Repo: my-node-app"]
        end

        subgraph Networking ["VPC Networking & Load Balancing"]
            ALB["Application Load Balancer (ecs-alb)"]
            TG_Blue["Blue Target Group (Port 3000)"]
            TG_Green["Green Target Group (Port 3000)"]
            ALB -->|Port 80 Production| TG_Blue
            ALB -.->|Port 8080 Staging| TG_Green
        end

        subgraph Compute ["Amazon ECS Fargate"]
            ECS_Cluster["ECS Cluster: my-ecs-cluster"]
            subgraph ECS_Service ["ECS Service: my-node-app-service"]
                Fargate_Tasks["2 Fargate Tasks (0.25 vCPU, 512MB RAM)"] --> TG_Blue
            end
        end

        subgraph Observability ["Monitoring & Notifications"]
            CW["CloudWatch Log Group (/ecs/my-node-app)"]
            SNS["SNS Topic: deployment-notifications"]
        end
    end

    G --> ECR
    Fargate_Tasks -.-> CW
    K --> SNS
```

---

## 🌟 Key Features & Enterprise Best Practices

- **Zero-Downtime Native Blue/Green Deployments**: Uses ECS rolling deployment controller (`minimumHealthyPercent=100`, `maximumPercent=200`) bound to dual ALB target groups (`blue-target-group` and `green-target-group`).
- **Zero Static Credentials (OIDC Federation)**: GitHub Actions authenticates to AWS STS using OpenID Connect (`aws-actions/configure-aws-credentials@v4`) and short-lived session tokens scoped strictly to `repo:Prasanth-004/my-node-app:*`.
- **Production-Hardened Docker Security**: Built on `node:18-alpine` executing as non-root unprivileged user `nodejs`, reducing container attack surface and containing kernel namespace privileges.
- **Automated Quality Guardrails**: Integrated Jest test suite (`app.test.js`) enforcing 100% pass rates on API endpoints before container image compilation.
- **Real-Time Observability & Alerts**: Centralized container logging in CloudWatch (`/ecs/my-node-app`) and automated deployment notifications sent via Amazon SNS (`deployment-notifications`).

---

## 📂 Repository Structure

```text
.
├── .github/
│   └── workflows/
│       └── deploy.yml              # Production GitHub Actions Pipeline Definition
├── iam/
│   ├── github-oidc-trust-policy.json # IAM OIDC Trust Policy
│   ├── GitHubECRPolicy.json        # ECR Push & Auth Policy
│   ├── GitHubECSPolicy.json        # ECS Deployment & SNS Policy
│   └── GitHubPassRolePolicy.json   # IAM PassRole Policy
├── app.js                          # Express.js Microservice Server & REST Endpoints
├── app.test.js                     # Jest Integration Test Suite
├── Dockerfile                      # Hardened Multi-Stage Dockerfile (Non-root user)
├── .dockerignore                   # Docker Build Context Exclusions
├── package.json                    # Node.js Manifest & Test Scripts
└── taskdef.json                    # ECS Task Definition Blueprint
```

---

## 🔧 AWS Infrastructure Specifications

| Infrastructure Component | Resource Name / Identifier | Region |
| :--- | :--- | :--- |
| **AWS Region** | `ap-south-2` (Asia Pacific - Hyderabad) | `ap-south-2` |
| **AWS Account ID** | `351682129477` | |
| **Amazon ECR Repository** | `my-node-app` | `ap-south-2` |
| **Application Load Balancer** | `ecs-alb` | `ap-south-2` |
| **ALB Security Group** | `ecs-alb-sg` (`sg-0012aaabd9c497a1b`) | `ap-south-2` |
| **Blue Target Group** | `blue-target-group` (Port 3000, `/health`) | `ap-south-2` |
| **Green Target Group** | `green-target-group` (Port 3000, `/health`) | `ap-south-2` |
| **Amazon ECS Cluster** | `my-ecs-cluster` (AWS Fargate) | `ap-south-2` |
| **Amazon ECS Service** | `my-node-app-service` (2 Desired Tasks) | `ap-south-2` |
| **CloudWatch Log Group** | `/ecs/my-node-app` | `ap-south-2` |
| **Amazon SNS Topic** | `deployment-notifications` | `ap-south-2` |

---

## 🧪 Local Testing & Development

### 1. Install Dependencies
```bash
npm install
```

### 2. Run Test Suite
```bash
npm test
```

### 3. Start Local Server
```bash
npm start
```

### 4. Test Local Endpoints
```bash
curl http://localhost:3000/
curl http://localhost:3000/health
curl http://localhost:3000/api/users
```

---

## 🌐 Live Production Endpoints

- 🚀 **Live Production API**: [http://ecs-alb-708781990.ap-south-2.elb.amazonaws.com](http://ecs-alb-708781990.ap-south-2.elb.amazonaws.com)
- 🏥 **Health Check Endpoint**: [http://ecs-alb-708781990.ap-south-2.elb.amazonaws.com/health](http://ecs-alb-708781990.ap-south-2.elb.amazonaws.com/health)
- 👥 **Users API Endpoint**: [http://ecs-alb-708781990.ap-south-2.elb.amazonaws.com/api/users](http://ecs-alb-708781990.ap-south-2.elb.amazonaws.com/api/users)

---

## 👥 Authors & Team

- **Prasanth**
- **Yashu**
