variable "name_prefix" { type = string }
variable "private_db_subnet_ids" { type = list(string) }
variable "rds_sg_id" { type = string }
variable "instance_class" { type = string }
variable "allocated_storage" { type = number }
variable "max_allocated_storage" { type = number }
variable "db_name" { type = string }
variable "db_user" { type = string }
variable "db_password" { type = string, sensitive = true }
variable "backup_retention_period" { type = number }
variable "maintenance_window" { type = string }
variable "deletion_protection" { type = bool }
variable "skip_final_snapshot" { type = bool }
variable "apply_immediately" { type = bool }
variable "db_timezone" { type = string, default = "UTC" }
variable "tags" { type = map(string) }
