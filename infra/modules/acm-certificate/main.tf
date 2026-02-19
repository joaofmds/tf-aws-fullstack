locals {
  merged_tags = merge(
    {
      ManagedBy = "terraform"
    },
    var.tags
  )
  
  # Known domains list for predictable iteration
  all_domains = concat([var.domain_name], var.subject_alternative_names)
}

resource "aws_acm_certificate" "this" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = var.validation_method

  tags = merge(local.merged_tags, {
    Name = var.name != null ? var.name : "${var.domain_name}-cert"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Route53 validation records (only if create_validation_records is true)
# Using count with known domain list length (known before apply)
# Values from domain_validation_options are accessed at apply time
resource "aws_route53_record" "validation" {
  count = var.create_validation_records ? length(local.all_domains) : 0

  zone_id = var.route53_zone_id
  name    = [
    for dvo in aws_acm_certificate.this.domain_validation_options :
    dvo.resource_record_name
    if dvo.domain_name == local.all_domains[count.index]
  ][0]
  type    = [
    for dvo in aws_acm_certificate.this.domain_validation_options :
    dvo.resource_record_type
    if dvo.domain_name == local.all_domains[count.index]
  ][0]
  records = [
    [
      for dvo in aws_acm_certificate.this.domain_validation_options :
      dvo.resource_record_value
      if dvo.domain_name == local.all_domains[count.index]
    ][0]
  ]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn

  validation_record_fqdns = var.create_validation_records ? [
    for record in aws_route53_record.validation : record.fqdn
  ] : var.validation_record_fqdns

  timeouts {
    create = var.validation_timeout
  }
}
