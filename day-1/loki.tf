resource "google_service_account" "loki" {
  account_id   = "${var.name}-loki"
  display_name = "${var.name}-loki"
}

resource "google_service_account_iam_binding" "loki" {
  members = [
    "serviceAccount:${var.google_project}.svc.id.goog[monitoring/loki]"
  ]
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.loki.name
}

resource "google_storage_bucket" "loki" {
  location                    = var.google_region
  name                        = "${var.name}-loki"
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  autoclass {
    enabled = true
  }
}