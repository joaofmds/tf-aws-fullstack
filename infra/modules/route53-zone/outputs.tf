output "zone_id" {
  description = "ID of the Route53 hosted zone."
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "List of name servers for the hosted zone."
  value       = aws_route53_zone.this.name_servers
}

output "name" {
  description = "Domain name of the hosted zone."
  value       = aws_route53_zone.this.name
}
