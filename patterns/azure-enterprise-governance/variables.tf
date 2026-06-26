variable "org-name"{
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