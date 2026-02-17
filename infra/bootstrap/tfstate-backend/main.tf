module "tfstate_backend" {
  source = "../../modules/tfstate-backend"

  org                      = var.org
  project                  = var.project
  environment              = var.environment
  state_key                = var.state_key
  enable_kms               = var.enable_kms
  create_access_log_bucket = var.create_access_log_bucket
  tags                     = var.tags
}
