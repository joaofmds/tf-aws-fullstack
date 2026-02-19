variable "domain_name" {
  description = "Domain name for the hosted zone (e.g., example.com)."
  type        = string
}

variable "comment" {
  description = "Comment for the hosted zone."
  type        = string
  default     = null
}

variable "name" {
  description = "Optional name tag for the hosted zone. Defaults to '{domain_name}-zone'."
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of tags to apply to the hosted zone."
  type        = map(string)
  default     = {}
}
