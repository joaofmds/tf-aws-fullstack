terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  alias  = "primary"
  region = var.region_primary
}

provider "aws" {
  alias  = "us_east_1"
  region = var.region_edge
}

module "aws_route53_acm_domains" {
  source = "../.."

  providers = {
    aws           = aws.primary
    aws.us_east_1 = aws.us_east_1
  }

  domain_name         = var.domain_name
  environment         = var.environment
  project_name        = var.project_name
  tags                = var.tags

  frontend_enabled    = true
  enable_www          = true
  amplify_app_id      = var.amplify_app_id
  amplify_branch_name = var.amplify_branch_name

  backend_enabled = true
  api_subdomain   = "api"
  alb_dns_name    = var.alb_dns_name
  alb_zone_id     = var.alb_zone_id

  region_primary = var.region_primary
  region_edge    = var.region_edge
}
