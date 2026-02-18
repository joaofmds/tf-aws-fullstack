variable "name_prefix" {
  description = "Prefix used when naming RDS resources."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name_prefix))
    error_message = "name_prefix must be 1-63 characters and contain only letters, numbers, and hyphens."
  }
}

# Networking
variable "private_db_subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group."
  type        = list(string)
  nullable    = false

  validation {
    condition = length(var.private_db_subnet_ids) > 0 && alltrue([
      for subnet_id in var.private_db_subnet_ids : can(regex("^subnet-[0-9a-fA-F]+$", subnet_id))
    ])
    error_message = "private_db_subnet_ids must contain at least one valid subnet ID and each item must start with subnet-."
  }
}

# Security
variable "rds_sg_id" {
  description = "Security group ID attached to the RDS instance."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^sg-[0-9a-fA-F]+$", var.rds_sg_id))
    error_message = "rds_sg_id must be a valid AWS security group ID (for example, sg-0123abcd)."
  }
}

# App / Service
variable "instance_class" {
  description = "RDS instance class (for example, db.t4g.micro)."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^db\\.[A-Za-z0-9.]+$", var.instance_class))
    error_message = "instance_class must start with 'db.' and be a valid RDS instance class string."
  }
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB for the RDS instance."
  type        = number
  nullable    = false

  validation {
    condition     = var.allocated_storage > 0
    error_message = "allocated_storage must be greater than 0."
  }
}

variable "max_allocated_storage" {
  description = "Maximum autoscaled storage in GiB for the RDS instance."
  type        = number
  nullable    = false

  validation {
    condition     = var.max_allocated_storage >= var.allocated_storage
    error_message = "max_allocated_storage must be greater than or equal to allocated_storage."
  }
}

variable "db_name" {
  description = "Initial database name to create in the RDS instance."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,62}$", var.db_name))
    error_message = "db_name must start with a letter and contain only letters, numbers, or underscores (max 63 chars)."
  }
}

variable "db_user" {
  description = "Master username for the RDS instance."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,62}$", var.db_user))
    error_message = "db_user must start with a letter and contain only letters, numbers, or underscores (max 63 chars)."
  }
}

variable "db_password" {
  description = "Master password for the RDS instance."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "db_password must be at least 8 characters long."
  }
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  nullable    = false

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "backup_retention_period must be between 0 and 35 days."
  }
}

variable "maintenance_window" {
  description = "Weekly maintenance window in UTC (ddd:hh24:mi-ddd:hh24:mi)."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-zA-Z]{3}:[0-2][0-9]:[0-5][0-9]-[a-zA-Z]{3}:[0-2][0-9]:[0-5][0-9]$", var.maintenance_window))
    error_message = "maintenance_window must follow the format ddd:hh:mm-ddd:hh:mm (e.g. sun:03:00-sun:04:00)."
  }
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled for the RDS instance."
  type        = bool
  nullable    = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip creating a final snapshot when deleting the RDS instance."
  type        = bool
  nullable    = false
}

variable "apply_immediately" {
  description = "Whether changes are applied immediately or during the maintenance window."
  type        = bool
  nullable    = false
}

variable "db_timezone" {
  description = "Database engine timezone setting."
  type        = string
  default     = "UTC"

  validation {
    condition     = length(trimspace(var.db_timezone)) > 0
    error_message = "db_timezone must not be empty."
  }
}

# Tags
variable "tags" {
  description = "Map of tags to apply to RDS resources."
  type        = map(string)
  default     = {}
}
