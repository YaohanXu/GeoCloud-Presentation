---
title: "Create a pipeline to extract and load the OPA Properties dataset into BigQuery"
labels: ["Scripting"]
---

All ingest processes in this project will follow this general pattern:
1.  Fetch data and store in a folder in the `musa5090s25-team<N>-raw_data` bucket
2.  Convert data to a BigQuery-friendly external table format (e.g. JSON-L or Parquet) and store in a folder in the `musa5090s25-team<N>-prepared_data` bucket
3.  Create (or replace) a BigQuery external table in the `source` dataset based on the data in `gs://musa5090s25-team<N>-prepared_data`
4.  Create (or replace) a regular BigQuery table in the `core` dataset that has at least one additional column added named `property_id` to act as a unique key (**NOTE: in the OPA properties dataset, the `parcel_number` should be a unique value). E.g.:
    ```sql
    CREATE OR REPLACE core.opa_properties
    AS (
        SELECT
            parcel_number AS property_id,
            *
        FROM source.opa_properties
    )
    ```

Your SQL commands should each be stored in their own files (e.g. `source_phl_opa_properties.sql` and `core_phl_opa_properties.sql`), but should be run from a Cloud Function as part of your pipeline. For an example, see the `run_sql` Cloud Function code at https://github.com/Weitzman-MUSA-GeoCloud/course-info/tree/main/week08/explore_phila_data/run_sql

**Acceptance Criteria:**
- [ ] A Cloud Function named `extract-opa-properties` to fetch the OPA Properties dataset and upload into a Cloud Storage bucket named `musa5090s25-team<N>-raw_data` into a folder named `opa_properties/`
- [ ] A Cloud Function named `prepare-opa-properties` to prepare the file in `gs://musa5090s25-team<N>-raw_data/opa_properties/` for backing an external table. The new file should be stored in JSON-L or Parquet format in a bucket named `musa5090s25-team<N>-prepared_data` and a file named `opa_properties/data.jsonl` or `opa_properties/data.parquet`. All field names should be lowercased.
- [ ] A Cloud Function named `load-opa-properties` that creates or updates an external table named `source.opa_properties` with the fields in `gs://musa5090s25-team<N>-prepared_data/opa_properties/data.*`, and creates or updates an internal table named `core.opa_properties` that contains all the fields from `source.opa_properties` in addition to a new field named `property_id` set equal to the value of `parcel_number`.
- [ ] A Workflow named `data-pipeline` to run each function in step.