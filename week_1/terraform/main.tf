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
  project     = "cosmic-stacker-479110-q1"
  region      = var.region
}


resource "google_storage_bucket" "demo_bucket" {
  name          = var.bucket_name
  location      = var.location
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "demo_dataset" {
  dataset_id                  = "cosmic_stacker_bq_dataset"
  description                 = "Test Dataset"
  location                    = var.location
}