variable "name_prefix" {
  description = "Prefix used when naming VPC and subnet resources."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name_prefix))
    error_message = "name_prefix must be 1-63 characters and contain only letters, numbers, and hyphens."
  }
}

# Networking
variable "vpc_cidr" {
  description = "CIDR block for the VPC."
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

  validation {
    condition = length(var.public_subnets) > 0 && alltrue([
      for subnet in values(var.public_subnets) : can(cidrhost(subnet.cidr, 0)) && length(trim(subnet.az)) > 0
    ])
    error_message = "public_subnets must include at least one subnet, and each subnet must have a valid CIDR and non-empty AZ."
  }
}

variable "private_app_subnets" {
  description = "Map of private application subnet definitions keyed by logical name."
  type        = map(object({ cidr = string, az = string }))
  nullable    = false

  validation {
    condition = length(var.private_app_subnets) > 0 && alltrue([
      for subnet in values(var.private_app_subnets) : can(cidrhost(subnet.cidr, 0)) && length(trim(subnet.az)) > 0
    ])
    error_message = "private_app_subnets must include at least one subnet, and each subnet must have a valid CIDR and non-empty AZ."
  }
}

variable "private_db_subnets" {
  description = "Map of private database subnet definitions keyed by logical name."
  type        = map(object({ cidr = string, az = string }))
  nullable    = false

  validation {
    condition = length(var.private_db_subnets) > 0 && alltrue([
      for subnet in values(var.private_db_subnets) : can(cidrhost(subnet.cidr, 0)) && length(trim(subnet.az)) > 0
    ])
    error_message = "private_db_subnets must include at least one subnet, and each subnet must have a valid CIDR and non-empty AZ."
  }
}

# Tags
variable "tags" {
  description = "Map of tags to apply to networking resources."
  type        = map(string)
  default     = {}
}
