provider "google" {
  project     = "portfolio-514118"
  region      = "us-central1"
}

terraform {
  backend "gcs" {
    bucket  = "gcp-serverless-api-terraform-bucket"
    prefix  = "terraform/state"
  }
}
