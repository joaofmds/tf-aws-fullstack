variable "name_prefix" {
  description = "Prefix used when naming ECS resources."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name_prefix))
    error_message = "name_prefix must be 1-63 characters and contain only letters, numbers, and hyphens."
  }
}

# App / Service
variable "region" {
  description = "AWS region where ECS resources are deployed."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.region))
    error_message = "region must be a valid AWS region format (for example, us-east-1)."
  }
}

variable "container_port" {
  description = "Container port exposed by the backend service."
  type        = number
  nullable    = false

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

variable "backend_image" {
  description = "Container image URI for the backend service."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.backend_image)) > 0
    error_message = "backend_image must not be empty."
  }
}

variable "cron_image" {
  description = "Container image URI for the cron service."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.cron_image)) > 0
    error_message = "cron_image must not be empty."
  }
}

variable "backend_cpu" {
  description = "CPU units allocated to the backend task definition."
  type        = number
  nullable    = false

  validation {
    condition     = var.backend_cpu > 0
    error_message = "backend_cpu must be greater than 0."
  }
}

variable "backend_memory" {
  description = "Memory (MiB) allocated to the backend task definition."
  type        = number
  nullable    = false

  validation {
    condition     = var.backend_memory > 0
    error_message = "backend_memory must be greater than 0."
  }
}

variable "cron_cpu" {
  description = "CPU units allocated to the cron task definition."
  type        = number
  nullable    = false

  validation {
    condition     = var.cron_cpu > 0
    error_message = "cron_cpu must be greater than 0."
  }
}

variable "cron_memory" {
  description = "Memory (MiB) allocated to the cron task definition."
  type        = number
  nullable    = false

  validation {
    condition     = var.cron_memory > 0
    error_message = "cron_memory must be greater than 0."
  }
}

variable "desired_count" {
  description = "Desired number of backend ECS tasks."
  type        = number
  nullable    = false

  validation {
    condition     = var.desired_count >= 0
    error_message = "desired_count must be greater than or equal to 0."
  }
}

variable "min_capacity" {
  description = "Minimum autoscaling capacity for the backend ECS service."
  type        = number
  nullable    = false

  validation {
    condition     = var.min_capacity >= 0
    error_message = "min_capacity must be greater than or equal to 0."
  }
}

variable "max_capacity" {
  description = "Maximum autoscaling capacity for the backend ECS service."
  type        = number
  nullable    = false

  validation {
    condition     = var.max_capacity >= var.min_capacity
    error_message = "max_capacity must be greater than or equal to min_capacity."
  }
}

variable "app_workers" {
  description = "Number of application worker processes for backend tasks."
  type        = number
  nullable    = false

  validation {
    condition     = var.app_workers > 0
    error_message = "app_workers must be greater than 0."
  }
}

variable "timezone" {
  description = "Timezone used by application and scheduled workloads."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.timezone)) > 0
    error_message = "timezone must not be empty."
  }
}

variable "db_host" {
  description = "Database host name used by ECS tasks."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.db_host)) > 0
    error_message = "db_host must not be empty."
  }
}

variable "db_port" {
  description = "Database port used by ECS tasks."
  type        = number
  nullable    = false

  validation {
    condition     = var.db_port >= 1 && var.db_port <= 65535
    error_message = "db_port must be between 1 and 65535."
  }
}

variable "db_name" {
  description = "Database name used by ECS tasks."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.db_name)) > 0
    error_message = "db_name must not be empty."
  }
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^arn:aws(-[a-z]+)?:secretsmanager:[a-z0-9-]+:[0-9]{12}:secret:.+$", var.db_secret_arn))
    error_message = "db_secret_arn must be a valid Secrets Manager ARN."
  }
}

variable "cors_param_arn" {
  description = "ARN of the SSM parameter containing CORS origins."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^arn:aws(-[a-z]+)?:ssm:[a-z0-9-]+:[0-9]{12}:parameter/.+$", var.cors_param_arn))
    error_message = "cors_param_arn must be a valid SSM parameter ARN."
  }
}

variable "uploads_bucket_name" {
  description = "Name of the S3 bucket used for uploads."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.uploads_bucket_name)) > 0
    error_message = "uploads_bucket_name must not be empty."
  }
}

variable "uploads_bucket_arn" {
  description = "ARN of the S3 bucket used for uploads."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^arn:aws(-[a-z]+)?:s3:::[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.uploads_bucket_arn))
    error_message = "uploads_bucket_arn must be a valid S3 bucket ARN."
  }
}

# Networking
variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS task networking."
  type        = list(string)
  nullable    = false

  validation {
    condition = length(var.private_subnet_ids) > 0 && alltrue([
      for subnet_id in var.private_subnet_ids : can(regex("^subnet-[0-9a-fA-F]+$", subnet_id))
    ])
    error_message = "private_subnet_ids must contain at least one valid subnet ID and each item must start with subnet-."
  }
}

# Security
variable "ecs_sg_id" {
  description = "Security group ID attached to ECS tasks."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^sg-[0-9a-fA-F]+$", var.ecs_sg_id))
    error_message = "ecs_sg_id must be a valid AWS security group ID (for example, sg-0123abcd)."
  }
}

# App / Service
variable "target_group_arn" {
  description = "ARN of the ALB target group associated with the backend service."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^arn:aws(-[a-z]+)?:elasticloadbalancing:[a-z0-9-]+:[0-9]{12}:targetgroup/.+$", var.target_group_arn))
    error_message = "target_group_arn must be a valid ELB target group ARN."
  }
}

variable "cron_schedule" {
  description = "EventBridge schedule expression used to run cron tasks."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.cron_schedule)) > 0
    error_message = "cron_schedule must not be empty."
  }
}

variable "log_retention_days" {
  description = "Number of days to retain ECS CloudWatch logs."
  type        = number
  nullable    = false

  validation {
    condition     = var.log_retention_days > 0
    error_message = "log_retention_days must be greater than 0."
  }
}
