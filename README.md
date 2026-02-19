# tf-aws-fullstack

Full-stack app (FastAPI + Vue) on AWS, provisioned and deployed with **Terraform** and **GitHub Actions**. Focus: infrastructure-as-code, multi-environment (dev/prod), and CI/CD.

---

## Architecture overview

| Layer        | Technology                    | Notes                                      |
|-------------|-------------------------------|--------------------------------------------|
| **Frontend**| AWS Amplify                   | Vue SPA, branch-based deploys, custom domain optional |
| **API**     | ECS Fargate + ALB             | FastAPI, TLS via ACM when domain is set    |
| **Database**| RDS PostgreSQL               | Private subnets, no public IP              |
| **Storage** | S3                            | Uploads (e.g. CSV import)                  |
| **Secrets** | Secrets Manager + SSM         | DB credentials, CORS origins               |
| **State**   | S3 + DynamoDB                 | Terraform remote backend                   |

- **Networking:** one VPC per environment; public subnets (ALB), private-app (ECS), private-db (RDS).
- **DNS/TLS (optional):** Route53 hosted zone, ACM certs (frontend in us-east-1, backend in app region), alias records for API.
- **Observability:** CloudWatch Logs per service, ALB 5xx and ECS CPU/memory alarms.

Detailed design and module layout: **[infra/README.md](infra/README.md)**.

---

## Repository structure

```
.
├── .github/workflows/          # CI/CD
│   ├── terraform.yml           # Plan/apply per env (dev → dev, main → prod)
│   └── backend-deploy.yml     # Build/push ECR, run migrations, deploy ECS
├── backend/                    # FastAPI app
│   ├── src/
│   ├── migrations/            # Alembic
│   ├── Dockerfile
│   └── cron.Dockerfile
├── frontend/                   # Vue SPA (Amplify build)
├── infra/
│   ├── modules/               # Reusable Terraform modules
│   │   ├── alb, ecr, ecs, network, rds, s3, secrets, security
│   │   ├── dns-acm, amplify-frontend, observability, oidc
│   │   └── ...
│   ├── envs/
│   │   ├── dev/               # dev environment
│   │   └── prod/              # prod environment
│   └── bootstrap/             # Optional: tfstate backend (S3 + DynamoDB)
├── scripts/
│   └── run-ecs-migration.sh   # Run Alembic migration via ECS one-off task
└── README.md
```

---

## Prerequisites

- **AWS account** and credentials (for local runs or bootstrap).
- **Terraform** ≥ 1.x (used in CI; local use optional).
- **GitHub:** repo connected to Amplify (frontend); secrets configured for Terraform and backend deploy (see below).

---

## Getting started

### 1. Terraform backend (one-time)

Use the bootstrap in `infra/bootstrap/tfstate-backend` to create the S3 bucket and DynamoDB table for remote state, then configure `backend "s3"` in `infra/envs/<env>/backend.tf`. See **[infra/README.md — Terraform remote state backend](infra/README.md)**.

### 2. Environment variables and secrets

- Copy `infra/envs/dev/terraform.tfvars.example` to `terraform.tfvars` and fill in values (VPC CIDRs, DB password, `cors_origins`, `domain_name`, GitHub org/repo, etc.).
- **CI (GitHub):** store the contents of `terraform.tfvars` in secret `TFVARS_DEV` / `TFVARS_PROD` so the Terraform workflow can write them before `plan`/`apply`.

### 3. Apply infrastructure

- **Via CI:** push to `dev` or `main` (with changes under `infra/` or the workflow file) to run Terraform plan/apply for that environment.
- **Locally:**
  ```bash
  cd infra/envs/dev
  terraform init
  terraform plan -var-file=terraform.tfvars
  terraform apply -var-file=terraform.tfvars
  ```

### 4. Deploy application

- **Backend:** push to `dev` or `main` with changes under `backend/` or the backend workflow; pipeline builds images, pushes to ECR, runs DB migrations (one-off ECS task), then updates the ECS service.
- **Frontend:** Amplify builds on push (or manual) using repo and branch configured in Terraform (`amplify-frontend` module).

---

## CI/CD pipelines

| Workflow          | Trigger (paths)        | Branches | Actions |
|-------------------|------------------------|----------|--------|
| **terraform**     | `infra/**`, workflow   | `dev`, `main` | Init, fmt, validate, plan; **apply on push** (dev on `dev`, prod on `main`) |
| **backend-deploy**| `backend/**`, workflow | `dev`, `main` | ECR build/push, **run Alembic migration** (wait for task), ECS force-new-deployment |

- Terraform uses **OIDC** with GitHub Actions (`AWS_TERRAFORM_ROLE_ARN_DEV` / prod).
- Backend deploy uses a separate deploy role (`AWS_DEPLOY_ROLE_ARN_DEV` / prod) and ECR repo secrets.
- Migrations run as a one-off ECS Fargate task; the workflow waits for the task to finish and fails the job if the migration exits non-zero.

---

## Operations

### Run DB migration manually

When the pipeline is not an option, run Alembic via an ECS one-off task:

```bash
export ENV=dev
export CLUSTER=tf-aws-fullstack-dev-cluster
export TASKDEF=tf-aws-fullstack-dev-backend
./scripts/run-ecs-migration.sh
```

Requires AWS CLI configured and permissions to run ECS tasks and describe VPC/subnets/security groups.

### CORS

Allowed origins are stored in SSM (`/${name_prefix}/cors_origins`) and injected into the backend as `CORS_ORIGINS`. They are set via Terraform variable `cors_origins` in `terraform.tfvars` (passed into the **secrets** module). Changing `cors_origins` updates SSM and, via `cors_origins_hash`, triggers a new ECS task definition revision and rollout so running tasks pick up the new value.

### Custom domain

Set `domain_name` in `terraform.tfvars` (e.g. `example.com`). The **dns-acm** module can create the Route53 hosted zone (`create_zone = true`) and ACM certificates; point your registrar’s nameservers to the zone’s NS records. Frontend and API URLs are derived from this (e.g. `https://example.com`, `https://api.example.com`).

---

## Key documentation

- **[infra/README.md](infra/README.md)** — Architecture details, Terraform layout, bootstrap, backend state, checklist.

---

## License

See repository settings or root license file.
