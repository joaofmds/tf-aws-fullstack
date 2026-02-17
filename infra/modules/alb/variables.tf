# Input variables for configuring the Application Load Balancer module.

# Naming
variable "name_prefix" {
  description = "Prefix used when naming ALB resources."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name_prefix))
    error_message = "name_prefix must be 1-63 characters and contain only letters, numbers, and hyphens."
  }
}

# Networking
variable "vpc_id" {
  description = "ID of the VPC where the ALB and target group are created."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^vpc-[0-9a-fA-F]+$", var.vpc_id))
    error_message = "vpc_id must be a valid AWS VPC ID (for example, vpc-0123abcd)."
  }
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where the ALB will be placed."
  type        = list(string)
  nullable    = false

  validation {
    condition = length(var.public_subnet_ids) > 0 && alltrue([
      for subnet_id in var.public_subnet_ids : can(regex("^subnet-[0-9a-fA-F]+$", subnet_id))
    ])
    error_message = "public_subnet_ids must contain at least one valid subnet ID and each item must start with subnet-."
  }
}

# Security
variable "alb_sg_id" {
  description = "Security group ID attached to the ALB."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^sg-[0-9a-fA-F]+$", var.alb_sg_id))
    error_message = "alb_sg_id must be a valid AWS security group ID (for example, sg-0123abcd)."
  }
}

# App / Service
variable "container_port" {
  description = "Backend container port used by the ALB target group."
  type        = number
  nullable    = false

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

variable "health_check_path" {
  description = "HTTP path used by the ALB target group health check."
  type        = string
  nullable    = false

  validation {
    condition     = length(trim(var.health_check_path)) > 0 && startswith(var.health_check_path, "/")
    error_message = "health_check_path must be non-empty and start with '/'."
  }
}

# TLS
variable "acm_certificate_arn" {
  description = "Optional ACM certificate ARN to enable HTTPS listeners on the ALB."
  type        = string
  default     = null

  validation {
    condition = var.acm_certificate_arn == null || can(
      regex("^arn:aws(-[a-z]+)?:acm:[a-z0-9-]+:[0-9]{12}:certificate/[0-9a-fA-F-]+$", var.acm_certificate_arn)
    )
    error_message = "acm_certificate_arn must be null or a valid ACM certificate ARN."
  }
}

# Tags
variable "tags" {
  description = "Map of tags to apply to ALB resources."
  type        = map(string)
  default     = {}
}
