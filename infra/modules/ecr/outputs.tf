# Output values exposed by the Amazon ECR module.

output "backend_repository_url" {
  description = "Repository URL for the backend container image."
  value       = aws_ecr_repository.backend.repository_url
}

output "backend_repository_arn" {
  description = "ARN of the backend ECR repository."
  value       = aws_ecr_repository.backend.arn
}

output "cron_repository_url" {
  description = "Repository URL for the cron container image."
  value       = aws_ecr_repository.cron.repository_url
}

output "cron_repository_arn" {
  description = "ARN of the cron ECR repository."
  value       = aws_ecr_repository.cron.arn
}
