output "hosted_zone_id" {
  description = "ID of the Route53 hosted zone."
  value       = local.zone_id
}

output "name_servers" {
  description = "Name servers for the Route53 hosted zone (when create_zone=true)."
  value       = var.create_zone ? module.route53_zone[0].name_servers : null
}

output "root_domain" {
  description = "Root domain name used."
  value       = local.root_domain
}

output "api_fqdn" {
  description = "Fully qualified domain name for the API (backend)."
  value       = local.api_fqdn
}

output "frontend_certificate_arn" {
  description = "ARN of the frontend ACM certificate (us-east-1)."
  value       = var.frontend_enabled ? module.acm_frontend[0].certificate_arn : null
}

output "backend_certificate_arn" {
  description = "ARN of the backend ACM certificate (primary region)."
  value       = var.backend_enabled ? module.acm_backend[0].certificate_arn : null
}

output "backend_url" {
  description = "HTTPS URL for the backend API."
  value       = var.backend_enabled ? "https://${local.api_fqdn}" : null
}
