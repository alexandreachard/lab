variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "zone" {
  type        = string
  description = "Zone where the instance template should be created."
}

variable "source_image" {
  description = "Boot disk image, e.g. debian-cloud/debian-12"
  type        = string
}

variable "disk_type" {
  description = "Boot disk type, can be either pd-ssd, local-ssd, or pd-standard"
  type        = string
}

variable "disk_encryption_key" {
  description = "The id of the encryption key that is stored in Google Cloud KMS to use to encrypt all the disks on this instance"
  type        = string
}

variable "subnetwork" {
  description = "The name of the subnetwork to attach this interface to. The subnetwork must exist in the same region this instance will be created in. Either network or subnetwork must be provided."
  type        = string
}