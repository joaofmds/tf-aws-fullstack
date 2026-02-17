output "tfstate_bucket_name" {
  description = "Terraform state S3 bucket name."
  value       = aws_s3_bucket.tfstate.bucket
}

output "tfstate_bucket_arn" {
  description = "Terraform state S3 bucket ARN."
  value       = aws_s3_bucket.tfstate.arn
}

output "tfstate_dynamodb_table_name" {
  description = "DynamoDB table name used for Terraform state locking."
  value       = aws_dynamodb_table.tfstate_lock.name
}

output "tfstate_kms_key_arn" {
  description = "KMS key ARN used to encrypt Terraform state objects (null when SSE-S3 is enabled)."
  value       = local.effective_kms_key_arn
}

output "terraform_backend_access_policy_arn" {
  description = "Managed IAM policy ARN that grants Terraform backend access (S3, DynamoDB and KMS when enabled)."
  value       = aws_iam_policy.terraform_backend_access.arn
}

output "terraform_backend_access_policy_json" {
  description = "IAM policy document JSON for Terraform backend access."
  value       = data.aws_iam_policy_document.terraform_backend_access.json
}

output "recommended_backend_config" {
  description = "Recommended backend \"s3\" configuration for this state backend."
  value       = <<-EOT
backend "s3" {
  bucket         = "${aws_s3_bucket.tfstate.bucket}"
  key            = "${local.state_key}"
  region         = "${local.region}"
  dynamodb_table = "${aws_dynamodb_table.tfstate_lock.name}"
  encrypt        = true
${var.enable_kms ? "  kms_key_id     = \"${aws_kms_key.tfstate[0].arn}\"" : ""}
}
EOT
}
