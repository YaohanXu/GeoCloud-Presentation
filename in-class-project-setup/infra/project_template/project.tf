# GCS Buckets:
# ${project_name}-raw_data       Raw data from the sources.
# ${project_name}-prepared_data  Data prepared for external tables in BigQuery.
# ${project_name}-temp_data      Temporary data used during processing. Files stored here will be deleted after a few days.
# ${project_name}-public         Public data that can be accessed by anyone over HTTP.

variable "project_name" {}
variable "location" {}

resource "google_storage_bucket" "raw_data" {
  project                     = var.project_name
  name                        = format("%s-raw_data", var.project_name)
  location                    = var.location
  uniform_bucket_level_access = true

  autoclass {
    enabled                = true
    terminal_storage_class = "ARCHIVE"
  }
}

resource "google_storage_bucket" "prepared_data" {
  project                     = var.project_name
  name                        = format("%s-prepared_data", var.project_name)
  location                    = var.location
  uniform_bucket_level_access = true

  autoclass {
    enabled                = true
    terminal_storage_class = "ARCHIVE"
  }
}

resource "google_storage_bucket" "temp_data" {
  project                     = var.project_name
  name                        = format("%s-temp_data", var.project_name)
  location                    = var.location
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 7
    }

    action {
      type = "Delete"
    }
  }
}

resource "google_storage_bucket" "public" {
  project                     = var.project_name
  name                        = format("%s-public", var.project_name)
  location                    = var.location
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "POST", "PUT", "OPTIONS", "HEAD", "DELETE"]
    response_header = ["*"]
  }
}

resource "google_storage_bucket_iam_member" "public_viewer" {
  bucket = google_storage_bucket.public.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# BigQuery Datasets:
# source   External tables backed by prepared source data in Cloud Storage.
# core     Data that is ready to be used for analysis. For the most part, the tables here are just copies of the external tables.
# derived  Data that has been derived from core data. Outputs from analyses or models go here.

resource "google_bigquery_dataset" "source" {
  project    = var.project_name
  dataset_id = "source"
  location   = var.location
}

resource "google_bigquery_dataset" "core" {
  project    = var.project_name
  dataset_id = "core"
  location   = var.location
}

resource "google_bigquery_dataset" "derived" {
  project    = var.project_name
  dataset_id = "derived"
  location   = var.location
}

# Service Account:
# A service account named `data-pipeline-user` is used to provide necessary
# access to different GCP services. The following roles are assigned to the
# service account:
# - Storage Object Admin
# - BigQuery Job User
# - Cloud Functions Invoker
# - Cloud Run Invoker
# - Workflows Invoker

resource "google_service_account" "data_pipeline_user" {
  project      = var.project_name
  account_id   = "data-pipeline-user"
  display_name = "Data Pipeline User"
}

resource "google_project_iam_member" "data_pipeline_user_storage_object_admin" {
  project = var.project_name
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.data_pipeline_user.email}"
}

resource "google_project_iam_member" "data_pipeline_user_bigquery_job_user" {
  project = var.project_name
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.data_pipeline_user.email}"
}

resource "google_project_iam_member" "data_pipeline_user_bigquery_data_owner" {
  project = var.project_name
  role    = "roles/bigquery.dataOwner"
  member  = "serviceAccount:${google_service_account.data_pipeline_user.email}"
}

resource "google_project_iam_member" "data_pipeline_user_cloud_functions_invoker" {
  project = var.project_name
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.data_pipeline_user.email}"
}

resource "google_project_iam_member" "data_pipeline_user_cloud_run_invoker" {
  project = var.project_name
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.data_pipeline_user.email}"
}

resource "google_project_iam_member" "data_pipeline_user_run_developer" {
  project = var.project_name
  # Might be necessary for deploying Cloud Run services.
  role   = "roles/run.developer"
  member = "serviceAccount:${google_service_account.data_pipeline_user.email}"
}

resource "google_project_iam_member" "data_pipeline_user_workflows_invoker" {
  project = var.project_name
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.data_pipeline_user.email}"
}

# Custom Role:
# All students should be granted a `Team Member` role that is a combination of
# the permissions from the Project IAM Admin role and any other roles we want.

resource "google_project_iam_custom_role" "team_member" {
  project     = var.project_name
  role_id     = "teamMember"
  title       = "Team Member"
  description = "Combination of Project IAM Admin and any other roles"
  permissions = setsubtract(
    setunion(
      split("\n", file("${path.module}/../permissions/project_iam_admin.txt")),
      split("\n", file("${path.module}/../permissions/storage_object_user.txt")),
      split("\n", file("${path.module}/../permissions/service_account_user.txt")),
      split("\n", file("${path.module}/../permissions/service_account_token_creator.txt")),
      split("\n", file("${path.module}/../permissions/bq_data_owner.txt")),
      split("\n", file("${path.module}/../permissions/run_admin.txt")),
    ),
    ["", "resourcemanager.projects.list"]
  )
}
