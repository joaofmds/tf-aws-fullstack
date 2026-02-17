output "db_endpoint" {
  description = "Endpoint address of the provisioned RDS instance."
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Database port of the provisioned RDS instance."
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Database name configured for the RDS instance."
  value       = aws_db_instance.this.db_name
}
