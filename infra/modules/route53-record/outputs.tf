output "fqdn" {
  description = "Fully qualified domain name (FQDN) of the record."
  value       = aws_route53_record.this.fqdn
}

output "name" {
  description = "Name of the record."
  value       = var.name
}

output "type" {
  description = "Type of the record."
  value       = var.type
}

output "zone_id" {
  description = "Zone ID where the record was created."
  value       = var.zone_id
}
