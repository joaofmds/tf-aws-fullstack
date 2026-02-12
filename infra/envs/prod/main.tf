data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  })
}

module "network" {
  source              = "../../modules/network"
  name_prefix         = local.name_prefix
  vpc_cidr            = var.vpc_cidr
  public_subnets      = var.public_subnets
  private_app_subnets = var.private_app_subnets
  private_db_subnets  = var.private_db_subnets
  tags                = local.common_tags
}

module "security" {
  source         = "../../modules/security"
  name_prefix    = local.name_prefix
  vpc_id         = module.network.vpc_id
  container_port = var.container_port
  tags           = local.common_tags
}

module "alb" {
  source              = "../../modules/alb"
  name_prefix         = local.name_prefix
  vpc_id              = module.network.vpc_id
  public_subnet_ids   = module.network.public_subnet_ids
  alb_sg_id           = module.security.alb_sg_id
  container_port      = var.container_port
  health_check_path   = "/healthz"
  acm_certificate_arn = var.acm_certificate_arn
  tags                = local.common_tags
}

module "ecr" {
  source      = "../../modules/ecr"
  name_prefix = local.name_prefix
  tags        = local.common_tags
}

module "s3" {
  source          = "../../modules/s3"
  name_prefix     = local.name_prefix
  account_id      = data.aws_caller_identity.current.account_id
  expiration_days = var.upload_retention_days
  tags            = local.common_tags
}

module "secrets" {
  source            = "../../modules/secrets"
  name_prefix       = local.name_prefix
  database_user     = var.database_user
  database_password = var.database_password
  database_name     = var.database_name
  cors_origins      = var.cors_origins
  tags              = local.common_tags
}

module "rds" {
  source                  = "../../modules/rds"
  name_prefix             = local.name_prefix
  private_db_subnet_ids   = module.network.private_db_subnet_ids
  rds_sg_id               = module.security.rds_sg_id
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  max_allocated_storage   = var.db_max_allocated_storage
  db_name                 = var.database_name
  db_user                 = var.database_user
  db_password             = var.database_password
  backup_retention_period = var.db_backup_retention
  maintenance_window      = var.db_maintenance_window
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = var.db_skip_final_snapshot
  apply_immediately       = var.db_apply_immediately
  db_timezone             = var.timezone
  tags                    = local.common_tags
}

module "ecs" {
  source             = "../../modules/ecs"
  name_prefix        = local.name_prefix
  region             = var.aws_region
  container_port     = var.container_port
  backend_image      = "${module.ecr.backend_repository_url}:${var.backend_image_tag}"
  cron_image         = "${module.ecr.cron_repository_url}:${var.cron_image_tag}"
  backend_cpu        = var.backend_cpu
  backend_memory     = var.backend_memory
  cron_cpu           = var.cron_cpu
  cron_memory        = var.cron_memory
  desired_count      = var.desired_count
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
  app_workers        = var.app_workers
  timezone           = var.timezone
  db_host            = module.rds.db_endpoint
  db_port            = module.rds.db_port
  db_name            = module.rds.db_name
  db_secret_arn      = module.secrets.db_secret_arn
  cors_param_arn     = module.secrets.cors_origins_param_arn
  uploads_bucket_name = module.s3.uploads_bucket_name
  uploads_bucket_arn = module.s3.uploads_bucket_arn
  private_subnet_ids = module.network.private_app_subnet_ids
  ecs_sg_id          = module.security.ecs_sg_id
  target_group_arn   = module.alb.target_group_arn
  log_retention_days = var.log_retention_days
  cron_schedule      = var.cron_schedule
}


module "observability" {
  source                  = "../../modules/observability"
  name_prefix             = local.name_prefix
  log_retention_days      = var.log_retention_days
  alb_arn_suffix          = trimprefix(module.alb.alb_arn, "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:loadbalancer/")
  target_group_arn_suffix = trimprefix(module.alb.target_group_arn, "arn:aws:elasticloadbalancing:${var.aws_region}:${data.aws_caller_identity.current.account_id}:targetgroup/")
  cluster_name            = module.ecs.cluster_name
  service_name            = module.ecs.service_name
  tags                    = local.common_tags
}
module "oidc" {
  source      = "../../modules/oidc"
  name_prefix = local.name_prefix
  github_org  = var.github_org
  github_repo = var.github_repo
}
