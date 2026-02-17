variable "name_prefix" {
  description = "Prefix used when naming secrets and parameters."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name_prefix))
    error_message = "name_prefix must be 1-63 characters and contain only letters, numbers, and hyphens."
  }
}

# App / Service
variable "database_user" {
  description = "Database username stored in Secrets Manager."
  type        = string
  nullable    = false

  validation {
    condition     = length(trim(var.database_user)) > 0
    error_message = "database_user must not be empty."
  }
}

variable "database_password" {
  description = "Database password stored in Secrets Manager."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(var.database_password) >= 8
    error_message = "database_password must be at least 8 characters long."
  }
}

variable "database_name" {
  description = "Database name stored in Secrets Manager."
  type        = string
  nullable    = false

  validation {
    condition     = length(trim(var.database_name)) > 0
    error_message = "database_name must not be empty."
  }
}

variable "cors_origins" {
  description = "CORS origins value stored in SSM Parameter Store."
  type        = string
  nullable    = false

  validation {
    condition     = length(trim(var.cors_origins)) > 0
    error_message = "cors_origins must not be empty."
  }
}

# Tags
variable "tags" {
  description = "Map of tags to apply to secret and parameter resources."
  type        = map(string)
  default     = {}
}
