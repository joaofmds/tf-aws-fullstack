variable "name_prefix" { type = string }
variable "vpc_cidr" { type = string }
variable "public_subnets" {
  type = map(object({ cidr = string, az = string }))
}
variable "private_app_subnets" {
  type = map(object({ cidr = string, az = string }))
}
variable "private_db_subnets" {
  type = map(object({ cidr = string, az = string }))
}
variable "tags" { type = map(string) }
