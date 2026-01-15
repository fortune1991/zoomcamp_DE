terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.12.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project_id
  region      = var.region
}

# VM instance
resource "google_compute_instance" "default" {
  name         = var.machine_name
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-minimal-2204-lts"
    }
  }

  network_interface {
    network       = "default"
    access_config {} # enables external IP
  }

  service_account {
    email = var.service_account_email
    scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.full_control"
    ]
  }

  # Add this so the firewall rule can target the VM
  tags = ["jupyter-lab"]
}

# Firewall to allow Jupyter Lab (port 8888)
resource "google_compute_firewall" "jupyter_lab" {
  name    = "${var.machine_name}-jupyter-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8888"]
  }

  source_ranges = ["34.126.99.255/32"]  # Restrict to my IP
  target_tags   = ["jupyter-lab"] # applies to any VM with this tag
}
