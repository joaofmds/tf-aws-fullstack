# Resumo Executivo

- Arquitetura multi-ambiente (dev/prod) com isolamento de rede por VPC e subnets dedicadas por camada (pública/app/db).
- Backend FastAPI em ECS Fargate com ALB público, TLS opcional por ACM/Route53 e autoscaling por CPU.
- Cron separado como ECS Scheduled Task (EventBridge), sem container always-on.
- RDS PostgreSQL privado (sem IP público), criptografado, backup e políticas diferentes para dev/prod.
- Uploads escolhidos em **S3** (mais barato/escala/durabilidade), com refatoração para processamento em memória + persistência opcional no bucket.
- Segredos/parametrização via Secrets Manager (credenciais DB) e SSM Parameter Store (CORS), sem `.env` em runtime.
- Observabilidade mínima com CloudWatch Logs por serviço, alarmes de 5xx do ALB e CPU/Mem do ECS.
- IAM least privilege separando execution role x task role e papéis de OIDC para GitHub Actions.
- CI/CD com Terraform plan/apply, build/push para ECR, deploy ECS e execução de migração Alembic via one-off task.
- Frontend no Amplify com variáveis por branch, rewrite SPA e CORS explícito para domínio do Amplify.

## Arquitetura

```text
                        Internet
                           |
                    +------+------+
                    |  Route53*   |
                    +------+------+
                           |
                    +------+------+
                    | ACM cert*   |
                    +------+------+
                           |
                    +------+------+
                    |   ALB (pub) |
                    +------+------+
                           |
        +------------------+------------------+
        |                                     |
+-------+--------+                   +--------+-------+
| ECS Service    |                   | ECS Scheduled  |
| FastAPI        |                   | Task (cron)    |
| private subnet |                   | private subnet |
+-------+--------+                   +--------+-------+
        |                                     |
        +------------------+------------------+
                           |
                    +------+------+
                    | S3 uploads  |
                    +-------------+
                           |
                    +------+------+
                    | RDS Postgres|
                    | private DB  |
                    +-------------+

* opcional/parametrizável para domínio próprio
```

## Decisões técnicas

1. **Uploads: S3 (escolha final)**
   - Prós: durável, barato, não acopla tasks, lifecycle policy, fácil auditoria e integração com eventos.
   - Contras: precisa refatorar código para API S3.
   - EFS só faria sentido para requisito POSIX compartilhado.

2. **Deploy ECS: rolling update**
   - Escolhido por simplicidade e menor custo operacional.
   - Blue/green pode ser habilitado depois para zero-downtime mais rígido.

3. **Migrações DB: Alembic + one-off task no pipeline**
   - Evita depender de init scripts de container do Postgres.
   - Processo reproduzível em dev/prod e auditável no CI/CD.

4. **Domínio próprio: opcional**
   - Infra aceita `acm_certificate_arn`; sem ele, ALB atende HTTP.
   - Com domínio próprio: Route53 alias + listener HTTPS.

## Estrutura Terraform

```text
infra/
  modules/
    alb/
    ecr/
    ecs/
    network/
    observability/
    oidc/
    rds/
    s3/
    secrets/
    security/
  envs/
    dev/
      backend.tf
      main.tf
      providers.tf
      versions.tf
      variables.tf
      outputs.tf
      terraform.tfvars.example
    prod/
      ... (mesma estrutura)
```

## Passo a passo

1. Criar buckets/tabela para backend remoto do Terraform (`tfstate` + DynamoDB lock).
2. Copiar `terraform.tfvars.example` para `terraform.tfvars` em cada ambiente.
3. Ajustar valores (CIDRs, domínio, GitHub org/repo, senha DB).
4. Executar:
   - `cd infra/envs/dev && terraform init && terraform plan -var-file=terraform.tfvars`
   - `terraform apply -var-file=terraform.tfvars`
5. Repetir em `prod`.

## Refatorações aplicadas no app

- Upload CSV agora processa em memória com limite (`UPLOAD_MAX_MB`) e persiste no S3 (`UPLOAD_S3_BUCKET`) quando configurado.
- Health check `/healthz` com teste de conectividade no banco.
- CORS vindo de `CORS_ORIGINS` (lista explícita), sem wildcard.
- SQLAlchemy com pool tuning (`pool_pre_ping`, recycle etc.).
- Headers de segurança básicos na API.
- Cron refatorado para limpeza de objetos antigos no S3.
- Alembic adicionado com migration inicial de schema/tabela `product.product`.

## Checklist pós-deploy

- [ ] ALB healthy no target group (`/healthz`).
- [ ] ECS service estável e autoscaling ativo.
- [ ] Task agendada do cron executando no EventBridge.
- [ ] Migração Alembic executa `upgrade head` com sucesso.
- [ ] Upload/import CSV funcional (frontend Amplify -> ALB -> ECS -> RDS/S3).
- [ ] CORS válido para os domínios dev/prod.
- [ ] Alarmes de CloudWatch criados e visíveis.
