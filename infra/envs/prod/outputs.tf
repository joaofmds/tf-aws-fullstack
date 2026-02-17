# Output values exposed by the production environment stack.

output "alb_dns_name" {
  description = "DNS name of the environment Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "backend_ecr_repository" {
  description = "ECR repository URL for the backend image."
  value       = module.ecr.backend_repository_url
}

output "cron_ecr_repository" {
  description = "ECR repository URL for the cron image."
  value       = module.ecr.cron_repository_url
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster in this environment."
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS backend service in this environment."
  value       = module.ecs.service_name
}

output "rds_endpoint" {
  description = "Endpoint address of the RDS instance."
  value       = module.rds.db_endpoint
}

output "uploads_bucket_name" {
  description = "Name of the S3 uploads bucket."
  value       = module.s3.uploads_bucket_name
}

output "github_actions_terraform_role_arn" {
  description = "IAM role ARN used by Terraform GitHub Actions workflows."
  value       = module.oidc.terraform_role_arn
}

output "github_actions_deploy_role_arn" {
  description = "IAM role ARN used by deployment GitHub Actions workflows."
  value       = module.oidc.deploy_role_arn
}
