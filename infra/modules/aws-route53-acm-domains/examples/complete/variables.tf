variable "domain_name" {
  type        = string
  description = "Domínio raiz (ex: joaofmsouza.com.br)."
  default     = "joaofmsouza.com.br"
}

variable "environment" {
  type        = string
  description = "Ambiente (dev/prod)."
  default     = "prod"
}

variable "project_name" {
  type        = string
  description = "Nome do projeto."
  default     = "joaofmsouza"
}

variable "region_primary" {
  type        = string
  description = "Região primária do stack (backend/ALB)."
  default     = "us-east-1"
}

variable "region_edge" {
  type        = string
  description = "Região edge para certificado frontend (CloudFront/Amplify)."
  default     = "us-east-1"
}

variable "amplify_app_id" {
  type        = string
  description = "ID do Amplify app existente."
}

variable "amplify_branch_name" {
  type        = string
  description = "Branch do Amplify para mapear no domínio."
  default     = "main"
}

variable "alb_dns_name" {
  type        = string
  description = "DNS do ALB existente."
}

variable "alb_zone_id" {
  type        = string
  description = "Zone ID do ALB existente."
}

variable "tags" {
  type        = map(string)
  description = "Tags adicionais."
  default = {
    CostCenter = "plataforma"
  }
}
