variable "aws_region" { type = string, default = "us-east-1" }
variable "project" { type = string, default = "tf-aws-fullstack" }
variable "environment" { type = string }
variable "container_port" { type = number, default = 8081 }

variable "vpc_cidr" { type = string }
variable "public_subnets" { type = map(object({ cidr = string, az = string })) }
variable "private_app_subnets" { type = map(object({ cidr = string, az = string })) }
variable "private_db_subnets" { type = map(object({ cidr = string, az = string })) }

variable "database_name" { type = string }
variable "database_user" { type = string }
variable "database_password" { type = string, sensitive = true }
variable "db_instance_class" { type = string }
variable "db_allocated_storage" { type = number }
variable "db_max_allocated_storage" { type = number }
variable "db_backup_retention" { type = number }
variable "db_maintenance_window" { type = string }
variable "db_deletion_protection" { type = bool }
variable "db_skip_final_snapshot" { type = bool }
variable "db_apply_immediately" { type = bool }

variable "backend_image_tag" { type = string, default = "latest" }
variable "cron_image_tag" { type = string, default = "latest" }
variable "backend_cpu" { type = number }
variable "backend_memory" { type = number }
variable "cron_cpu" { type = number }
variable "cron_memory" { type = number }
variable "desired_count" { type = number }
variable "min_capacity" { type = number }
variable "max_capacity" { type = number }
variable "app_workers" { type = number, default = 2 }

variable "timezone" { type = string, default = "UTC" }
variable "cron_schedule" { type = string, default = "rate(6 hours)" }
variable "upload_retention_days" { type = number, default = 30 }
variable "log_retention_days" { type = number, default = 14 }
variable "cors_origins" { type = string }
variable "acm_certificate_arn" { type = string, default = null }

variable "github_org" { type = string }
variable "github_repo" { type = string }
variable "tags" { type = map(string), default = {} }
