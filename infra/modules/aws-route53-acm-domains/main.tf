locals {
  base_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Component   = "dns-acm"
  }

  merged_tags = merge(local.base_tags, var.tags)

  root_domain = trimsuffix(var.domain_name, ".")
  api_fqdn    = "${var.api_subdomain}.${local.root_domain}"
  www_fqdn    = "www.${local.root_domain}"

  frontend_sans = var.enable_www ? [local.www_fqdn] : []

  frontend_urls = var.frontend_enabled ? concat(
    ["https://${local.root_domain}"],
    var.enable_www ? ["https://${local.www_fqdn}"] : []
  ) : []
}

data "aws_region" "primary" {}

data "aws_region" "edge" {
  provider = aws.us_east_1
}

data "aws_route53_zone" "public" {
  name         = "${local.root_domain}."
  private_zone = false
}

resource "aws_acm_certificate" "frontend" {
  count    = var.frontend_enabled ? 1 : 0
  provider = aws.us_east_1

  domain_name               = local.root_domain
  subject_alternative_names = local.frontend_sans
  validation_method         = "DNS"

  tags = merge(local.merged_tags, {
    Name      = "${var.project_name}-${var.environment}-frontend-cert"
    Component = "frontend"
  })

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = data.aws_region.edge.name == var.region_edge
      error_message = "O provider aws.us_east_1 deve apontar para region_edge (${var.region_edge})."
    }
  }
}

resource "aws_route53_record" "frontend_validation" {
  for_each = var.frontend_enabled ? {
    for dvo in aws_acm_certificate.frontend[0].domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id         = data.aws_route53_zone.public.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "frontend" {
  count    = var.frontend_enabled ? 1 : 0
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.frontend[0].arn
  validation_record_fqdns = [for record in aws_route53_record.frontend_validation : record.fqdn]
}

resource "aws_amplify_domain_association" "frontend" {
  count = var.frontend_enabled ? 1 : 0

  app_id      = var.amplify_app_id
  domain_name = local.root_domain

  sub_domain {
    branch_name = var.amplify_branch_name
    prefix      = ""
  }

  dynamic "sub_domain" {
    for_each = var.enable_www ? [1] : []
    content {
      branch_name = var.amplify_branch_name
      prefix      = "www"
    }
  }

  wait_for_verification = true

  lifecycle {
    precondition {
      condition     = var.amplify_app_id != null && var.amplify_branch_name != null
      error_message = "amplify_app_id e amplify_branch_name são obrigatórios quando frontend_enabled=true."
    }
  }

  depends_on = [aws_acm_certificate_validation.frontend]
}

resource "aws_acm_certificate" "backend" {
  count = var.backend_enabled ? 1 : 0

  domain_name       = local.api_fqdn
  validation_method = "DNS"

  tags = merge(local.merged_tags, {
    Name      = "${var.project_name}-${var.environment}-backend-cert"
    Component = "backend"
  })

  lifecycle {
    create_before_destroy = true

    precondition {
      condition     = data.aws_region.primary.name == var.region_primary
      error_message = "O provider aws padrão deve apontar para region_primary (${var.region_primary})."
    }
  }
}

resource "aws_route53_record" "backend_validation" {
  for_each = var.backend_enabled ? {
    for dvo in aws_acm_certificate.backend[0].domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id         = data.aws_route53_zone.public.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "backend" {
  count = var.backend_enabled ? 1 : 0

  certificate_arn         = aws_acm_certificate.backend[0].arn
  validation_record_fqdns = [for record in aws_route53_record.backend_validation : record.fqdn]
}

resource "aws_route53_record" "api_a" {
  count = var.backend_enabled ? 1 : 0

  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.api_fqdn
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

  lifecycle {
    precondition {
      condition     = var.alb_dns_name != null && var.alb_zone_id != null
      error_message = "alb_dns_name e alb_zone_id são obrigatórios quando backend_enabled=true."
    }
  }
}

resource "aws_route53_record" "api_aaaa" {
  count = var.backend_enabled ? 1 : 0

  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.api_fqdn
  type    = "AAAA"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }

  lifecycle {
    precondition {
      condition     = var.alb_dns_name != null && var.alb_zone_id != null
      error_message = "alb_dns_name e alb_zone_id são obrigatórios quando backend_enabled=true."
    }
  }
}
