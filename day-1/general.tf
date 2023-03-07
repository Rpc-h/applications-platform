terraform {
  backend "gcs" {
    prefix = "day-1"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.52.0, < 5.0.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8.0, < 3.0.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0, < 2.0.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.17.0, < 3.0.0"
    }
  }
}

provider "google" {
  project = var.google_project
  region  = var.google_region
}

provider "helm" {
  kubernetes {
    //Made available from the pipeline
    config_path = "~/.kube/config"
  }
}

provider "kubectl" {
  //Made available from the pipeline
  config_path = "~/.kube/config"
}

provider "kubernetes" {
  //Made available from the pipeline
  config_path = "~/.kube/config"
}