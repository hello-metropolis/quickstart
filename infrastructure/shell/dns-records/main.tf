provider "google" {
  version     = "3.5.0"
  credentials = "gcp-service-account.json"
  project     = var.project_id
}


data "terraform_remote_state" "terraform-state" {
  backend = "gcs"
  config = {
    bucket      = var.bucket_name
    prefix      = "metropolis-quickstart-managed-state-${var.sandbox_id}"
    credentials = "gcp-service-account.json"
  }
}

resource "google_dns_record_set" "custom-record" {
  managed_zone = var.managed_zone
  name         = "${var.domain}."
  type         = "A"
  ttl          = 300
  rrdatas      = [var.ip_address]
}