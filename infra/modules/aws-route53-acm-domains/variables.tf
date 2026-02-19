variable "domain_name" {
  description = "Domínio raiz público (ex: joaofmsouza.com.br)."
  type        = string

  validation {
    condition     = can(regex("^(?=.{1,253}$)(?!-)(?:[a-zA-Z0-9-]{1,63}\\.)+[a-zA-Z]{2,63}$", var.domain_name))
    error_message = "domain_name deve ser um FQDN válido (ex: joaofmsouza.com.br)."
  }
}

variable "environment" {
  description = "Ambiente de implantação."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment deve ser dev ou prod."
  }

  validation {
    condition     = var.environment != "prod" || var.enable_www
    error_message = "Em prod, enable_www deve ser true para manter cobertura de domínio com www."
  }
}

variable "project_name" {
  description = "Nome do projeto usado em tags e nomes de recursos."
  type        = string

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name não pode ser vazio."
  }
}

variable "tags" {
  description = "Tags adicionais aplicadas aos recursos."
  type        = map(string)
  default     = {}
}

variable "enable_www" {
  description = "Habilita subdomínio www no frontend (Amplify + SAN no certificado frontend)."
  type        = bool
  default     = true
}

variable "frontend_enabled" {
  description = "Habilita criação do certificado frontend e associação de domínio no Amplify."
  type        = bool
  default     = true
}

variable "backend_enabled" {
  description = "Habilita criação do certificado backend e registro DNS api -> ALB."
  type        = bool
  default     = true
}

variable "amplify_app_id" {
  description = "ID do Amplify App existente (obrigatório se frontend_enabled=true)."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = !var.frontend_enabled || (var.amplify_app_id != null && length(trimspace(var.amplify_app_id)) > 0)
    error_message = "amplify_app_id é obrigatório quando frontend_enabled=true."
  }
}

variable "amplify_branch_name" {
  description = "Nome da branch do Amplify para mapear no domínio (obrigatório se frontend_enabled=true)."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = !var.frontend_enabled || (var.amplify_branch_name != null && length(trimspace(var.amplify_branch_name)) > 0)
    error_message = "amplify_branch_name é obrigatório quando frontend_enabled=true."
  }
}

variable "alb_dns_name" {
  description = "DNS name do ALB existente (obrigatório se backend_enabled=true)."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = !var.backend_enabled || (var.alb_dns_name != null && length(trimspace(var.alb_dns_name)) > 0)
    error_message = "alb_dns_name é obrigatório quando backend_enabled=true."
  }
}

variable "alb_zone_id" {
  description = "Zone ID do ALB existente (obrigatório se backend_enabled=true)."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = !var.backend_enabled || (var.alb_zone_id != null && length(trimspace(var.alb_zone_id)) > 0)
    error_message = "alb_zone_id é obrigatório quando backend_enabled=true."
  }
}

variable "api_subdomain" {
  description = "Subdomínio do backend (sem o domínio raiz)."
  type        = string
  default     = "api"

  validation {
    condition     = can(regex("^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$", var.api_subdomain))
    error_message = "api_subdomain deve conter apenas [a-z0-9-], sem ponto, e não pode iniciar/finalizar com hífen."
  }
}

variable "region_primary" {
  description = "Região primária do stack (onde está o ALB/backend)."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d$", var.region_primary))
    error_message = "region_primary deve estar no formato AWS region (ex: us-east-1)."
  }
}

variable "region_edge" {
  description = "Região edge para certificado frontend (normalmente us-east-1)."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d$", var.region_edge))
    error_message = "region_edge deve estar no formato AWS region (ex: us-east-1)."
  }
}
