# patterns/terraform-state-refactoring/variables.tf

variable "environment" {
  type        = string
  default     = "staging"
  description = "Target deployment environment."

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  type        = string
  default     = "francecentral"
  description = "Azure deployment region."

  validation {
    condition     = can(regex("^(francecentral|westeurope|northeurope)$", var.location))
    error_message = "Location must be francecentral, westeurope, or northeurope."
  }
}

variable "asp_sku" {
  type        = string
  default     = "P1v3"
  description = "App Service Plan SKU."

  validation {
    condition     = contains(["B1", "P1v3", "P2v3"], var.asp_sku)
    error_message = "Only production-approved SKUs (B1, P1v3, P2v3) are permitted."
  }
}
