---
marp: true
style: |
  .columns-2 {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
---

# Creating Jobs and APIs with BigQuery data

---

## Agenda

1.  Working with data from a query

2.  Creating a job in Cloud Run

3.  Creating an API with Cloud Functions

4.  Containerizing an API for Cloud Run

---

## Working with data from a query

- Use the BigQuery client library to run a query (or Pandas GBQ for Python)
- Use the BigQuery client to write new results into a table, or the Cloud Storage client to write to a file

<!--

-  Create a new module in a folder with some keys and a .env file
-  Install the bigquery libraries for Node and Python
-  Select some data from the phl.opa_properties and phl.pwd_parcels tables. Explain that I've already tested the query in the BigQuery console to make sure that I'm getting the data that I want.

SELECT 
  property.parcel_number        AS id,
  LEFT(property.sale_date, 10)  AS last_sale_date,
  property.sale_price           AS last_sale_price,
  ST_ASGEOJSON(parcel.geometry) AS geometry
FROM phl.opa_properties AS property
JOIN phl.pwd_parcels    AS parcel
  ON LPAD(property.parcel_number, 10, '0') = LPAD(CAST(parcel.BRT_ID AS STRING), 10, '0')
WHERE property.zip_code = '19104'

-  Demonstrate how to run the query in Python and Node, and how to write the results to a table or a file.

-->

---

## Creating a job in Cloud Run

---

## Creating an API with Cloud Functions

* Think of inputs and outputs -- just like a function

---

## Containerizing an API for Cloud Run