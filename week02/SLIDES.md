---
marp: true
style: |
  .focus p {
    text-align: center;
    font-size: 1.5em;
    text-decoration: underline;
  }
  .columns-2 {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 1rem;
  }
---

# Spatial Databases & Querying Geospatial Data

---

## Agenda

- Overview of databases
  - All different types of DBs
  - Focus on "relational databases"
  - **PostgreSQL** and **PostGIS**
- Loading data into PostgreSQL and PostGIS
  - **`ogr2ogr`** and **QGIS**
- Querying data

---

# Introduction to Databases
Let's talk about them. https://docs.google.com/presentation/d/1v-nMrK1-xhoOSA4Euq3B5xq6pSm0uv-D_485J4d_yZo/edit?usp=sharing

---

# Loading data into PostGIS

... can be a chore.

<!-- Now that we have a notion of what we're working with when we're working with a database, and a little bit about the types of data we might store, I want to talk about querying data with SQL. But before doing that we need some data to query, so we're going to talk about loading data into a database first, so that you can follow along. -->

<!-- You would think it would be pretty painless, as the main reason for PostgreSQL and PostGIS to exist is to operate on stored data. However, loading data (geospatial or otherwise) can be a fairly technical and manual endeavor. -->

---

## Tabular data (in CSV format) -- the careful way

1.  Inspect the header and first few rows of the CSV file
2.  Write `CREATE TABLE` SQL statement
3.  Write `COPY` SQL statement

