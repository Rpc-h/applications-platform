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

variable "memory_min" {
  type        = number
  default     = 8
  description = "Minimum amount of memory for auto-provisioned nodes"
}

variable "memory_max" {
  type        = number
  default     = 32
  description = "Maximum amount of memory for auto-provisioned nodes"
}

variable "cpu_min" {
  type        = number
  default     = 4
  description = "Minimum amount of CPU cores for auto-provisioned nodes"
}

variable "cpu_max" {
  type        = number
  default     = 8
  description = "Maximum amount of CPU cores for auto-provisioned nodes"
}

