---
title: "Add transform steps to workflow"
labels: []
---

Workflow can be re-deployed with the following command:

```
gcloud workflows deploy data-pipeline \
  --source tasks/data_pipeline.yaml \
  --location us-central1 \
  --service-account data-pipeline-user@musa509s23-team1-philly-cama.iam.gserviceaccount.com
```

Also present in this PR are functions for generating input information for property tiles. They can be deployed with:

```
gcloud functions deploy transform-property-tile-info \
  --source tasks/transform_property_tile_info \
  --entry-point generate_derived_table \
  --env-vars-file=tasks/env.yaml \
  --region us-central1 \
  --runtime python311 \
  --trigger-http \
  --timeout=540s \
  --no-allow-unauthenticated \
  --service-account data-pipeline-user@musa509s23-team1-philly-cama.iam.gserviceaccount.com

gcloud functions deploy export-property-tile-info \
  --source tasks/export_property_tile_info \
  --entry-point export_temp_data \
  --env-vars-file=tasks/env.yaml \
  --region us-central1 \
  --runtime python311 \
  --trigger-http \
  --timeout=540s \
  --no-allow-unauthenticated \
  --service-account data-pipeline-user@musa509s23-team1-philly-cama.iam.gserviceaccount.com
```