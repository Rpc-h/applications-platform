#TODO - https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_binding
#Looks like GCP is yolo deleting or assigning service accounts to roles...
resource "google_project_iam_binding" "main" {
  members = [
    "serviceAccount:${google_service_account.cert_manager.email}",
    "serviceAccount:${google_service_account.external_dns.email}"
  ]
  role = "roles/dns.admin"
  #Not inferred from the provider
  project = var.google_project
}
