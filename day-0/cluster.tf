resource "google_container_cluster" "main" {
  name = var.name

  #TODO - do not hardcode
  location = "europe-west6"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network = google_compute_network.main.name

  cluster_autoscaling {
    enabled = true

    resource_limits {
      resource_type = "memory"
      minimum       = var.memory_min
      maximum       = var.memory_max
    }

    resource_limits {
      resource_type = "cpu"
      minimum       = var.cpu_min
      maximum       = var.cpu_max
    }

    auto_provisioning_defaults {
      disk_type       = "pd-balanced"
      disk_size       = "50"
      image_type      = "COS_CONTAINERD"
      service_account = google_service_account.main.email
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]

      management {
        auto_upgrade = true
        auto_repair  = true
      }

      upgrade_settings {
        strategy  = "SURGE"
        max_surge = 1
      }

      shielded_instance_config {
        enable_integrity_monitoring = true
      }
    }
  }

  release_channel {
    //TODO - maybe switch to STABLE if becomes too risky?
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${var.google_project}.svc.id.goog"
  }

  cost_management_config {
    enabled = true
  }

  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS"
    ]
  }

  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      #Workloads is deprecated in favour of managed prometheus
    ]

    managed_prometheus {
      enabled = true
    }
  }
}

#TODO - add SSH keys to nodes
resource "google_container_node_pool" "main" {
  name     = var.name
  location = var.google_region
  cluster  = google_container_cluster.main.name
  #Node count per zone
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-standard-2"

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.main.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}