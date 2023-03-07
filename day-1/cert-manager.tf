resource "google_service_account" "cert_manager" {
  account_id   = "${var.name}-cert-manager"
  display_name = "${var.name}-cert-manager"
}

#TODO - see main.tf
#resource "google_project_iam_binding" "cert_manager" {
#  members = [
#    "serviceAccount:${google_service_account.cert_manager.email}"
#  ]
#  role = "roles/dns.admin"
#  #Not inferred from the provider
#  project = var.google_project
#}

resource "google_service_account_iam_binding" "cert_manager" {
  members = [
    "serviceAccount:${var.google_project}.svc.id.goog[cert-manager/cert-manager]"
  ]
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.cert_manager.name
}