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
  description = "Primary branch URL in Amplify."
  value       = aws_amplify_branch.primary.web_url
}

output "custom_domain_urls" {
  description = "Resolved custom domain URLs managed by Amplify for this environment."
  value = var.custom_domain_enabled ? (
    var.environment == "prod" ? compact([
      "https://${var.domain_name}",
      trimspace(var.prod_subdomain) != "" ? "https://${var.prod_subdomain}.${var.domain_name}" : null
    ]) : ["https://${var.dev_subdomain}.${var.domain_name}"]
  ) : []
}

output "webhook_url" {
  description = "Webhook URL when created. Null when webhook is disabled."
  value       = local.create_webhook ? aws_amplify_webhook.this[0].url : null
  sensitive   = true
}
