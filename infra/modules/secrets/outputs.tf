output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret storing database credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "cors_origins_param_arn" {
  description = "ARN of the SSM parameter storing allowed CORS origins."
  value       = aws_ssm_parameter.cors_origins.arn
}
