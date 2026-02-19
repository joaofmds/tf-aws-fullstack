variable "domain_name" {
  description = "Root domain name (e.g., example.com)."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for resource naming."
  type        = string
}

variable "api_subdomain" {
  description = "Subdomain for the backend API (without root domain)."
  type        = string
  default     = "api"
}

variable "frontend_enabled" {
  description = "Whether to create ACM certificate for frontend (Amplify)."
  type        = bool
  default     = true
}

variable "backend_enabled" {
  description = "Whether to create ACM certificate and DNS records for backend (ALB)."
  type        = bool
  default     = true
}

variable "frontend_sans" {
  description = "Subject Alternative Names for the frontend certificate (e.g., ['www.example.com'])."
  type        = list(string)
  default     = []
}

variable "frontend_certificate_name" {
  description = "Optional name for the frontend certificate. Defaults to '{name_prefix}-frontend-cert'."
  type        = string
  default     = null
}

variable "backend_certificate_name" {
  description = "Optional name for the backend certificate. Defaults to '{name_prefix}-backend-cert'."
  type        = string
  default     = null
}

variable "alb_dns_name" {
  description = "DNS name of the ALB for Route53 alias records. Required if backend_enabled=true."
  type        = string
  default     = null
}

variable "alb_zone_id" {
  description = "Zone ID of the ALB for Route53 alias records. Required if backend_enabled=true and alb_dns_name is provided."
  type        = string
  default     = null
}

variable "route53_zone_id" {
  description = "Optional Route53 hosted zone ID. If not provided, will try to lookup by domain_name. If create_zone=true, will create a new zone."
  type        = string
  default     = null
}

variable "create_zone" {
  description = "Whether to create a new Route53 hosted zone if it doesn't exist. If false, will only lookup existing zone."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Map of tags to apply to resources."
  type        = map(string)
  default     = {}
}
