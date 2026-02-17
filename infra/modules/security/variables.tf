# Input variables for configuring security groups.

# Naming
variable "name_prefix" {
  description = "Prefix used when naming security groups."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name_prefix))
    error_message = "name_prefix must be 1-63 characters and contain only letters, numbers, and hyphens."
  }
}

# Networking
variable "vpc_id" {
  description = "ID of the VPC where security groups are created."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^vpc-[0-9a-fA-F]+$", var.vpc_id))
    error_message = "vpc_id must be a valid AWS VPC ID (for example, vpc-0123abcd)."
  }
}

# App / Service
variable "container_port" {
  description = "Application container port allowed from the ALB to ECS tasks."
  type        = number
  nullable    = false

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

# Tags
variable "tags" {
  description = "Map of tags to apply to security groups."
  type        = map(string)
  default     = {}
}
