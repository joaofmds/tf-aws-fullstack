variable "org" {
  description = "Organization or company identifier used in resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,20}$", var.org))
    error_message = "org must contain only lowercase letters, numbers, and hyphens (2-20 chars)."
  }
}

variable "project" {
  description = "Project identifier used in resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,24}$", var.project))
    error_message = "project must contain only lowercase letters, numbers, and hyphens (2-24 chars)."
  }
}

variable "environment" {
  description = "Environment name for backend key prefix recommendations and tags."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]{2,16}$", var.environment))
    error_message = "environment must contain only lowercase letters, numbers, and hyphens (2-16 chars)."
  }
}

variable "state_key" {
  description = "S3 object key for terraform state."
  type        = string
  default     = null
}

variable "enable_kms" {
  description = "When true, create and enforce a dedicated KMS key for S3 state object encryption."
  type        = bool
  default     = true
}

variable "create_access_log_bucket" {
  description = "When true, create a dedicated S3 bucket and enable access logging for the tfstate bucket."
  type        = bool
  default     = false
}

variable "access_log_prefix" {
  description = "Prefix used by S3 server access logs in the log bucket."
  type        = string
  default     = "s3-access/"
}

variable "noncurrent_version_retention_days" {
  description = "Retention window for noncurrent object versions. Must be at least 90 days."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_version_retention_days >= 90
    error_message = "noncurrent_version_retention_days must be at least 90 days."
  }
}

variable "abort_multipart_days" {
  description = "Number of days after which incomplete multipart uploads are aborted."
  type        = number
  default     = 7

  validation {
    condition     = var.abort_multipart_days >= 1
    error_message = "abort_multipart_days must be at least 1 day."
  }
}

variable "tags" {
  description = "Common tags applied to all created resources."
  type        = map(string)
  default     = {}
}
