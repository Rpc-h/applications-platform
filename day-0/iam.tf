resource "google_service_account" "main" {
  account_id   = "${var.name}-node"
  display_name = "${var.name}-node"
}

resource "google_project_iam_binding" "main" {
  members = [
    "serviceAccount:${google_service_account.main.email}"
  ]
  role = "roles/container.nodeServiceAccount"
  #Not inferred from the provider
  project = var.google_project
}
