---
marp: true
style: |
  .columns-2 {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
---

<!-- _backgroundColor: dimgray -->
<!-- _color: white -->

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

To load our data into BigQuery we're going to use something called "external tables" (the afore-mentioned ETL platforms often use this same method). External tables allow us to upload data to Google Cloud Storage and query it from there as if it were a native table in BigQuery. In other words, loading data into BigQuery could often be as easy as uploading a CSV file to a Google Cloud Storage folder and querying it like a database table.

https://cloud.google.com/bigquery/docs/batch-loading-data

CSV isn't the only format that's supported for external tables; for example, we're going to use a format called Newline Delimited JSON, or "JSON-L". There's also formats like GeoParquet, among others. You can see all the formats in the BigQuery documentation on batch loading data. -->

---

### 1. Download the OPA Properties dataset

Download the Office of Property Assessment's (OPA) property data from [OpenDataPhilly](https://opendataphilly.org/datasets/philadelphia-properties-and-assessment-history/) in GeoJSON format.

<!-- Download the OPA property data from opendataphilly in GeoJSON format. Note that often it doesn't matter too much which initial format you extract data in a data pipeline as an initial step to transform data from one format to something more compatible with the system you're loading into is pretty common. This is one thing that people will often use ogr2ogr for; it's not _just_ for loading data into PostGIS -- it's a tool to convert data from one geospatial format into any other. We've just been using it so far to translate data from GeoJSON or Shapefile format into PostGIS format. We could just as easily go from, for example, Shapefile to CSV.

We could also, download the CSV directly from OpenDataPhilly, but in this case that's not going to get us what we want because the coordinates of the data is in EPSG:2272. Also, I'm going to make a point or two using the GeoJSON.

For the sake of a little bit of exploration, I'll download two formats: the CSV, and the GeoJSON. Both of these contain the same data, just encoded in different formats. -->

---

### 2. Convert the OPA Properties dataset

_Transform the data into a format that BigQuery accepts for external tables; this would be a little-t in **EtLT**._

<!-- In the Data Pipelines Pocket Reference you're going to read about different patterns used in data pipelines. People often talk about "ETL" and "ELT", but Densmore (the author) also refers to "EtLT", which is a pattern we're going to employ often.

We're going to need to translate the file we downloaded into something that BigQuery can understand. In doing this, we're not altering the meaning of any of the fields, or aggregating to change any units of analysis, or filtering any of thedata out. Those would all be big-T transformations. This is really just modifying how the data in encoded to make it compatible with our system.

There are countless ways we could go about this. For example, as I mentioned before, we could use ogr2ogr to translate it into a CSV with a WKT geography column. Alternatively we could use a simple Python or JavaScript script to do the conversion for us. When we get to Cloud Functions you'll see that using a script turns out to be a pretty convenient option, since we'll eventually want this to be run in a process on a cloud server. -->

<div class="columns-2">
<div>

```sh
ogr2ogr \
  "data/opa_properties_public-4326.csv" \
  "data/opa_properties_public.geojson" \
  -lco GEOMETRY=AS_WKT \
  -lco GEOMETRY_NAME=geog \
  -skipfailures
```

</div>
<div>

Load the GeoJSON file and write a CSV with a new `geog` column containing WKT. Gracefully handle records that have `NULL` geometries (`-skipfailures`).

</div>
</div>

---

### 2. Convert the OPA Properties dataset

<!-- If we were to use a small script to do this, it might look like one of these. These scripts use the GeoJSON download files, since we don't have to worry about reprojecting the coordinates into 4326. Also, instead of generating a new CSV, it generates data in a format called JSON-L, or new-line-delimited JSON. This is another format that BigQuery plays well with. It's a little more verbose than CSV, but can be compressed pretty small.

The code block on the left is Python and on the right is JavaScript, but the two blocks of code do basically the same thing. -->

<div class="columns-2" style="font-size: 0.6em">
<div>

![Python h:32](images/Python_icon.png)

```python
import json


# Load the data from the GeoJSON file
with open('opa_properties_public.geojson', 'r') as f:
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
import BigJSON from 'big-json';

// Load the data from the GeoJSON file
const data = await BigJSON.parse({
  body: fs.readFileSync('opa_properties_public.geojson')
});

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

_Copy the code above into a file called `opa_properties.py` or `opa_properties.mjs` and run it._

<div class="columns-2">
<div>

```bash
python3 opa_properties.py
```

</div>
<div>

```bash
node opa_properties.mjs
```

</div>
</div>

---

### 3. Upload the resulting file to Google Cloud Storage

<!-- Finally we'll need to upload this file to somewhere in Google Cloud Platform. This is also something we will script in the future, but for now we'll do it manually, with the added bonus that it allows us to get familiar with the Google Cloud Console interface. -->

- Log in to the **Google Cloud Console** (https://console.cloud.google.com)
- Find the **Google Cloud Storage** service
- Create a new bucket in Google Cloud Storage (maybe call it `data_lake`)
- Create a new folder in the bucket (maybe call it `phl_opa_properties`)
- Upload the JSONL file to the folder

---

### 4. Create a new dataset in BigQuery

<!-- Now let's get the BigQuery side of things set up. Remember that in BigQuery a "dataset" is essentially equivalent to a "schema" in PostgreSQL. So let's create a new dataset to store our table in. -->

- Navigate to the **BigQuery** service
- Create a new dataset in BigQuery (maybe call it `data_lake`)

---

### 5. Create the external table

<!-- We've uploaded a file to Google Cloud Storage, and now we have to tell BigQuery to let us query that file as a table bu creating a table object in BigQuery that points to the file. The `uris` option is what I use to specify where the file is. The gs lets us know that it's a GCS url. Also notice the asterisk, or wildcard that I'm using. You can actually have BigQuery treat multiple files as one big table. This is really useful, for example, if you have data that you;re adding to the table on a regular basis; all you have to do is upload the new data to storage and old data will still be there. -->

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

<!-- Finally, as an optional last step, I almost always create a native table. -->
```sql
CREATE OR REPLACE TABLE `phl.opa_properties`
CLUSTER BY (geog)
AS (
  SELECT *
  FROM `data_lake.phl_opa_properties`
)
```

---

<!-- In class I'll show how you can take a table that you've created and visualize it using a tool like Carto. -->

## Let's try out Carto!
