# Terraform Module: amplify-frontend

Módulo Terraform production-grade para provisionar frontend no AWS Amplify integrado a um backend em ECS/ALB.

## Recursos criados

- `aws_amplify_app`
- `aws_amplify_branch` (branch principal do ambiente)
- `aws_amplify_domain_association` (opcional)
- `aws_amplify_webhook` (opcional)

## Características

- Suporte a monorepo (`app_root`, default `frontend`).
- Build spec padrão para `vite` e `nextjs`, com override por `amplify_build_spec`.
- Rewrites/redirects para SPA (suporte a refresh sem 404).
- Headers de segurança (HSTS, CSP, X-Frame-Options, etc.).
- Tags padronizadas.
- PR previews configuráveis.
- Basic Auth opcional para preview branches.
- Integração com backend via env var:
  - `VITE_API_BASE_URL` (Vite/React)
  - `NEXT_PUBLIC_API_BASE_URL` (Next.js)

## Modo de integração de repositório

### 1) `app_mode = "connected"` (padrão)

Amplify conecta direto ao GitHub (recomendado). Requer:

- `repository_url`
- `repository_branch`
- `github_oauth_token`

### 2) `app_mode = "webhook"`

Para pipelines externos. Amplify não conecta ao repo; o módulo cria webhook opcional para disparo de deploy.

## Variáveis importantes

- `backend_base_url`: URL HTTPS do backend (ALB/CloudFront/etc).
- `custom_domain_enabled` + `domain_name`: ativa domínio customizado.
  - `prod`: root (`example.com`) + `www` (ou `prod_subdomain` customizado)
  - `dev`: `dev.example.com` (ou `dev_subdomain` customizado)

## Uso

### Exemplo `infra/envs/dev/main.tf`

```hcl
module "amplify_frontend" {
  source = "../../modules/amplify-frontend"

  project_name       = var.project
  environment        = "dev"
  app_mode           = "connected"
  repository_url     = "https://github.com/acme/my-monorepo"
  repository_branch  = "develop"
  github_oauth_token = var.github_oauth_token

  build_type        = "vite"
  app_root          = "frontend"
  node_version      = "20"
  backend_base_url  = "https://api-dev.example.com"
  enable_pr_previews = true

  custom_domain_enabled = true
  domain_name           = "example.com"
  dev_subdomain         = "dev"

  frontend_env_vars = {
    VITE_APP_NAME = "my-app-dev"
  }

  tags = {
    Project     = var.project
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

### Exemplo `infra/envs/prod/main.tf`

```hcl
module "amplify_frontend" {
  source = "../../modules/amplify-frontend"

  project_name       = var.project
  environment        = "prod"
  app_mode           = "connected"
  repository_url     = "https://github.com/acme/my-monorepo"
  repository_branch  = "main"
  github_oauth_token = var.github_oauth_token

  build_type       = "nextjs"
  app_root         = "frontend"
  node_version     = "20"
  backend_base_url = "https://api.example.com"

  enable_pr_previews = false

  custom_domain_enabled = true
  domain_name           = "example.com"
  prod_subdomain        = "www"

  frontend_env_vars = {
    NEXT_PUBLIC_APP_ENV = "prod"
  }

  tags = {
    Project     = var.project
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}
```

## Outputs

- `amplify_app_id`
- `default_domain`
- `branch_name`
- `branch_url`
- `custom_domain_urls`
- `webhook_url` (sensível)

## CORS / Integração Backend (ECS + ALB)

1. Defina `backend_base_url` com HTTPS (`https://api.example.com`).
2. Configure CORS no backend para permitir o domínio do frontend:
   - dev: `https://dev.example.com` (ou domínio padrão Amplify durante bootstrap)
   - prod: `https://example.com` e `https://www.example.com`
3. No ALB, use ACM para TLS e redirecionamento HTTP→HTTPS.
4. Evite `*` em CORS para produção, prefira allowlist explícita.

## Segurança e segredos

- `frontend_env_vars` é para valores **não sensíveis**.
- `frontend_secrets` é mantido por compatibilidade de interface, mas bloqueado por validação para evitar vazamento em Terraform state.
- Para segredos reais, use Secrets Manager/SSM e busque no build pipeline/runtime sem persistir no estado do Terraform.

## Troubleshooting

- **Erro de validação em modo `connected`**: confirme `repository_url`, `repository_branch` e `github_oauth_token`.
- **Domínio não associa**: valide DNS apontando para Amplify e status da associação no console.
- **Preview sem Basic Auth**: confirme `enable_basic_auth_for_previews = true` e credenciais preenchidas.
- **API inacessível no frontend**: verifique `backend_base_url` (HTTPS), regras de CORS e SG/NACL no backend.
- **Next.js artifact**: ajuste `amplify_build_spec` para `next export`/SSR conforme sua estratégia.