<!-- When you're thinking about loading data into PostgreSQL, the tools or libraries that you use are generally going to be different depending on where your data falls among two broad types: (1) tabular data or (2) geospatial data. When I say tabular data I'm usually referring to data in CSV files, but some of these tools (especially if you're talking about R or Pandas in Python) will also work with things like excel files, parquet files, or dataframes without geospatial information. -->

<!-- So how do we load tabular data? There are a few ways. The first way is using a `COPY` SQL statement. Generally speaking, this entails three steps:
1. inspecting the data attributes,
2. creating the table in your database (e.g. with a `CREATE TABLE` SQL statement), and
3. transfering the data into the table using a `COPY` command. 

Let's try it out. -->

---

### 1. Inspect the header and first few rows

https://www.rideindego.com/wp-content/uploads/2024/10/indego-stations-2024-10-01.csv  

Sometimes you may notice that some preliminary cleaning or correction must be done (as is the case with the above file).

<!-- 

Let's try this using some data from the Indego bike share system. I've linked to a CSV file here. If you're following along in the slides, go ahead and download this file now.

When we open up this CSV file and inspect it (and you can do that with Excel or Google Sheets or Pandas, or just in VS Code -- I use an extension called Rainbow CSV to color-code the columns of CSV files) ... when I inspect it, I can see that this file has a few columns, and then a bunch of blank columns, on of which has a single value down below. I just want to use the first four columns of this file. There are a number of ways that you can deal with a file like this; I used a package called csvkit. 

-->

---

### 2. `CREATE TABLE`

```sql
CREATE TABLE IF NOT EXISTS indego_stations
(
  station_id   INTEGER,
  station_name TEXT,
  go_live_date TEXT
);
```

<!--

You can create tables in your database using a GUI tool such as PG Admin, or you can create table with SQL DDL code. I generally prefer the latter, so that I can save the table definition in a file somewhere, in case I need to delete it and recreate it.

Quick overview of this statement: it starts with CREATE TABLE, and I usually follow it by IF NOT EXISTS, especially if I include it in some sort of database initialization script, so that I can run that script as many times as I want without running into an error. Without the IF NOT EXISTS, I would get an error if I try to create the table and it already exists in the database. With IF NOT EXISTS, the database will do nothing if the table already exists. If you explicitly want to replace the table, you would DROP the table first

DROP TABLE IF EXISTS indego_stations;

Before issuing the CREATE TABLE statement. Notice that each of my SQL statements ends in a semi-colon.

After the CREATE TABLE there are parentheses, and a list of field definitions inside those parentheses. Each field definition is, at a minimum, a field name followed by the data type for the field. If you check the postgres documentation for create table (https://www.postgresql.org/docs/current/sql-createtable.html) you'll find other things you can do in field definition, but this is all we need for now.

You can see that the field names that I'm using don't exactly match what's in the CSV file header. I recommend that field names be in "snake_case" -- i.e. lower-case with underscores (`_`) connecting words. Like we saw before, Postgres is going to try to convert names to lowercase in your queries anyway, so just write them that way. And I recommend you _never_ use spaces in your identifiers.

Also notice that the type I'm choosing to use for the go_live_date column is TEXT instead of DATE. If you're loading from a CSV file, unless you know that the data in your date columnn is in ISO format, or year-month-day format, I recommand creating the table with a TEXT type, and then converting the column type to DATE after you've loaded the data.

## Structure

Just like you have databases that store structured, semi-structured, or unstructured data, data file formats also have varying degrees of structure within them. Most of the data formats that we work with will be semi-structured for various reasons. CSV files fall into this semi-structured category:
- They're not completely unstructured because there's a clear definition of what is a row and what is a field, and where the boundaries between adjacent fields and rows are. Further, every row has the same set of fields within a CSV file -- some of the fields may be empty in a given row, but they're still represented in the data. If a CSV file doesn't conform to these constrainst then it's not a valid CSV file. So that's a fair bit of structure
- On the other hand, CSVs are also not completely structured. The individual values within a CSV file are all untyped. There's no way, within the CSV specification, to enforce that a given column can only contain numeric data, or can only contain dates, etc. Some libraries that read CSV data will attempt to guess each column's type (and perhaps do a pretty good job at it), but with a structured data format you shouldn't have to read a columns values in order to know what data types they'll be.

Conversation topic: Is JSON a structured data format?
  
  My answer is no, but it can be. It's like having a conversation about whether a food vessel with high sides is a cup or a bowl. I don't usually like those conversations in real-world contexts, but I enjoy the conceptual nature of them. But in the real-world, they're mostly pedantic.

  So why bring it up if it's so pedantic? Because I think it's important to remind ourselves to think critically about the technical aspects of technology. Not just the obviously social aspects (like how is AI going to affect us, and should we build it, etc.) -- though those are hugely important too -- but the really technical aspects. It's important to remind ourselves that none of this was handed down on stone tablets from on high. Humans make decisions about these definitions and boundaries. And _that's_ important for conversations that you'll have when advocating for different things with technologists.

  What's a good story to illustrate? Owner names in OPA data? CISO deciding that application isn't secure?

-->

---

### 2. `CREATE TABLE`

<div class="columns-2">
<div>

```sql
CREATE TABLE IF NOT EXISTS indego_stations
(
  id           INTEGER,
  name         TEXT,
  go_live_date DATE,
  status       TEXT
);
```

</div>
<div>

It's almost always a good idea to use `IF NOT EXISTS`, unless you want the command to explicitly fail when the table already exists.

</div>
</div>

---

### 2. `CREATE TABLE`

<div class="columns-2">
<div>

```sql
DROP TABLE IF EXISTS indego_stations;

CREATE TABLE indego_stations
(
  id           INTEGER,
  name         TEXT,
  go_live_date DATE,
  status       TEXT
);
```

</div>
<div>

If you want to _replace_ the table, you would use a `DROP TABLE IF EXISTS` statement first, and then a `CREATE TABLE`.

</div>
</div>

---

### 2. `CREATE TABLE`

<div class="columns-2">
<div>

```sql
DROP TABLE IF EXISTS indego_stations;

CREATE TABLE indego_stations
(
  id           INTEGER,
  name         TEXT,
  go_live_date DATE,
  status       TEXT
);
```

</div>
<div>

Each of the fields on the tablel is specified in the form:

```
  field_name  FIELD_TYPE
```

I recommend that field names be in "snake_case" -- i.e. lower-case with underscores (`_`) connecting words.

</div>
</div>

---

### 2. `CREATE TABLE`

<div class="columns-2">
<div>

```sql
DROP TABLE IF EXISTS indego_stations;

CREATE TABLE indego_stations
(
  id           INTEGER,
  name         TEXT,
  go_live_date DATE,
  status       TEXT
);
```

</div>
<div>

The PostgreSQL documentation on the `CREATE TABLE` statement is [here](https://www.postgresql.org/docs/current/sql-createtable.html).

Even though SQL is standard, each DB's flavor of SQL has its own documentation. E.g., here's the [docs for `CREATE TABLE` for SQLite](https://www.sqlite.org/lang_createtable.html).

Try to get good at reading those statemetn diagrams.

</div>
</div>

---

### 3. `COPY`

```sql
COPY indego_stations
FROM '...path to file goes here...'
WITH (FORMAT csv, HEADER true);
```

<!-- Now we're going to copy the file into the table with a COPY command. The `FROM` value should contain the **full path** to the CSV file you're trying to load. Also, you'll have to make sure that the PostgreSQL user has permission to access the file you're loading. I've seen that be an issue before on Windows installations of Postgres, because the user that you log in as is not the same as the user that Postgres runs as (which, I know, can be confusing and you should remind me to talk about it further in class if you have issues). You should have a folder named "Public" somewhere in your home folder and you might have good luck putting the file in there.

With the copy command you can do things like specify column order, use different CSV delimiters (e.g. if your file is tab-separated instead of comma-separated), and many more options. Refer to the full [`COPY` documentation](https://www.postgresql.org/docs/current/sql-copy.html).

Now if we run this code and take a look in the indego_stations table we see the data. But the go_live_date column is still a text type, so let's update that. We can use an ALTER TABLE command to do so. There are many table alterations that are possible, but right now we're just going to alter one of the tables column types, and we're going to tell Postgres how to alter the type with USING.

ALTER TABLE indego_stations
ALTER COLUMN go_live_date TYPE DATE
  USING to_date(go_live_date, 'MM/DD/YYYY');

This is another thing that you'll be able to dive deeper into in the postgres documentation (https://www.postgresql.org/docs/current/sql-altertable.html) or the sqlite documentation (https://www.sqlite.org/lang_altertable.html) as it's just a standard SQL command.
-->
---

### 3. `COPY`

<div class="columns-2">
<div>

```sql
COPY indego_stations
FROM '...path to file goes here...'
WITH (FORMAT csv, HEADER true);
```

</div>
<div>

The `FROM` value should contain the **full path** to the CSV file you're trying to load.

</div>
</div>

---

### 3. `COPY`

<div class="columns-2">
<div>

```sql
COPY indego_stations
FROM '...path to file goes here...'
WITH (FORMAT csv, HEADER true);
```

</div>
<div>

You can do things like specify column order, use different CSV delimiters (e.g. if your file is a tab-separated instead of comma-separated), and many more options. Refer to the full [`COPY` documentation](https://www.postgresql.org/docs/current/sql-copy.html).

</div>
</div>

---

## Tabular data (in CSV format) -- the GUI way

- You can also load with pgAdmin (but you still have to manually specify the table columns)
  1.  Right-click on a schema and select **Create > Table...**
  2.  Give the table a name -- remember the

<!-- You can load tabular data into tables in a few other ways as well. For example you can use the PGAdmin GUI to create and load data. While this may seem easier, the first time you have to redo a table load you'll see the value of having your creation and load steps writted as code, because then you'll just be able to copy and paste the steps.

You can also use tools in other languages like R, or Python with Pandas to load tables into your database. In fact in the course-info repository you should be able to find a few sample scripts to do just that.
-->

---

## Tabular data -- quick ways

- With a tool like `csvsql` (a part of csvkit)
- With Pandas
- With R

---

### Loading with `csvsql`

- Comes from a _very handy_ library called `csvkit`
- ```bash
  csvsql \
    --db postgresql://postgres:postgres@localhost:5432/musa_509 \
    --tables csvkit_indego_stations \
    --create-if-not-exists \
    --insert \
    --overwrite \
    data/indego_stations.csv
  ```
  (replace the back slashes (`\`) above with back ticks (`` ` ``) if you're in Windows PowerShell)

---

### Loading tabular data with Pandas

```python
import pandas as pd

# Load the CSV into a DataFrame.
df = pd.read_csv('data/indego_stations.csv')

# Load the DataFrame into the database.
USERNAME = 'postgres'
PASSWORD = 'postgres'
DATABASE = 'musa_509'

df.to_sql(
    'indego_stations',
    f'postgresql://{USERNAME}:{PASSWORD}@localhost:5432/{DATABASE}',
    if_exists='replace',
    index=False,
)
```

---

### Loading tabular data with R

```r
library(RPostgreSQL)

# Load the CSV into a DataFrame.
df <- read.csv('data/indego_stations.csv')

# Load the DataFrame into the database.
drv <- dbDriver('PostgreSQL')
con <- dbConnect(drv,
    user = 'postgres', password = 'postgres',
    dbname = 'musa_509', host = 'localhost')

if (dbExistsTable(con, 'r_indego_stations'))
    dbRemoveTable(con, 'r_indego_stations')

dbWriteTable(con,
    name = 'r_indego_stations',
    value = df, row.names = FALSE)
```

---

## Loading spatial data files

- With `ogr2ogr`
- With `shp2pgsql` (or the `shp2pgsql` GUI on Windows only)
- With QGIS
- With Python/R

<!-- 

We already know that we can use ogr2ogr or QGIS to load geospatial data into a database. For the QGIS method, in the week 1 folder in the course-info repository there is a link to a video on "Getting Started with PostGIS in QGIS on macOS" (https://video.osgeo.org/w/pxcBCc4oHhAZvUi9NdWxXf). At about 7 minutes into that video he talks about importing data through QGIS. You may actually want to start at about 4 minutes and 20 seconds though, because he talks about how to connect to a database from QGIS, which you'll need to do first. Even though the video is called "getting started on a mac", all of the QGIS content is exactly the same on Windows (or Linux for that matter).

These aren't the only ways to get data into your database; e.g. you could also use SQL with `CREATE TABLE` and `ST_GeomFromText` or `ST_GeomFromGeoJSON` if you have GeoJSON -->

---

## A quick aside: Frequent acronyms

Acronyms you may see over and over:
- OSGeo
- OGC/OpenGIS
- OGR (as in `ogr2ogr`)
- GDAL
- GEOS
- PROJ (as in `proj.db contains DATABASE.LAYOUT.VERSION.MINOR = 0 whereas a number >= 2 is expected. It comes from another PROJ instillation.`)

---

### **OSGeo** -- _Open Source Geospatial Foundation (https://www.osgeo.org/)_

"a not-for-profit organization whose mission is to foster global adoption of open geospatial technology by being an inclusive software foundation devoted to an open philosophy and participatory community driven development."

<!-- If you're not familiar with what open source is ... there are various philosophical frameworks for OS, but generally it's software where you have access to the source code, and frequently where you can participate in the shaping or writing of that software.  -->

---

<div class="focus">

**OSGeo is a software community.**

</div>

---

### **OGC** -- _Open Geospatial (OpenGIS) Consortium (https://www.ogc.org/)_

"a worldwide community committed to improving access to geospatial, or location information. … Our community creates free, publicly available geospatial standards that enable new technologies."  The difference with OSGeo is that "OGC is the place where many collaborate on creating standards, OSGeo is the place where many collaborate on implementing software" https://wiki.osgeo.org/wiki/The_definition_of_Open_in_OGC,_OSGeo_and_OSM

---

<div class="focus">

**OGC/OpenGIS is a standards community.**

</div>

---

### **OGR** -- Kinda stands for _OpenGIS Reference_, but also not really anymore...and it kinda never did. Now it's just OGR (like KFC)

"OGR used to be a separate vector IO library inspired by [**OpenGIS** Simple Features](https://www.ogc.org/standards/sfa) which was separated from GDAL. With the GDAL 2.0 release, the GDAL and OGR components were integrated together. [You'll often see people refer to **GDAL/OGR**] … OGR used to stand for _**O**pen**G**IS Simple Features **R**eference Implementation_. However, since OGR is not fully compliant with the OpenGIS Simple Feature specification and is not approved as a reference implementation of the spec the name was changed to OGR Simple Features Library. The only meaning of OGR in this name is historical." https://gdal.org/faq.html

---

### **GDAL** -- _Geospatial Data Abstraction Library (https://gdal.org/)_

**An OSGeo project** and a "translator library for raster and vector geospatial data formats"

<!-- GDAL knows how to read data from a number of formats, and write data to a number of formats. So, it's good at translating between data file formats. It does this by using an internal data model that is independent of any particular file format. That's what OGR was for originally, and why it's part of GDAL. -->

---

### **GEOS** -- _Geometry Engine - Open Source (https://libgeos.org/)_

**An OSGeo project** and "a C/C++ library for computational geometry with a focus on algorithms used in geographic information systems (GIS) software. It implements the OGC Simple Features geometry model and provides all the spatial functions in that standard as well as many others."

---

### **PROJ** -- I don't know whether it stands for something or is just short for _projection_ (https://proj.org/)

**An OSGeo project** and "a generic coordinate transformation software [system] that transforms geospatial coordinates from one coordinate reference system (CRS) to another."

<!-- There are a lot of libraries like this where you look at it and say "that seems oddly specific", and they're often built to manage ostensibly mathematical processes that are based around very socially constructed realities. For example there are multiple libraries in Python and JavaScript that just deal with managing time zones on temporal data. -->

---

### Loading data with `ogr2ogr`

Let's use http://www.rideindego.com/stations/json/

We saw something like this last week:

```sh
ogr2ogr \
  -f "PostgreSQL" \
  -nln "indego_station_statuses" \
  -lco "OVERWRITE=yes" \
  PG:"host=localhost port=5432 dbname=musa_509 user=postgres password=postgres" \
  "data/indego_station_statuses.geojson"
```

**Reading from GeoJSON format ⇨ Writing to PostgreSQL tabular format**

<!-- Usually when I'm using something like ogr2ogr that has a complicated command line structure what I'll do is open a blank file and construct my command there. That way if I do something wrong I don't have to edit the command in the terminal (which isn't the best editing interface).

[let the errors come through, like the file path, and the table name]
-->

---

### Loading data with `ogr2ogr`

- "Drivers" determine the types of formats `ogr2ogr` can translate between. A driver just has to know how to convert data from a single format into an OGR model (or vice versa).
- Full documentation at https://gdal.org/programs/ogr2ogr.html (so many options 😵‍💫)
- Each driver may have even more driver-specific options; e.g., [the options for PostGIS](https://gdal.org/drivers/vector/pg.html#dataset-open-options).
- Here are some common commands you might need: https://morphocode.com/using-ogr2ogr-convert-data-formats-geojson-postgis-esri-geodatabase-shapefiles/

<!-- One of the _most useful_ but _least friendly_ command line interfaces. -->

---

### Loading data with QGIS

- Remember that PostgreSQL is just a server running on a computer, and many clients can potentially connect to it. QGIS can act as one of those clients.
- A walkthrough: https://www.crunchydata.com/blog/loading-data-into-postgis-an-overview
  - In our case we have to deselect the JSON field `bikes`, and maybe the array field `coordinates`.

---

### Loading data with GeoPandas

```python
import geopandas as gpd
import sqlalchemy as sqa

# Load the shp into a DataFrame.
df = gpd.read_file('data/indego_station_statuses.geojson')

# Load the DataFrame into the database.
USERNAME = 'postgres'
PASSWORD = 'postgres'
DATABASE = 'musa_509'

engine = sqa.create_engine(
    f'postgresql://{USERNAME}:{PASSWORD}@localhost:5432/{DATABASE}'
)
df.to_postgis(
    'pandas_indego_station_statuses',
    engine,
    if_exists='replace',
    index=False,
)
```

---

### Loading data with R

?

(someone who knows R better than I do, let me know how to do this)

---

# Querying data in a PostGIS database

<!--

OK! Once we have our data loaded into the database, it's pretty smooth sailing, relatively speaking. Now we can get to work querying the data that we've loaded in. If you haven't completed the Codecademy SQL exercises in the  **"Manipulation"** and **"Queries"** sections, just know that I'll be glossing over some concepts that you should have gotten from there. You can watch this portion before doing the exercises, but you may want to revisit it afterwards.

-->

---