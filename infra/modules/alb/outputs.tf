output "alb_arn" {
  description = "ARN of the created Application Load Balancer."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the created Application Load Balancer."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "Canonical hosted zone ID of the ALB (for Route53 alias records)."
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "ARN of the backend target group attached to the ALB."
  value       = aws_lb_target_group.backend.arn
}

output "has_https" {
  description = "Whether HTTPS is enabled on the ALB (certificate configured)."
  value       = var.acm_certificate_arn != null
}
