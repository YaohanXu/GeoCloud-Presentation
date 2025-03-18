To follow along with the sample code in the slides, run the following:

```sql
CREATE DATABASE week02;
```

Then, connect to that database, and run:

```sql
CREATE EXTENSION postgis;
```

## Case insensitivity of keywords

```sql
CREATE TABLE "MyCheeseTable" (
  cheese_name TEXT,
  cheese_odor TEXT
);

INSERT INTO "MyCheeseTable"
VALUES ('havarti', 'buttery, and maybe sharp');
```

On screen:
```sql
select cheese_odor
from "MyCheeseTable"
where cheese_name = 'havarti';
```

Toggle the keywords between upper and lowercase to show they're the same.

## Case insesnsitivity of identifiers (kinda, but not)

```sql
SELECT cheese_odor
FROM MyCheeseTable
WHERE cheese_name = 'havarti';
```

Run that to show that it fails because the name gets converted to lowercase.

```sql
SELECT cheese_odor
FROM "MyCheeseTable"
WHERE cheese_name = 'havarti';
```

Run that to show that it passes.

To clean up, run:

```sql
DROP TABLE "MyCheeseTable";
```

## Loading data

The following will load tabular data from a CSV with code:

```sql
DROP TABLE IF EXISTS indego_stations;
CREATE TABLE indego_stations
(
  station_id   INTEGER,
  station_name TEXT,
  go_live_date TEXT
);

COPY indego_stations
FROM '...path to file goes here...'
WITH (FORMAT csv, HEADER true);

/home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week02/indego-stations-2024-10-01-clean.csv

ALTER TABLE indego_stations
ALTER COLUMN go_live_date TYPE DATE
  USING to_date(go_live_date, 'MM/DD/YYYY');
```

## Loading geospatial data with ogr2ogr

```bash
ogr2ogr \
  -f "PostgreSQL" \
  -nln "indego_station_statuses" \
  -lco "OVERWRITE=yes" \
  PG:"host=localhost port=5434 dbname=week2 user=postgres password=postgres" \
  "data/indego_station_statuses.geojson"
```