# Explore Philadelphia Data

## JavaScript

### Extract scripts
```
$ time node extract_phl_li_permits.mjs
Downloaded /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/raw_data/phl_li_permits.gpkg

real    0m59.217s
user    0m5.312s
sys     0m2.859s

$ time node extract_phl_opa_properties.mjs
Downloaded /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/raw_data/phl_opa_properties.csv

real    0m33.633s
user    0m6.831s
sys     0m3.052s

$ time node extract_phl_pwd_parcels.mjs
Downloaded /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/raw_data/phl_pwd_parcels.geojson

real    0m20.797s
user    0m10.061s
sys     0m3.414s

$ time node extract_septa_gtfs.mjs
Received 200 response...
Content-Length: 18710867
Extracted into /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/raw_data/septa_bus...
Extracted into /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/raw_data/septa_rail...

real    0m4.979s
user    0m1.645s
sys     0m0.532s
```

### Prepare scripts
```
$ time node prepare_phl_li_permits.mjs
Processed data into /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/prepared_data/phl_li_permits.jsonl

real    0m52.649s
user    0m47.067s
sys     0m7.816s

$ time node --max-old-space-size=4096 prepare_phl_opa_properties.mjs
Processed data into /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/prepared_data/phl_opa_properties.jsonl

real    2m21.131s
user    2m7.493s
sys     0m14.001s

$ time node prepare_phl_pwd_parcels.mjs
Processed data into /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/prepared_data/phl_pwd_parcels.jsonl

real    1m14.397s
user    1m17.107s
sys     0m10.507s

$ time node prepare_septa_gtfs.mjs

real    0m23.978s
user    0m30.715s
sys     0m1.900s
```

## Python

### Extract scripts
```
$ time python extract_phl_li_permits.py 
Downloaded /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/raw_data/phl_li_permits.gpkg

real    0m55.815s
user    0m2.039s
sys     0m2.429s

$ time python extract_phl_opa_properties.py
Downloaded /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/raw_data/phl_opa_properties.csv

real    0m30.920s
user    0m3.937s
sys     0m2.809s

$ time python extract_phl_pwd_parcels.py
Downloaded /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/raw_data/phl_pwd_parcels.geojson

real    0m14.168s
user    0m4.163s
sys     0m1.882s

$ time python extract_septa_gtfs.py
Received 200 response...
Content-Length: 18710867
Extracted into /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/raw_data/septa_bus...
Extracted into /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/raw_data/septa_rail...

real    0m1.892s
user    0m0.852s
sys     0m0.308s
```

### Prepare scripts
```
$ time python prepare_phl_li_permits.py
Processed data into /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/prepared_data/phl_li_permits.jsonl

real    1m54.187s
user    1m45.093s
sys     0m3.426s

$ time python prepare_phl_opa_properties.py
Processed data into /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/prepared_data/phl_opa_properties.jsonl

real    1m1.262s
user    0m50.385s
sys     0m4.612s

$ time python prepare_phl_pwd_parcels.py
Processed data into /home/mjumbewu/Code/musa/musa-509/spring-2024/course-info/week06/explore_phila_data/prepared_data/phl_pwd_parcels.jsonl

real    0m35.832s
user    0m32.418s
sys     0m2.403s

$ time python prepare_septa_gtfs.py

real    0m11.425s
user    0m8.667s
sys     0m0.813s
```