# Input variables for configuring Amazon S3 storage resources.

# Naming
variable "name_prefix" {
  description = "Prefix used when naming S3 resources."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name_prefix))
    error_message = "name_prefix must be 1-63 characters and contain only letters, numbers, and hyphens."
  }
}

# App / Service
variable "account_id" {
  description = "AWS account ID used in S3 bucket policy configuration."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "account_id must be a 12-digit AWS account ID."
  }
}

variable "expiration_days" {
  description = "Number of days before uploaded objects expire."
  type        = number
  default     = 30

  validation {
    condition     = var.expiration_days > 0
    error_message = "expiration_days must be greater than 0."
  }
}

# Tags
variable "tags" {
  description = "Map of tags to apply to S3 resources."
  type        = map(string)
  default     = {}
}
