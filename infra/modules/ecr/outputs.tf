output "backend_repository_url" { value = aws_ecr_repository.backend.repository_url }
output "backend_repository_arn" { value = aws_ecr_repository.backend.arn }
output "cron_repository_url" { value = aws_ecr_repository.cron.repository_url }
output "cron_repository_arn" { value = aws_ecr_repository.cron.arn }
