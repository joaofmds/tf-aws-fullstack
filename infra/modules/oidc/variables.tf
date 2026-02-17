variable "name_prefix" {
  description = "Prefix used when naming IAM OIDC resources."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,63}$", var.name_prefix))
    error_message = "name_prefix must be 1-63 characters and contain only letters, numbers, and hyphens."
  }
}

# App / Service
variable "github_org" {
  description = "GitHub organization that is allowed to assume configured roles."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+$", var.github_org))
    error_message = "github_org must contain only GitHub organization name characters."
  }
}

variable "github_repo" {
  description = "GitHub repository name allowed to assume configured roles."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+$", var.github_repo))
    error_message = "github_repo must contain only GitHub repository name characters."
  }
}
