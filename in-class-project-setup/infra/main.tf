locals {
  project_names = toset([
    "musa5090s25-team1",
    "musa5090s25-team2",
    "musa5090s25-team3",
    "musa5090s25-team4",
    "musa5090s25-team5",
    "musa5090s25-team6",
  ])
}

module "team_project" {
  source       = "./project_template"
  for_each     = local.project_names
  project_name = each.key
  location     = "us-east4"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_storage_bucket.raw_data
  id = "${each.key}/musa5090s25-team5-raw_data"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_storage_bucket.prepared_data
  id = "${each.key}/musa5090s25-team5-prepared_data"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_storage_bucket.temp_data
  id = "${each.key}/musa5090s25-team5-temp_data"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_storage_bucket.public
  id = "${each.key}/${each.key}-public"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_storage_bucket_iam_member.public_viewer
  id = "${each.key}-public roles/storage.objectViewer allUsers"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_bigquery_dataset.source
  id = "${each.key}/source"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_bigquery_dataset.core
  id = "${each.key}/core"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_bigquery_dataset.derived
  id = "${each.key}/derived"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_service_account.data_pipeline_user
  id = "projects/${each.key}/serviceAccounts/data-pipeline-user@${each.key}.iam.gserviceaccount.com"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_project_iam_member.data_pipeline_user_storage_object_admin
  id = "${each.key} roles/storage.objectAdmin serviceAccount:data-pipeline-user@${each.key}.iam.gserviceaccount.com"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_project_iam_member.data_pipeline_user_bigquery_job_user
  id = "${each.key} roles/bigquery.jobUser serviceAccount:data-pipeline-user@${each.key}.iam.gserviceaccount.com"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_project_iam_member.data_pipeline_user_bigquery_data_owner
  id = "${each.key} roles/bigquery.dataOwner serviceAccount:data-pipeline-user@${each.key}.iam.gserviceaccount.com"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_project_iam_member.data_pipeline_user_cloud_functions_invoker
  id = "${each.key} roles/cloudfunctions.invoker serviceAccount:data-pipeline-user@${each.key}.iam.gserviceaccount.com"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_project_iam_member.data_pipeline_user_cloud_run_invoker
  id = "${each.key} roles/run.invoker serviceAccount:data-pipeline-user@${each.key}.iam.gserviceaccount.com"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_project_iam_member.data_pipeline_user_run_developer
  id = "${each.key} roles/run.developer serviceAccount:data-pipeline-user@${each.key}.iam.gserviceaccount.com"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_project_iam_member.data_pipeline_user_workflows_invoker
  id = "${each.key} roles/workflows.invoker serviceAccount:data-pipeline-user@${each.key}.iam.gserviceaccount.com"
}

import {
  for_each = local.project_names
  to = module.team_project[each.key].google_project_iam_custom_role.team_member
  id = "${each.key}/teamMember"
}
