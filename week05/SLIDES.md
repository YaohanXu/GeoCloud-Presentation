---
marp: true
style: |
  .columns-2 {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
---

<!-- We're going to move PostgreSQL aside for a while -- we're not saying goodbye, we're just moving it out of the center of our view so that we can make room for the universe of other things we're going to be talking about. 

This week we're going to talk about using programming tools to move data into a particular kind of database called a data warehouse, but before we get there I want to talk about the cloud, and set up our motivation. -->

# Into the Cloud 😶‍🌫️

---

## Agenda

<!-- After spring break we're going to be splitting up into three teams. Each team is going to build their own version of a computer assisted mass appraisal system for the City of Philadelphia.

https://docs.google.com/drawings/d/1_4iotvP8y2ajsU5e-NEkZDGfF1Y7uoE7FY_d3HU1ldE/edit

This system will be useful for both city staff that work within the Office of Property Assessment, and also for residential property owners in Philadelphia. There will be different interfaces useful for the two stakeholder groups, but the interfaces will be based on the same data.

For this, we're going to set up a data warehouse, into which we will place property assessment and related information. The data will be updated on a regular and frequent basis, and we will organize the data so that we can build machine learning models and user interfaces on top of it. All of this will be done automatically on a certain schedule, in the cloud, and without human intervention.
-->

1. Intro to Cloud Services (and GCP specifically)
2. Intro to Data Warehouses (and BigQuery specifically)
3. Intro to Business Intelligence Platforms (and Carto specifically)
3. A Data-visualization-in-the-cloud Exercise

---

## Intro to Cloud Services
<!--
We'll talk more about the project in a couple of weeks, but for now, let's talk about what the cloud is.
-->
https://docs.google.com/presentation/d/1WcuSZ3BJz5wPfrbS9qNCJ20Axr6m0PIKLFMu-ljfdoI/edit?usp=sharing

---

## Let's try out BigQuery!

<!-- We're going to load a dataset into BigQuery and then do some light visualization with it.

There are about 5-bajillion-and-one ways to load data into a data warehouse. In a production environment, many companies will rely on systems such as Stitch or FiveTran for extracting data from sources and loading it into data warehouses or data lakes. These platforms are incredibly useful, and it's definitely a best-practice to use them for basic extraction and loading. However, we're going to use a bit more of a low-level approach in this class (1) to get an understanding of what Stitch and FiveTran are doing for us, and (2) because these ETL platforms have their limits, and there are many cases where data engineers have to write their own custom ingestion logic when a ready-made connector doesn't already exist.

To load our data into BigQuery we're going to use something called "external tables" (the afore-mentioned ETL platforms often use this same method). External tables allow us to upload data to Google Cloud Storage and query it from there as if it were a native table in BigQuery. In other words, loading data into BigQuery could often be as easy as uploading a CSV file to a Google Cloud Storage folder.

https://cloud.google.com/bigquery/docs/batch-loading-data

CSV isn't the only format that's supported for external tables; for example, we're going to use a format called Newline Delimited JSON, or "JSON-L". There's also formats like GeoParquet, among others. You can see all the formats in the BigQuery documentation on batch loading data. -->

---

### 1. Download the OPA Properties dataset

Download the Office of Property Assessment's (OPA) property data from [OpenDataPhilly](https://opendataphilly.org/datasets/philadelphia-properties-and-assessment-history/) in GeoJSON format.

<!-- Download the OPA property data from opendataphilly in GeoJSON format. Note that often it doesn't matter too much which initial format you extract data in a data pipeline as an initial step to transform data from one format to something more compatible with the system you're loading into is pretty common. This is one thing that people will often use ogr2ogr for; it's not _just_ for loading data into PostGIS -- it's a tool to convert data from one geospatial format into any other. We've just been using it so far to translate data from GeoJSON or Shapefile format into PostGIS format. We could just as easily go from, for example, Shapefile to CSV.

We could also, download the CSV directly from OpenDataPhilly, but in this case that's not going to get us what we want because the coordinates of the data is in EPSG:2272. Also, I'm going to make a point or two using the GeoJSON.

For the sake of a little bit of exploration, I'll download three formats: the CSV, the GeoJSON, and the GeoPackage. All three of these contain the same data, just encoded in different formats. -->

---

### 2. Convert the OPA Properties dataset to CSV

<!-- In the Data Pipelines Pocket Reference you're going to read about different patterns used in data pipelines. People often talk about "ETL" and "ELT", but Densmore (the author) also refers to "EtLT", which is a pattern we're going to employ often.

We can use a small script to load the raw data that we downloaded and transform it into a format that's more suitable for BigQuery. -->

<div class="columns-2">
<div>

![Python h:32](images/Python_icon.png)

```python
import json

# Load the data from the GeoJSON file
with open('opa_properties.geojson') as f:
    data = json.load(f)

# Write the data to a JSONL file
with open('opa_properties.jsonl', 'w') as f:
    for feature in data['features']:
        row = feature['properties']
        row['geog'] = json.dumps(feature['geometry'])
        f.write(json.dumps(row) + '\n')
```

</div>
<div>

![Node.js h:32](images/Node.js_icon.png)

```javascript
import fs from 'node:fs';

// Load the data from the GeoJSON file
const data = JSON.parse(
  fs.readFileSync('opa_properties.geojson'));

// Write the data to a JSONL file
const f = fs.createWriteStream('opa_properties.jsonl');
for (const feature of data.features) {
  const row = feature.properties;
  row.geog = JSON.stringify(feature.geometry);
  f.write(JSON.stringify(row) + '\n');
}
```

</div>
</div>

_Copy the code above into a file called `opa_properties.py` or `opa_properties.js` and run it._

<div class="columns-2">
<div>

```bash
python3 opa_properties.py
```

</div>
<div>

```bash
node opa_properties.js
```

</div>
</div>

---

### 3. Upload the resulting JSONL file to Google Cloud Storage

- Log in to the **Google Cloud Console** (https://console.cloud.google.com)
- Find the **Google Cloud Storage** service
- Create a new bucket in Google Cloud Storage (maybe call it `data_lake`)
- Create a new folder in the bucket (maybe call it `phl_opa_properties`)
- Upload the JSONL file to the folder

---

### 4. Create a new dataset in BigQuery

- Navigare to the **BigQuery** service
- Create a new dataset in BigQuery (maybe call it `data_lake`)
- Also create a new dataset in Carto (maybe call it `phl`; we'll use this later)

---

### 5. Create the external table

```sql
CREATE OR REPLACE EXTERNAL TABLE `data_lake.phl_opa_properties` (
  `opa_account_num` STRING,
  `owner_name` STRING,
  `mailing_address` STRING,
  `mailing_city` STRING,
  ...
)
OPTIONS (
  description = 'Philadelphia OPA Properties - Raw Data',
  uris = ['gs://data_lake/phl_opa_properties/*.jsonl'],
  format = 'JSON',
  max_bad_records = 0
)
```

---

### 6. Create a native table from the external table

```sql
CREATE OR REPLACE TABLE `phl.opa_properties`
CLUSTER BY (geog)
AS (
  SELECT *
  FROM `data_lake.phl_opa_properties`
)
```

---

## Let's try out Carto!
