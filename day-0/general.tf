terraform {
  backend "gcs" {
    prefix = "day-0"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.52.0, < 5.0.0"
    }
  }
}

provider "google" {
  project = var.google_project
  region  = var.google_region
}