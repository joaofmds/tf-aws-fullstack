output "db_secret_arn" { value = aws_secretsmanager_secret.db_credentials.arn }
output "cors_origins_param_arn" { value = aws_ssm_parameter.cors_origins.arn }
