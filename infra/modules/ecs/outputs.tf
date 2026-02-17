# Output values exposed by the ECS module.

output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "Name of the backend ECS service."
  value       = aws_ecs_service.backend.name
}

output "backend_task_definition_arn" {
  description = "ARN of the backend ECS task definition."
  value       = aws_ecs_task_definition.backend.arn
}

output "cron_task_definition_arn" {
  description = "ARN of the cron ECS task definition."
  value       = aws_ecs_task_definition.cron.arn
}

output "execution_role_arn" {
  description = "ARN of the ECS task execution IAM role."
  value       = aws_iam_role.execution_role.arn
}

output "task_role_arn" {
  description = "ARN of the ECS task IAM role."
  value       = aws_iam_role.task_role.arn
}

output "backend_log_group_name" {
  description = "CloudWatch log group name for backend tasks."
  value       = aws_cloudwatch_log_group.backend.name
}

output "cron_log_group_name" {
  description = "CloudWatch log group name for cron tasks."
  value       = aws_cloudwatch_log_group.cron.name
}
