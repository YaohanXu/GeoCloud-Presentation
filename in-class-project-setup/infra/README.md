# Infrastructure

This directory contains the infrastructure code for the in-class project setup. The infrastructure is defined using [OpenTofu](https://opentofu.org/docs/intro/), a fork of [Terraform](https://www.terraform.io/).

## Initializing for a project

Create the new project, and attach to a billing account: https://console.cloud.google.com/billing/linkedaccount

You will probably have to set the application default credentials:

```bash
export gcpproject=musa5090s25-...
gcloud auth application-default login --project ${gcpproject}
gcloud config set project ${gcpproject}
gcloud storage buckets create gs://${gcpproject}-config
```

Update the _variables.tf_ file, setting the project ID as the `cama_prefix` value.

Afterwards, to initialize the infrastructure (**Note: Be careful running `init` with `-reconfigure` as it will get rid of any existing configuration state data, if there is some**):

```bash
tofu init -reconfigure
```

## Updating roles/team_member permissions

Run the following:

```bash
gcloud iam roles describe roles/resourcemanager.projectIamAdmin --format json | jq -r '.includedPermissions | join("\n")' > permissions/project_iam_admin.txt
```