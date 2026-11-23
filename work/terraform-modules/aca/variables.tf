variable "env_name" { type = string }
variable "location" { type = string }
variable "subnet_id" { type = string }
variable "min_replicas" { type = number }
variable "shared_acr_id" { type = string }
variable "acr_login_server" { type = string }
variable "app_env" {
  type        = map(string)
  description = "Environment variables of the container (no secrets)"
  default     = {}
}