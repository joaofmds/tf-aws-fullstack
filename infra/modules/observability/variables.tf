variable "name_prefix" {
  description = "Prefix used when naming monitoring resources."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name_prefix))
    error_message = "name_prefix must be 1-63 characters and contain only letters, numbers, and hyphens."
  }
}

# App / Service
variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs."
  type        = number
  nullable    = false

  validation {
    condition     = var.log_retention_days > 0
    error_message = "log_retention_days must be greater than 0."
  }
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB used for CloudWatch metrics."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.alb_arn_suffix)) > 0
    error_message = "alb_arn_suffix must not be empty."
  }
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the target group used for CloudWatch metrics."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.target_group_arn_suffix)) > 0
    error_message = "target_group_arn_suffix must not be empty."
  }
}

variable "cluster_name" {
  description = "Name of the ECS cluster to monitor."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.cluster_name)) > 0
    error_message = "cluster_name must not be empty."
  }
}

variable "service_name" {
  description = "Name of the ECS service to monitor."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.service_name)) > 0
    error_message = "service_name must not be empty."
  }
}

# Tags
variable "tags" {
  description = "Map of tags to apply to observability resources."
  type        = map(string)
  default     = {}
}
