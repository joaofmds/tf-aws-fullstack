output "cluster_name" { value = aws_ecs_cluster.this.name }
output "service_name" { value = aws_ecs_service.backend.name }
output "backend_task_definition_arn" { value = aws_ecs_task_definition.backend.arn }
output "cron_task_definition_arn" { value = aws_ecs_task_definition.cron.arn }
output "execution_role_arn" { value = aws_iam_role.execution_role.arn }
output "task_role_arn" { value = aws_iam_role.task_role.arn }
output "backend_log_group_name" { value = aws_cloudwatch_log_group.backend.name }
output "cron_log_group_name" { value = aws_cloudwatch_log_group.cron.name }
