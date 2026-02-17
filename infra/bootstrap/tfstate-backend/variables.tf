variable "aws_region" {
  description = "AWS region where the Terraform backend resources will be created."
  type        = string
}

variable "org" {
  description = "Organization slug used in global naming."
  type        = string
}

variable "project" {
  description = "Project slug used in global naming."
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod) used in backend key and tagging."
  type        = string
}

variable "state_key" {
  description = "Optional explicit state key. Defaults to envs/<environment>/terraform.tfstate."
  type        = string
  default     = null
}

variable "enable_kms" {
  description = "Enable dedicated KMS key encryption for state objects."
  type        = bool
  default     = true
}

variable "create_access_log_bucket" {
  description = "Enable creation of a dedicated access log bucket and S3 server access logging."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Optional tags applied to all backend resources."
  type        = map(string)
  default     = {}
}
