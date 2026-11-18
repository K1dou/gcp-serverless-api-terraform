terraform {
  required_version = "~> 1.17"

  backend "gcs" {}

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
