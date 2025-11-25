variable "bucket_name" {
  description = "Name for my bucket"
  default     = "cosmic-stacker-479110-q1-demo_bucket"
}

variable "region" {
  description = "region"
  default     = "us-central1"
}

variable "location" {
  description = "location"
  default     = "US"
}

variable "credentials" {
  description = "My credentials file"
  default     = "./keys/my_creds.json"
}