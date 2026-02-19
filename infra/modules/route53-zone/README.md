# Route53 Hosted Zone Module

Módulo genérico para criar uma Route53 Hosted Zone pública.

## Características

- ✅ Criação de hosted zone pública no Route53
- ✅ Tags customizáveis
- ✅ Outputs úteis (zone_id, name_servers)

## Uso

### Criação básica

```hcl
module "route53_zone" {
  source = "../../modules/route53-zone"
  
  domain_name = "example.com"
  
  tags = {
    Environment = "prod"
  }
}
```

### Com nome customizado

```hcl
module "route53_zone" {
  source = "../../modules/route53-zone"
  
  domain_name = "example.com"
  name        = "my-custom-zone"
  comment     = "Production domain zone"
  
  tags = {
    Environment = "prod"
  }
}
```

## Inputs

| Nome | Descrição | Tipo | Padrão | Obrigatório |
|------|-----------|------|--------|-------------|
| `domain_name` | Nome do domínio (ex: example.com) | `string` | - | ✅ |
| `comment` | Comentário para a hosted zone | `string` | `null` | ❌ |
| `name` | Nome da tag Name | `string` | `"{domain_name}-zone"` | ❌ |
| `tags` | Tags adicionais | `map(string)` | `{}` | ❌ |

## Outputs

| Nome | Descrição |
|------|-----------|
| `zone_id` | ID da hosted zone |
| `name_servers` | Lista de name servers da hosted zone |
| `name` | Nome do domínio da hosted zone |

## Notas Importantes

- **Name Servers**: Após criar a hosted zone, você precisa atualizar os name servers no seu registrador de domínio (onde você comprou o domínio).
- **Custo**: Route53 cobra $0.50 por hosted zone por mês.
- **Deleção**: Ao deletar uma hosted zone, todos os registros DNS são removidos.

## Exemplo de Integração

### Com módulo DNS/ACM

```hcl
module "route53_zone" {
  source = "../../modules/route53-zone"
  
  domain_name = "example.com"
  tags        = local.common_tags
}

module "dns_acm" {
  source = "../../modules/dns-acm"
  
  domain_name      = "example.com"
  route53_zone_id = module.route53_zone.zone_id
  create_zone     = false  # Usar zona existente
  
  # ...
}
```

Ou deixe o módulo criar automaticamente:

```hcl
module "dns_acm" {
  source = "../../modules/dns-acm"
  
  domain_name = "example.com"
  create_zone = true  # Criar zona automaticamente
  
  # ...
}
```
