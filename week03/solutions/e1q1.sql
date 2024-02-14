with neighborhoods_w_area as (
    select
        name,
        st_area(geog) / 1000000 as area_sqkm,
        geog
    from phl.neighborhoods
)

select
    ngb.name,
    ngb.geog,
    count(sta.id) / ngb.area_sqkm as density_sqkm
from neighborhoods_w_area as ngb
left join indego.stations_geo as sta
    on st_covers(ngb.geog, sta.geog)
group by ngb.name, ngb.geog, ngb.area_sqkm
order by density_sqkm desc;