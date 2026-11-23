variable "org-name" {
  type        = string
  description = "The org name"
}

variable "dev_subscription_id" {
  type        = string
  description = "The target subscription ID for development workloads"
}

variable "prod_subscription_id" {
  type        = string
  description = "The target subscription ID for production workloads"
}

variable "allowed_locations" {
  type        = list(string)
  description = "Azure regions allowed in Production"
}

variable "team_a_group_object_id" {
  type        = string
  description = "groupd id of team A entra group"
}

variable "ops_group_object_id" {
  type        = string
  description = "groupd id of ops entra group"
}
