output "certificate_arn" {
  description = "ARN of the validated ACM certificate."
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "certificate_id" {
  description = "ID of the ACM certificate."
  value       = aws_acm_certificate.this.id
}

output "certificate_domain" {
  description = "Primary domain name of the certificate."
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_domain_validation_options" {
  description = "Domain validation options for the certificate."
  value       = aws_acm_certificate.this.domain_validation_options
  sensitive   = true
}
