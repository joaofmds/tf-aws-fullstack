output "hosted_zone_id" {
  value = module.aws_route53_acm_domains.hosted_zone_id
}

output "frontend_urls" {
  value = module.aws_route53_acm_domains.frontend_urls
}

output "backend_url" {
  value = module.aws_route53_acm_domains.backend_url
}

output "backend_certificate_arn" {
  value = module.aws_route53_acm_domains.backend_certificate_arn
}
