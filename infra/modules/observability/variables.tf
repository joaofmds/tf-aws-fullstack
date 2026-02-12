variable "name_prefix" { type = string }
variable "log_retention_days" { type = number }
variable "alb_arn_suffix" { type = string }
variable "target_group_arn_suffix" { type = string }
variable "cluster_name" { type = string }
variable "service_name" { type = string }
variable "tags" { type = map(string) }
