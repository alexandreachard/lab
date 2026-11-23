terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0" # vm 8.0.0 and lb-http 6.x modules require google < 5
    }
  }
}
