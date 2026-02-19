# Módulo Terraform `aws-route53-acm-domains`

Módulo focado em DNS e certificados ACM para cenários com:

- **Frontend no AWS Amplify** usando domínio customizado no apex (`joaofmsouza.com.br`) e opcionalmente `www`.
- **Backend em ECS/ALB** usando `api.joaofmsouza.com.br` com alias Route53 para um ALB existente.

> O módulo **não cria hosted zone**, apenas consome uma hosted zone pública existente no Route53.

## O que o módulo provisiona

1. Busca da hosted zone pública por `domain_name`.
2. Certificado ACM do frontend em `region_edge` (normalmente `us-east-1`) com validação DNS automatizada.
3. Associação de domínio no Amplify (`aws_amplify_domain_association`) para apex e opcional `www`.
4. Certificado ACM do backend em `region_primary` para `api.<domain>` com validação DNS automatizada.
5. Registros `A` e `AAAA` alias de `api.<domain>` para o ALB informado.

## Decisão importante sobre frontend

Quando `aws_amplify_domain_association` é usado, o próprio Amplify gerencia os records necessários para o domínio do app. Por isso, este módulo **não cria manualmente alias A/AAAA para apex/www**, evitando drift e conflitos.

## Diagrama lógico (texto)

```text
Internet
  ├─ https://joaofmsouza.com.br ─┐
  ├─ https://www.joaofmsouza.com.br (opcional) ─┤ -> Amplify Domain Association
  └─ https://api.joaofmsouza.com.br -----------> Route53 Alias (A/AAAA) -> ALB existente

ACM (region_edge/us-east-1): cert frontend (apex + www opcional)
ACM (region_primary): cert backend (api.<domain>)
Validação DNS de ambos via Route53
```

## Requisitos

- Terraform >= 1.6.0
- Provider AWS >= 5.0
- Hosted zone pública já existente
- Amplify App existente (se `frontend_enabled = true`)
- ALB existente (se `backend_enabled = true`)

## Uso básico

```hcl
module "route53_acm_domains" {
  source = "../../modules/aws-route53-acm-domains"

  providers = {
    aws           = aws.primary
    aws.us_east_1 = aws.us_east_1
  }

  domain_name         = "joaofmsouza.com.br"
  environment         = "prod"
  project_name        = "meu-projeto"
  region_primary      = "us-east-1"
  region_edge         = "us-east-1"

  frontend_enabled    = true
  amplify_app_id      = "d123example"
  amplify_branch_name = "main"
  enable_www          = true

  backend_enabled = true
  api_subdomain   = "api"
  alb_dns_name    = "my-alb-123456.us-east-1.elb.amazonaws.com"
  alb_zone_id     = "Z35SXDOTRQ7X7K"

  tags = {
    Owner = "platform"
  }
}
```

## Integração com ALB HTTPS

O módulo exporta `backend_certificate_arn` / `backend_acm_certificate_arn`. Use esse ARN no `aws_lb_listener` (fora do módulo).

## Integração com Amplify

O módulo cria `aws_amplify_domain_association` para o domínio raiz e aguarda verificação (`wait_for_verification = true`).

## Inputs

| Nome | Tipo | Default | Obrigatório | Descrição |
|------|------|---------|-------------|-----------|
| `domain_name` | `string` | n/a | sim | Domínio raiz público. |
| `environment` | `string` | n/a | sim | `dev` ou `prod` (em `prod`, exige `enable_www=true`). |
| `project_name` | `string` | n/a | sim | Nome do projeto para tags e nomes. |
| `tags` | `map(string)` | `{}` | não | Tags adicionais. |
| `enable_www` | `bool` | `true` | não | Habilita `www` no frontend. |
| `frontend_enabled` | `bool` | `true` | não | Habilita recursos de frontend (ACM edge + Amplify domain). |
| `backend_enabled` | `bool` | `true` | não | Habilita recursos de backend (ACM + DNS api -> ALB). |
| `amplify_app_id` | `string` | `null` | condicional | Obrigatório quando `frontend_enabled=true`. |
| `amplify_branch_name` | `string` | `null` | condicional | Obrigatório quando `frontend_enabled=true`. |
| `alb_dns_name` | `string` | `null` | condicional | Obrigatório quando `backend_enabled=true`. |
| `alb_zone_id` | `string` | `null` | condicional | Obrigatório quando `backend_enabled=true`. |
| `api_subdomain` | `string` | `"api"` | não | Prefixo do backend. |
| `region_primary` | `string` | n/a | sim | Região primária do stack. |
| `region_edge` | `string` | `"us-east-1"` | não | Região edge para cert frontend. |

## Outputs

| Nome | Descrição |
|------|-----------|
| `hosted_zone_id` | ID da hosted zone pública. |
| `root_domain` | Domínio raiz. |
| `api_fqdn` | FQDN do backend (`api.<domain>`). |
| `www_fqdn` | FQDN do `www` (ou `null`). |
| `frontend_certificate_arn` | ARN do cert frontend (edge). |
| `backend_certificate_arn` | ARN do cert backend (primária). |
| `backend_acm_certificate_arn` | Alias para integração com listener HTTPS. |
| `amplify_domain_association_id` | ID da associação de domínio no Amplify. |
| `amplify_domain_status` | Status da associação no Amplify. |
| `frontend_urls` | URLs HTTPS esperadas do frontend. |
| `backend_url` | URL HTTPS do backend. |

## Boas práticas implementadas

- Validações de inputs condicionais para evitar planos inválidos.
- `precondition` para garantir que providers estão nas regiões esperadas.
- Tags padrão: `Project`, `Environment`, `ManagedBy=terraform`, `Component`.
- Certificados com `create_before_destroy` para reduzir downtime.
- Sem outputs sensíveis e sem armazenamento de segredos.
