terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }

  backend "gcs" {
    bucket = "weitzman-musa-geocloud-tfstate"
    prefix = "tf/state-s25"
  }
}

provider "google" {
  project                         = "weitzman-musa-geocloud"
  region                          = "us-east4"
  add_terraform_attribution_label = false
}
