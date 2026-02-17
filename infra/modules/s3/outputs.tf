output "uploads_bucket_name" {
  description = "Name of the uploads S3 bucket."
  value       = aws_s3_bucket.uploads.bucket
}

output "uploads_bucket_arn" {
  description = "ARN of the uploads S3 bucket."
  value       = aws_s3_bucket.uploads.arn
}
