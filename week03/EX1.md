(For the exercise #1)

# Bike Share Station Density by Neighborhood

I'm going to demonstrate exercise #1 for this week. Both of the exercises use PostGIS to surface some basic information that could be used when deciding which geographic areas to focus on for new bike share stations.

This first exercise depends on:
* **Bikeshare station location data**, which I've already loaded into the `indego.stations_geo` table, and
* **Neighborhood polygon data** (there is no official source of neighborhood boundaries in Philadelphia, but Azavea (which is now called Element 84) has created [the go-to source](https://github.com/azavea/geo-data/tree/master/Neighborhoods_Philadelphia))

I've already downloaded that file into my local folder, created a new schema named `phl`:

```sql
create schema if not exists phl;
```

and loaded the file into my database with this `ogr2ogr` command:

```bash
ogr2ogr \
    -f "PostgreSQL" \
    -nln "neighborhoods" \
    -lco "SCHEMA=phl" \
    -lco "GEOM_TYPE=geography" \
    -lco "GEOMETRY_NAME=geog" \
    -lco "OVERWRITE=yes" \
    PG:"host=localhost port=5434 dbname=musa509week03 user=postgres password=postgres" \
    "data/phl_neighborhoods.geojson"
```

1.  Write a query that lists which neighborhoods have the highest density of bikeshare stations. Let's say "density" means number of stations per square km.
    * Your query should return results containing:
      * The neighborhood name (in a column named `name`)
      * The neighborhood polygon as a `geography` (in a column named `geog`)
      * The number of bike share stations per square kilometer in the neighborhood (in a column named `density_sqkm`)
    * Your results should be ordered from most dense to least dense.
    * Be sure to include neighborhoods that have zero bike share stations in your results.
    * Note that the neighborhoods dataset has an area field; don't trust that field. Calculate the area using `ST_Area` yourself.

```sql
with neighborhoods_sqm as (
    select 
        name,
        shape_area, 
        st_area(geog) / 1000000 as shape_area_sqkm,
        geog
    from phl.neighborhoods
)

select
    ngh.name,
    count(sta.id) / ngh.shape_area_sqkm as density,
    ngh.geog
from neighborhoods_sqm as ngh
left join indego.stations_geo as sta
    on st_covers(ngh.geog, sta.geog)
group by ngh.name, ngh.geog, ngh.shape_area_sqkm
order by density desc
```

2.  Write a query to get the average bikeshare station density across _all the neighborhoods that have a non-zero bike share station density_.
    * The query should return a single record with a single field named `avg_density_sqkm`
    * Try using a common table expressions (CTE) to write this query.

3.  Write a query that lists which neighborhoods have a density above the average, and which have a density below average.
    * Your query should return results containing:
      * The neighborhood name (in a column named `name`)
      * The neighborhood polygon as a `geography` (in a column named `geog`)
      * The number of bike share stations per square kilometer in the neighborhood (in a column named `density_sqkm`)
      * The status relative to the average density (in a column named `rel_to_avg_density`). If the density is greater than or equal the average, the field should have a value of `'above'`. If the density is less than the average, the field should have a value of `'below'`.
