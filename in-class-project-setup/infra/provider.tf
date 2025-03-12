terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.8.0"
    }
  }

  backend "gcs" {
    bucket  = format("%s-config", var.cama_prefix)
    prefix  = "tf/state"
  }
}

provider "google" {
  project = var.cama_prefix
  region  = var.location
}