---
title: "Add a Cloud Run task to generate map tiles"
labels: []
---

See Issue #14 for more detail.

To deploy this Run job, use the following commands:

```bash
gcloud builds submit \
  --region us-central1 \
  --tag gcr.io/musa509s23-team1-philly-cama/generate-property-map-tiles

# Note, if the job already exists, you have to change "create" to "update" below.
gcloud beta run jobs create generate-property-map-tiles \
  --image gcr.io/musa509s23-team1-philly-cama/generate-property-map-tiles \
  --service-account data-pipeline-user@musa509s23-team1-philly-cama.iam.gserviceaccount.com \
  --cpu 4 \
  --memory 2Gi \
  --region us-central1