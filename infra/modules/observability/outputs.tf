# Output values exposed by the observability module.

output "alb_5xx_alarm_name" {
  description = "Name of the ALB 5XX CloudWatch alarm."
  value       = aws_cloudwatch_metric_alarm.alb_5xx.alarm_name
}
