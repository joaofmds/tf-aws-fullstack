locals {
  root_domain = trimsuffix(trimspace(var.domain_name), ".")
  api_fqdn    = "${var.api_subdomain}.${local.root_domain}"
}

# Route53 Zone - create or lookup
module "route53_zone" {
  count = var.create_zone ? 1 : 0
  
  source = "../route53-zone"
  
  domain_name = local.root_domain
  name        = "${var.name_prefix}-zone"
  tags        = var.tags
}

# Route53 Zone lookup (if not creating)
data "aws_route53_zone" "public" {
  count        = var.create_zone ? 0 : 1
  zone_id      = var.route53_zone_id
  name         = var.route53_zone_id == null ? "${local.root_domain}." : null
  private_zone = false
}

locals {
  zone_id = var.create_zone ? module.route53_zone[0].zone_id : data.aws_route53_zone.public[0].zone_id
}

# ACM Certificate for Frontend (Amplify) - must be in us-east-1
module "acm_frontend" {
  count = var.frontend_enabled ? 1 : 0
  
  source = "../acm-certificate"
  
  providers = {
    aws = aws.us_east_1
  }
  
  domain_name               = local.root_domain
  subject_alternative_names = var.frontend_sans
  validation_method         = "DNS"
  route53_zone_id          = local.zone_id
  create_validation_records = true
  
  name = var.frontend_certificate_name != null ? var.frontend_certificate_name : "${var.name_prefix}-frontend-cert"
  tags = merge(var.tags, {
    Component = "frontend"
  })
}

# ACM Certificate for Backend (ALB) - in primary region
module "acm_backend" {
  count = var.backend_enabled ? 1 : 0
  
  source = "../acm-certificate"
  
  domain_name               = local.api_fqdn
  validation_method         = "DNS"
  route53_zone_id           = local.zone_id
  create_validation_records = true
  
  name = var.backend_certificate_name != null ? var.backend_certificate_name : "${var.name_prefix}-backend-cert"
  tags = merge(var.tags, {
    Component = "backend"
  })
}

# Route53 A record for API subdomain pointing to ALB
module "route53_api_a" {
  count = var.backend_enabled && var.alb_dns_name != null ? 1 : 0
  
  source = "../route53-record"
  
  zone_id = local.zone_id
  name    = local.api_fqdn
  type    = "A"
  
  alias_target = {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Route53 AAAA record for API subdomain pointing to ALB
module "route53_api_aaaa" {
  count = var.backend_enabled && var.alb_dns_name != null ? 1 : 0
  
  source = "../route53-record"
  
  zone_id = local.zone_id
  name    = local.api_fqdn
  type    = "AAAA"
  
  alias_target = {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
