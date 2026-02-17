# Input variables for configuring Amazon ECR repositories.

# Naming
variable "name_prefix" {
  description = "Prefix used when naming ECR repositories."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name_prefix))
    error_message = "name_prefix must be 1-63 characters and contain only letters, numbers, and hyphens."
  }
}

# Tags
variable "tags" {
  description = "Map of tags to apply to ECR repositories."
  type        = map(string)
  default     = {}
}
