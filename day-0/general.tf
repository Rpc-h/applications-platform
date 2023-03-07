terraform {
  backend "gcs" {
    prefix = "day-0"
  }
}

provider "google" {
  project = var.google_project
  region  = var.google_region
}