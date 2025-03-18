---
title: "Create a pipeline to ingest the PWD Parcels into a BigQuery table"
labels: ["Scripting"]
---

Refer to issue #1 for detail.

**Acceptance Criteria:**
- [ ] A Cloud Function named `extract-pwd-parcels` to fetch the PWD Parcels dataset and upload into a Cloud Storage bucket named `musa5090s25-team<N>-raw_data` into a folder named `pwd_parcels/`
- [ ] A Cloud Function named `prepare-pwd-parcels` to prepare the file in `gs://musa5090s25-team<N>-raw_data/pwd_parcels/` for backing an external table. The new file should be stored in JSON-L format in a bucket named `musa5090s25-team<N>-prepared_data` and a file named `pwd_parcels/data.jsonl`. All field names should be lowercased.
- [ ] A Cloud Function named `load-pwd-parcels` that creates or updates an external table named `source.pwd_parcels` with the fields in `gs://musa5090s25-team<N>-prepared_data/pwd_parcels/data.jsonl`, and creates or updates an internal table named `core.pwd_parcels` that contains all the fields from `source.pwd_parcels` in addition to a new field named `property_id` set equal to the value of `parcel_number`.
- [ ] A [parallel branch](https://cloud.google.com/workflows/docs/reference/syntax/parallel-steps) added to the Workflow named `data-pipeline` to run each function in step.