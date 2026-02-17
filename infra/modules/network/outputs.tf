output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "List of IDs for created public subnets."
  value       = [for s in aws_subnet.public : s.id]
}

output "private_app_subnet_ids" {
  description = "List of IDs for created private application subnets."
  value       = [for s in aws_subnet.private_app : s.id]
}

output "private_db_subnet_ids" {
  description = "List of IDs for created private database subnets."
  value       = [for s in aws_subnet.private_db : s.id]
}
