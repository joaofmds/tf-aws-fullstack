variable "domain_name" {
  description = "Primary domain name for the certificate."
  type        = string
}

variable "subject_alternative_names" {
  description = "List of subject alternative names (SANs) for the certificate."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for san in var.subject_alternative_names : can(
        regex("^(?=.{1,253}$)(?!-)(?:[a-zA-Z0-9-]{1,63}\\.)+[a-zA-Z]{2,63}$", san)
      )
    ])
    error_message = "All subject_alternative_names must be valid FQDNs."
  }
}

variable "validation_method" {
  description = "Method to use for certificate validation. Must be DNS or EMAIL."
  type        = string
  default     = "DNS"

  validation {
    condition     = contains(["DNS", "EMAIL"], var.validation_method)
    error_message = "validation_method must be either DNS or EMAIL."
  }
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for automatic DNS validation. If provided, validation records will be created automatically."
  type        = string
  default     = null
}

variable "create_validation_records" {
  description = "Whether to create Route53 validation records. Set to true if route53_zone_id will be provided (even if known only after apply)."
  type        = bool
  default     = false
}

variable "validation_record_fqdns" {
  description = "List of FQDNs for validation records (required if route53_zone_id is not provided and validation_method is DNS)."
  type        = list(string)
  default     = []
}

variable "validation_timeout" {
  description = "Timeout for certificate validation."
  type        = string
  default     = "5m"
}

variable "name" {
  description = "Optional name tag for the certificate. Defaults to '{domain_name}-cert'."
  type        = string
  default     = null
}

# Note: To use a different AWS provider (e.g., us-east-1 for edge certificates),
# pass it via the providers block in the module call:
# providers = { aws = aws.us_east_1 }

variable "tags" {
  description = "Map of tags to apply to the certificate."
  type        = map(string)
  default     = {}
}
