tofu import 'module.team_project["musa5090s25-team5"].google_storage_bucket.raw_data' \
    musa5090s25-team5/musa5090s25-team5-raw_data
tofu import 'module.team_project["musa5090s25-team5"].google_storage_bucket.prepared_data' \
    musa5090s25-team5/musa5090s25-team5-prepared_data
tofu import 'module.team_project["musa5090s25-team5"].google_storage_bucket.temp_data' \
    musa5090s25-team5/musa5090s25-team5-temp_data
tofu import 'module.team_project["musa5090s25-team5"].google_storage_bucket.public' \
    musa5090s25-team5/musa5090s25-team5-public
tofu import 'module.team_project["musa5090s25-team5"].google_storage_bucket_iam_member.public_viewer' \
    "musa5090s25-team5-public roles/storage.objectViewer allUsers"
tofu import 'module.team_project["musa5090s25-team5"].google_bigquery_dataset.source' \
    musa5090s25-team5/source
tofu import 'module.team_project["musa5090s25-team5"].google_bigquery_dataset.core' \
    musa5090s25-team5/core
tofu import 'module.team_project["musa5090s25-team5"].google_bigquery_dataset.derived' \
    musa5090s25-team5/derived
tofu import 'module.team_project["musa5090s25-team5"].google_service_account.data_pipeline_user' \
    "projects/musa5090s25-team5/serviceAccounts/data-pipeline-user@musa5090s25-team5.iam.gserviceaccount.com"
tofu import 'module.team_project["musa5090s25-team5"].google_project_iam_member.data_pipeline_user_storage_object_admin' \
    "musa5090s25-team5 roles/storage.objectAdmin serviceAccount:data-pipeline-user@musa5090s25-team5.iam.gserviceaccount.com"
tofu import 'module.team_project["musa5090s25-team5"].google_project_iam_member.data_pipeline_user_bigquery_job_user' \
    "musa5090s25-team5 roles/bigquery.jobUser serviceAccount:data-pipeline-user@musa5090s25-team5.iam.gserviceaccount.com"
tofu import 'module.team_project["musa5090s25-team5"].google_project_iam_member.data_pipeline_user_bigquery_data_owner' \
    "musa5090s25-team5 roles/bigquery.dataOwner serviceAccount:data-pipeline-user@musa5090s25-team5.iam.gserviceaccount.com"
tofu import 'module.team_project["musa5090s25-team5"].google_project_iam_member.data_pipeline_user_cloud_functions_invoker' \
    "musa5090s25-team5 roles/cloudfunctions.invoker serviceAccount:data-pipeline-user@musa5090s25-team5.iam.gserviceaccount.com"
tofu import 'module.team_project["musa5090s25-team5"].google_project_iam_member.data_pipeline_user_cloud_run_invoker' \
    "musa5090s25-team5 roles/run.invoker serviceAccount:data-pipeline-user@musa5090s25-team5.iam.gserviceaccount.com"
tofu import 'module.team_project["musa5090s25-team5"].google_project_iam_member.data_pipeline_user_run_developer' \
    "musa5090s25-team5 roles/run.developer serviceAccount:data-pipeline-user@musa5090s25-team5.iam.gserviceaccount.com"
tofu import 'module.team_project["musa5090s25-team5"].google_project_iam_member.data_pipeline_user_workflows_invoker' \
    "musa5090s25-team5 roles/workflows.invoker serviceAccount:data-pipeline-user@musa5090s25-team5.iam.gserviceaccount.com"
tofu import 'module.team_project["musa5090s25-team5"].google_project_iam_custom_role.team_member' \
    "musa5090s25-team5/teamMember"

