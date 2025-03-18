---
title: "Create a pipeline to extract and load the OPA Assessment History dataset into BigQuery"
labels: ["Scripting"]
---

Refer to issue #1 for detail.

**Acceptance Criteria:**
- [ ] A Cloud Function named `extract-opa-assessments` to fetch the PWD Parcels dataset and upload into a Cloud Storage bucket named `musa509s23_team<N>_raw_data` into a folder named `opa_assessments/`
- [ ] A Cloud Function named `prepare-opa-assessments` to prepare the file in `gs://musa509s23_team<N>_raw_data/opa_assessments/` for backing an external table. The new file should be stored in JSON-L format in a bucket named `musa509s23_team<N>_prepared_data` and a file named `opa_assessments/data.jsonl`. All field names should be lowercased.
- [ ] A Cloud Function named `load-opa-assessments` that creates or updates an external table named `source.opa_assessments` with the fields in `gs://musa509s23_team<N>_prepared_data/opa_assessments/data.jsonl`, and creates or updates an internal table named `core.opa_assessments` that contains all the fields from `source.opa_assessments` in addition to a new field named `property_id` set equal to the value of `parcel_number`.
- [ ] A [parallel branch](https://cloud.google.com/workflows/docs/reference/syntax/parallel-steps) added to the Workflow named `data-pipeline` to run each function in step.