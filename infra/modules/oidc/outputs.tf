output "terraform_role_arn" {
  description = "ARN of the IAM role used by Terraform GitHub Actions workflows."
  value       = aws_iam_role.terraform.arn
}

output "deploy_role_arn" {
  description = "ARN of the IAM role used by deployment GitHub Actions workflows."
  value       = aws_iam_role.deploy.arn
}
