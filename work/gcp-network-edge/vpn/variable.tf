variable "project_id" {
  type        = string
  description = "Project ID"
  default     = "net-spoke-prod-0"
}

variable "region" {
  type        = string
  description = "Region where the instance template should be created."
  default     = "europe-west9"
}

variable "network" {
  description = "The name of the network to attach this interface to"
  type        = string
  default     = "prod-spoke-0"
}