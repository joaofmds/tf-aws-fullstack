variable "project_name" {
  description = "Project name used in resource naming."
  type        = string
  nullable    = false

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name cannot be empty."
  }
}

variable "environment" {
  description = "Deployment environment. Supported values: dev or prod."
  type        = string
  nullable    = false

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be one of: dev, prod."
  }
}

variable "app_mode" {
  description = "Amplify integration mode. connected = linked to git repository, webhook = external CI/CD pipeline triggers webhook deployments."
  type        = string
  default     = "connected"

  validation {
    condition     = contains(["connected", "webhook"], var.app_mode)
    error_message = "app_mode must be either connected or webhook."
  }
}

variable "repository_url" {
  description = "Git repository URL for the frontend source code (required in connected mode)."
  type        = string
  default     = null
}

variable "repository_branch" {
  description = "Primary branch to deploy for this environment (required in connected mode)."
  type        = string
  default     = null
}

variable "github_oauth_token" {
  description = "GitHub OAuth token used by Amplify when app_mode=connected. Prefer short-lived/least-privilege tokens."
  type        = string
  default     = null
  sensitive   = true
}

variable "build_type" {
  description = "Frontend build type used to compute defaults and API env variable naming."
  type        = string
  default     = "vite"

  validation {
    condition     = contains(["vite", "nextjs", "custom"], var.build_type)
    error_message = "build_type must be one of: vite, nextjs, custom."
  }
}

variable "amplify_build_spec" {
  description = "Optional custom Amplify build spec in YAML. If null, a secure default is generated from build_type."
  type        = string
  default     = null
}

variable "app_root" {
  description = "Monorepo root path for frontend app relative to repository root."
  type        = string
  default     = "frontend"
}

variable "node_version" {
  description = "Node.js version used by Amplify build image."
  type        = string
  default     = "20"
}

variable "backend_base_url" {
  description = "Base URL for backend API (ALB/CloudFront/API domain), injected into frontend environment variables."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^https://", var.backend_base_url))
    error_message = "backend_base_url must start with https:// for production-grade security."
  }
}

variable "frontend_env_vars" {
  description = "Additional non-sensitive environment variables for Amplify app/branch."
  type        = map(string)
  default     = {}
}

variable "frontend_secrets" {
  description = "Sensitive frontend variables placeholder. Not persisted by this module because Amplify env vars would store values in Terraform state."
  type        = map(string)
  default     = {}
  sensitive   = true

  validation {
    condition     = length(var.frontend_secrets) == 0
    error_message = "frontend_secrets is intentionally blocked to avoid secret leakage in Terraform state. Use AWS Secrets Manager/SSM + runtime secret fetch in the app build process."
  }
}

variable "enable_pr_previews" {
  description = "Enable pull request previews in Amplify auto branch creation configuration."
  type        = bool
  default     = true
}

variable "enable_basic_auth_for_previews" {
  description = "Enable Basic Auth for auto-created preview branches."
  type        = bool
  default     = false
}

variable "basic_auth_username" {
  description = "Username for Basic Auth on preview branches when enabled."
  type        = string
  default     = null
  sensitive   = true
}

variable "basic_auth_password" {
  description = "Password for Basic Auth on preview branches when enabled."
  type        = string
  default     = null
  sensitive   = true
}

variable "custom_domain_enabled" {
  description = "Whether to associate a custom domain with Amplify app."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Root domain name (for example: example.com). Required when custom_domain_enabled=true."
  type        = string
  default     = null
}

variable "prod_subdomain" {
  description = "Production subdomain prefix. Use 'www' for www.example.com or empty string for apex root only."
  type        = string
  default     = "www"
}

variable "dev_subdomain" {
  description = "Development subdomain prefix, for example dev (dev.example.com)."
  type        = string
  default     = "dev"
}

variable "enable_webhook" {
  description = "Force creation of Amplify webhook in addition to selected app_mode behavior."
  type        = bool
  default     = false
}

variable "preview_branch_patterns" {
  description = "Glob patterns for auto-created preview branches."
  type        = list(string)
  default     = ["feature/*", "bugfix/*", "hotfix/*"]
}

variable "enable_auto_branch_creation" {
  description = "Enable automatic branch creation for preview patterns."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Map of tags applied to all supported Amplify resources."
  type        = map(string)
  default     = {}
}
