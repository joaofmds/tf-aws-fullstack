variable "name_prefix" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "alb_sg_id" { type = string }
variable "container_port" { type = number }
variable "health_check_path" { type = string }
variable "acm_certificate_arn" { type = string, default = null }
variable "tags" { type = map(string) }
