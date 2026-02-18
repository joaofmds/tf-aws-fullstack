# Input variables for the production environment stack.

# Naming
variable "aws_region" {
  description = "AWS region where the production environment is deployed."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "aws_region must be a valid AWS region format (for example, us-east-1)."
  }
}

variable "project" {
  description = "Project identifier used in resource naming."
  type        = string
  default     = "tf-aws-fullstack"

  validation {
    condition     = length(trimspace(var.project)) > 0
    error_message = "project must not be empty."
  }
}

variable "environment" {
  description = "Environment name used for resource naming and tagging."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "environment must not be empty."
  }
}

# Networking
variable "container_port" {
  description = "Application container port exposed by backend services."
  type        = number
  default     = 8081

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the environment VPC."
  type        = string
  nullable    = false

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "public_subnets" {
  description = "Map of public subnet definitions keyed by logical name."
  type        = map(object({ cidr = string, az = string }))
  nullable    = false
}

variable "private_app_subnets" {
  description = "Map of private application subnet definitions keyed by logical name."
  type        = map(object({ cidr = string, az = string }))
  nullable    = false
}

variable "private_db_subnets" {
  description = "Map of private database subnet definitions keyed by logical name."
  type        = map(object({ cidr = string, az = string }))
  nullable    = false
}

# App / Service
variable "database_name" {
  description = "Name of the application database."
  type        = string
  nullable    = false
}

variable "database_user" {
  description = "Database username for the application."
  type        = string
  nullable    = false
}

variable "database_password" {
  description = "Database password for the application."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(var.database_password) >= 8
    error_message = "database_password must be at least 8 characters long."
  }
}

variable "db_instance_class" {
  description = "RDS instance class for the environment database."
  type        = string
  nullable    = false
}

variable "db_allocated_storage" {
  description = "Initial allocated RDS storage in GiB."
  type        = number
  nullable    = false
}

variable "db_max_allocated_storage" {
  description = "Maximum autoscaled RDS storage in GiB."
  type        = number
  nullable    = false
}

variable "db_backup_retention" {
  description = "Number of days to retain database backups."
  type        = number
  nullable    = false
}

variable "db_maintenance_window" {
  description = "Preferred weekly maintenance window for RDS."
  type        = string
  nullable    = false
}

variable "db_deletion_protection" {
  description = "Whether deletion protection is enabled for RDS."
  type        = bool
  nullable    = false
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip a final snapshot when deleting RDS."
  type        = bool
  nullable    = false
}

variable "db_apply_immediately" {
  description = "Whether database changes are applied immediately."
  type        = bool
  nullable    = false
}

variable "backend_image_tag" {
  description = "Container image tag for the backend service."
  type        = string
  default     = "latest"
}

variable "cron_image_tag" {
  description = "Container image tag for the cron service."
  type        = string
  default     = "latest"
}

variable "backend_cpu" {
  description = "CPU units for backend tasks."
  type        = number
  nullable    = false
}

variable "backend_memory" {
  description = "Memory (MiB) for backend tasks."
  type        = number
  nullable    = false
}

variable "cron_cpu" {
  description = "CPU units for cron tasks."
  type        = number
  nullable    = false
}

variable "cron_memory" {
  description = "Memory (MiB) for cron tasks."
  type        = number
  nullable    = false
}

variable "desired_count" {
  description = "Desired number of backend service tasks."
  type        = number
  nullable    = false
}

variable "min_capacity" {
  description = "Minimum autoscaling capacity for backend service."
  type        = number
  nullable    = false
}

variable "max_capacity" {
  description = "Maximum autoscaling capacity for backend service."
  type        = number
  nullable    = false
}

variable "app_workers" {
  description = "Number of worker processes for the backend application."
  type        = number
  default     = 2
}

variable "timezone" {
  description = "Timezone used by application and scheduled workloads."
  type        = string
  default     = "UTC"
}

variable "cron_schedule" {
  description = "EventBridge schedule expression for cron tasks."
  type        = string
  default     = "rate(6 hours)"
}

variable "upload_retention_days" {
  description = "Number of days to retain uploaded objects in S3."
  type        = number
  default     = 30
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs."
  type        = number
  default     = 14
}

variable "cors_origins" {
  description = "Allowed CORS origins for the application."
  type        = string
  nullable    = false
}

# TLS
variable "acm_certificate_arn" {
  description = "Optional ACM certificate ARN used to enable HTTPS on the ALB."
  type        = string
  default     = null

  validation {
    condition = var.acm_certificate_arn == null || can(
      regex("^arn:aws(-[a-z]+)?:acm:[a-z0-9-]+:[0-9]{12}:certificate/[0-9a-fA-F-]+$", var.acm_certificate_arn)
    )
    error_message = "acm_certificate_arn must be null or a valid ACM certificate ARN."
  }
}

# Security
variable "github_org" {
  description = "GitHub organization allowed to assume OIDC roles."
  type        = string
  nullable    = false
}

variable "github_repo" {
  description = "GitHub repository allowed to assume OIDC roles."
  type        = string
  nullable    = false
}

# Tags
variable "tags" {
  description = "Map of common tags applied to all environment resources."
  type        = map(string)
  default     = {}
}
