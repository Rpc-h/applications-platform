resource "google_compute_network" "main" {
  name                    = var.name
  auto_create_subnetworks = true
  routing_mode            = "REGIONAL"
}

resource "google_compute_firewall" "main" {
  name    = "ssh"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports = [
      "22"
    ]
  }

  source_ranges = [
    "0.0.0.0/0"
  ]
}