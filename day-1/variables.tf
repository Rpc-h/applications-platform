variable "google_project" {
  type        = string
  description = "The ID of the GCP project"
}

variable "google_region" {
  type        = string
  description = "The default GCP region for resource placement"
}

variable "name" {
  type        = string
  description = "The name used in naming resources"
}

variable "domain" {
  type        = string
  description = "The domain name for the DNS zone"
}

variable "argocd_repo_url" {
  type        = string
  description = "The URL for the ArgoCD repository"
}

variable "argocd_credentials_url" {
  type        = string
  description = "The URL for the ArgoCD credentials template"
}

variable "argocd_credentials_key" {
  type        = string
  description = "The base64 encoded SSH private key for the ArgoCD credentials template"
}