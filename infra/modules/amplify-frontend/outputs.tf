output "amplify_app_id" {
  description = "Amplify application ID."
  value       = aws_amplify_app.this.id
}

output "default_domain" {
  description = "Amplify default domain (for example: main.d123abc.amplifyapp.com)."
  value       = aws_amplify_app.this.default_domain
}

output "branch_name" {
  description = "Primary branch configured for this environment."
  value       = aws_amplify_branch.primary.branch_name
}

output "branch_url" {
  description = "Primary branch URL in Amplify (https://<branch>.<app-default-domain>)."
  value       = "https://${aws_amplify_branch.primary.branch_name}.${aws_amplify_app.this.default_domain}"
}

output "custom_domain_urls" {
  description = "Resolved custom domain URLs managed by Amplify for this environment."
  value = var.custom_domain_enabled ? (
    var.custom_sub_domains != null ? [
      for subdomain in var.custom_sub_domains :
      subdomain.prefix == "" ? "https://${var.domain_name}" : "https://${subdomain.prefix}.${var.domain_name}"
    ] : (
      var.environment == "prod" ? compact([
        "https://${var.domain_name}",
        trimspace(var.prod_subdomain) != "" ? "https://${var.prod_subdomain}.${var.domain_name}" : null
      ]) : ["https://${var.dev_subdomain}.${var.domain_name}"]
    )
  ) : []
}

output "domain_association_id" {
  description = "ID of the domain association (when custom_domain_enabled=true)."
  value       = var.custom_domain_enabled ? aws_amplify_domain_association.this[0].id : null
}

output "certificate_verification_dns_record" {
  description = "DNS record for certificate verification (when custom_domain_enabled=true)."
  value       = var.custom_domain_enabled ? aws_amplify_domain_association.this[0].certificate_verification_dns_record : null
}

output "webhook_url" {
  description = "Webhook URL when created. Null when webhook is disabled."
  value       = local.create_webhook ? aws_amplify_webhook.this[0].url : null
  sensitive   = true
}
