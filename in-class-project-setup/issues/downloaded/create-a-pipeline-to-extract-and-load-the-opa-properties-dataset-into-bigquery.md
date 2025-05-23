---
title: "Create a pipeline to extract and load the OPA Properties dataset into BigQuery"
labels: ["Scripting"]
---

All ETL processes in this project will follow this general pattern:
1.  Fetch data and store in a folder in the `musa509s23_team01_raw_data` bucket
2.  Convert data to JSON-L and store in a folder in the `musa509s23_team01_prepared_data` bucket
3.  Create (or replace) a BigQuery external table in the `source` dataset based on the data in the `musa509s23_team01_prepared_data` bucket
4.  Create (or replace) a regular BigQuery table in the `core` dataset that has at least one additional column added named `property_id`. E.g.:
    ```sql
    CREATE OR REPLACE core.opa_properties
    AS (
        SELECT
            parcel_number AS property_id,
            *
        FROM source.opa_properties
    )
    ```

Your SQL commands should each be stored in their own files (e.g. `create_source_opa_properties.sql` and `create_core_opa_properties.sql`), but should be run from a Cloud Function as part of your pipeline. For an example, see the `load_census` code at https://github.com/musa-509-spring-2023/pipeline01/tree/main/src/load_census

**Acceptance Criteria:**
- [x] A Cloud Function named `extract-opa-properties` to fetch the OPA Properties dataset and upload into a Cloud Storage bucket named `musa509s23_team01_raw_data` into a folder named `opa_properties/`
- [x] A Cloud Function named `prepare-opa-properties` to prepare the file in `gs://musa509s23_team01_raw_data/opa_properties/` for backing an external table. The new file should be stored in JSON-L format in a bucket named `musa509s23_team01_prepared_data` and a file named `opa_properties/data.jsonl`. All field names should be lowercased.
- [x] A Cloud Function named `load-opa-properties` that creates or updates an external table named `source.opa_properties` with the fields in `gs://musa509s23_team01_prepared_data/opa_properties/data.jsonl`, and creates or updates an internal table named `core.opa_properties` that contains all the fields from `source.opa_properties` in addition to a new field named `property_id` set equal to the value of `parcel_number`.
- [x] A Workflow named `data-pipeline` to run each function in step.