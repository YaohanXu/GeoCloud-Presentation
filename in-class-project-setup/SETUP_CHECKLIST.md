## GitHub

- [ ] Create a new repository for each team. Disable pushing directly to the main branch. Require a review on all pull requests.
- [ ] Add an issue into each repository with the contents of this file.
- [ ] Create a new team for each group. Use the `invite_gh_team_members.mjs` script to invite the group members to the teams.
- [ ] Create a new project for each team.
- [ ] Link the repository to the project.

## Google Cloud

- [ ] Create a new project for each team.
- [ ] Create a new role called "Student Team Member" in each project. Initialize with permissions from "Editor" and "Project IAM Admin".
- [ ] Add a principal for each group member to the "Student Team Member" role in the project. You can do this through the Console GUI, or using the [`gcloud projects add-iam-policy-binding`](https://cloud.google.com/sdk/gcloud/reference/projects/add-iam-policy-binding) command.
- [ ] Create a new service account for each team. Add the "BigQuery Data Editor", "BigQuery Job User", "Cloud Run Invoker", "Storage Object Admin", and "Workflows Invoker" roles to the service account.
- [ ] Create four new buckets for each team: `musa5090s24_team1_raw_data`, `musa5090s24_team1_table_data`, `musa5090s24_team1_public`, and `musa5090s24_team1_temp`.
- [ ] Give the `temp` bucket a lifecycle rule to delete objects after 7 days.
- [ ] Allow cross-origin resource sharing on the `public` bucket.
- [ ] Upload old tiles and chart data for apex charts to the `public` bucket.
- [ ] Create new datasets in BigQuery called `source`, `core` and `derived` for each project.
- [ ] Add tables named `core.opa_properties`, `core.opa_assessments`, and `core.pwd_parcels` to the `core` dataset.