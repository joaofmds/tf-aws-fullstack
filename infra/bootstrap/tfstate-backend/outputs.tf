output "tfstate_bucket_name" {
  value       = module.tfstate_backend.tfstate_bucket_name
  description = "Terraform state S3 bucket name."
}

output "tfstate_bucket_arn" {
  value       = module.tfstate_backend.tfstate_bucket_arn
  description = "Terraform state S3 bucket ARN."
}

output "tfstate_dynamodb_table_name" {
  value       = module.tfstate_backend.tfstate_dynamodb_table_name
  description = "Terraform state lock table name."
}

output "tfstate_kms_key_arn" {
  value       = module.tfstate_backend.tfstate_kms_key_arn
  description = "Terraform state KMS key ARN when enabled."
}

output "recommended_backend_config" {
  value       = module.tfstate_backend.recommended_backend_config
  description = "Copy/paste backend \"s3\" block recommendation."
}

output "terraform_backend_access_policy_arn" {
  value       = module.tfstate_backend.terraform_backend_access_policy_arn
  description = "IAM managed policy ARN to grant backend read/write/lock permissions."
}

output "terraform_backend_access_policy_json" {
  value       = module.tfstate_backend.terraform_backend_access_policy_json
  description = "IAM policy JSON to embed in an existing role if needed."
}
