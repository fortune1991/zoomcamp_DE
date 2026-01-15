variable "machine_name" {
  description = "Name for my machine"
  default     = "terraform-spark-machine"
}

variable "region" {
  description = "region"
  default     = "asia-southeast1"
}

variable "zone" {
  description = "zone"
  default     = "asia-southeast1-b"
}

variable "credentials" {
  description = "My credentials file"
  default     = "./keys/dbt-tutorial-keys.json"
}

variable "project_id" {
  description = "My project id"
  default     = "dbt-tutorial-481800"
}

variable "service_account_email" {
  description = "Service account e-mail address"
  default     = "dbt-226@dbt-tutorial-481800.iam.gserviceaccount.com"
}