output "hosted_zone_id" {
  description = "ID da hosted zone pública encontrada para o domínio raiz."
  value       = data.aws_route53_zone.public.zone_id
}

output "root_domain" {
  description = "Domínio raiz utilizado pelo módulo."
  value       = local.root_domain
}

output "api_fqdn" {
  description = "FQDN do backend (api)."
  value       = local.api_fqdn
}

output "www_fqdn" {
  description = "FQDN do www quando habilitado, senão null."
  value       = var.enable_www ? local.www_fqdn : null
}

output "frontend_certificate_arn" {
  description = "ARN do certificado ACM frontend emitido em region_edge (us-east-1 por padrão)."
  value       = var.frontend_enabled ? aws_acm_certificate_validation.frontend[0].certificate_arn : null
}

output "backend_certificate_arn" {
  description = "ARN do certificado ACM backend emitido na região primária; use no listener HTTPS do ALB."
  value       = var.backend_enabled ? aws_acm_certificate_validation.backend[0].certificate_arn : null
}

output "backend_acm_certificate_arn" {
  description = "Alias de compatibilidade para integração direta no aws_lb_listener HTTPS do backend."
  value       = var.backend_enabled ? aws_acm_certificate_validation.backend[0].certificate_arn : null
}

output "amplify_domain_association_id" {
  description = "ID da associação de domínio no Amplify."
  value       = var.frontend_enabled ? aws_amplify_domain_association.frontend[0].id : null
}

output "amplify_domain_status" {
  description = "Status atual da associação de domínio no Amplify."
  value       = var.frontend_enabled ? aws_amplify_domain_association.frontend[0].domain_status : null
}

output "frontend_urls" {
  description = "Lista de URLs finais esperadas para frontend."
  value       = local.frontend_urls
}

output "backend_url" {
  description = "URL HTTPS final do backend (api)."
  value       = var.backend_enabled ? "https://${local.api_fqdn}" : null
}
