resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.name_prefix}/database"
  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.database_user
    password = var.database_password
    dbname   = var.database_name
  })
}

resource "aws_ssm_parameter" "cors_origins" {
  name  = "/${var.name_prefix}/cors_origins"
  type  = "String"
  value = var.cors_origins
  tags  = var.tags
}
