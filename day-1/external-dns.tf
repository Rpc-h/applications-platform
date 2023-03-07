resource "google_service_account" "external_dns" {
  account_id   = "${var.name}-external-dns"
  display_name = "${var.name}-external-dns"
}

#TODO - see main.tf
#resource "google_project_iam_binding" "external_dns" {
#  members = [
#    "serviceAccount:${google_service_account.external_dns.email}"
#  ]
#  role = "roles/dns.admin"
#  #Not inferred from the provider
#  project = var.google_project
#}

resource "google_service_account_iam_binding" "external_dns" {
  members = [
    "serviceAccount:${var.google_project}.svc.id.goog[external-dns/external-dns]"
  ]
  role               = "roles/iam.workloadIdentityUser"
  service_account_id = google_service_account.external_dns.name
}