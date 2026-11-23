variable "project_id" {
  type        = string
  description = "Project ID of the network (spoke) project"
}

variable "network" {
  type        = string
  description = "VPC network name"
}

variable "vm_service_account_email" {
  type        = string
  description = "Service account of the VMs reachable over SSH through IAP"
}
