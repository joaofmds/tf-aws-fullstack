variable "zone_id" {
  description = "Route53 hosted zone ID where the record will be created."
  type        = string
}

variable "name" {
  description = "Name of the record (e.g., 'api.example.com' or 'www')."
  type        = string
}

variable "type" {
  description = "DNS record type (A, AAAA, CNAME, TXT, MX, NS, etc.)."
  type        = string

  validation {
    condition = contains([
      "A", "AAAA", "CNAME", "MX", "NS", "PTR", "SOA", "SPF", "SRV", "TXT", "CAA"
    ], var.type)
    error_message = "type must be a valid DNS record type."
  }
}

variable "records" {
  description = "List of record values. Required for non-alias records."
  type        = list(string)
  default     = []
}

variable "alias_target" {
  description = "Alias target configuration. Required for alias records (A/AAAA pointing to ALB, CloudFront, etc.)."
  type = object({
    name                   = string
    zone_id                = string
    evaluate_target_health = bool
  })
  default = null
}

variable "ttl" {
  description = "TTL (Time To Live) for the record in seconds. Ignored for alias records."
  type        = number
  default     = 300
}

variable "allow_overwrite" {
  description = "Allow Terraform to overwrite existing records."
  type        = bool
  default     = false
}

variable "set_identifier" {
  description = "Unique identifier to differentiate records with the same name and type (for routing policies)."
  type        = string
  default     = null
}

variable "weighted_routing_policy" {
  description = "Weighted routing policy configuration."
  type = object({
    weight = number
  })
  default = null
}

variable "failover_routing_policy" {
  description = "Failover routing policy configuration."
  type = object({
    type = string # PRIMARY or SECONDARY
  })
  default = null
}

variable "geolocation_routing_policy" {
  description = "Geolocation routing policy configuration."
  type = object({
    continent   = optional(string)
    country     = optional(string)
    subdivision = optional(string)
  })
  default = null
}

variable "latency_routing_policy" {
  description = "Latency routing policy configuration."
  type = object({
    region = string
  })
  default = null
}

variable "multivalue_answer_routing_policy" {
  description = "Enable multivalue answer routing policy."
  type        = bool
  default     = false
}
