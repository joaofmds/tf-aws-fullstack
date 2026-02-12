variable "name_prefix" { type = string }
variable "database_user" { type = string }
variable "database_password" { type = string, sensitive = true }
variable "database_name" { type = string }
variable "cors_origins" { type = string }
variable "tags" { type = map(string) }
