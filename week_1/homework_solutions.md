# Michael Fortune Homework Solutions Week 1
## Question 1

```
docker run -it --entrypoint=bash python:3.12.8
pip --version
```
**answer:** 24.3.1

## Question 2

**answer:** postgres:5432

## Ingest green taxi data

- First deleted yellow_taxi_trips. Zones table already loaded
- Next updated ingestion script for green_taxi_trips 
- Ran the below cdocker commands

```
docker build -t taxi_ingest:v003_green_taxi_data .
docker run -it \
    --network=docker_sql_default \
    taxi_ingest:v003_green_taxi_data \
        --user=root \
        --password=root \
        --host=pg-database \
        --port=5432 \
        --db=ny_taxi \
        --table_name=green_taxi_trips \
        --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz"
```

## Question 3

- First view the table schema in pgAdmin. In the left tree:
    - Expand Servers → Databases → (your DB) → Schemas → public → Tables.
    - Right-click your table → Properties → Columns tab

- Find the date column. We'll use the drop_off one (lpep_dropoff_datetime)
- Define query to SELECT dates. Format is YYYY-MM-DD

```
SELECT
    CAST(lpep_dropoff_datetime AS DATE) AS day,
    *
FROM green_taxi_trips t
WHERE 
    (CAST(lpep_dropoff_datetime AS DATE) >= DATE '2019-10-01'
    AND CAST(lpep_dropoff_datetime AS DATE) < DATE '2019-11-01')
    ;
```
- Aggregate the data based on trip length with a final AND statement on the trip_distance column

**answer:** 104,802;  198,924;  109,603;  27,678;  35,189

## Question 4

```
SELECT
    CAST(lpep_pickup_datetime AS DATE) AS day,
    MAX(trip_distance) AS max_trip_distance
FROM green_taxi_trips
GROUP BY
    CAST(lpep_pickup_datetime AS DATE)
ORDER BY
    max_trip_distance DESC;
```

**answer:** 2019-10-31

## Question 5

```
SELECT 
	CAST(lpep_pickup_datetime AS DATE) as "date",
	"PULocationID",
	zpu."Zone" as "pickup_loc",
    COUNT (1) as "trips from location",
	SUM(total_amount) AS "sum_total_amount"
FROM
    green_taxi_trips t
JOIN zones zpu
	ON t."PULocationID" = zpu."LocationID"
WHERE
    CAST(lpep_pickup_datetime AS DATE) = DATE '2019-10-18'
GROUP BY
	"PULocationID",
	"pickup_loc",
	CAST(lpep_pickup_datetime AS DATE)
HAVING
    SUM(total_amount) > 13000
ORDER BY
	"trips from location" DESC;
```

**answer:** East Harlem North, East Harlem South, Morningside Heights

## Question 6

```
SELECT
    CAST(lpep_pickup_datetime AS DATE) as "date",
	"PULocationID",
	zpu."Zone" as "pickup_loc",
	"DOLocationID",
	zdo."Zone" as "dropoff_loc",
	"tip_amount"
FROM 
    green_taxi_trips t
JOIN zones zpu
	ON t."PULocationID" = zpu."LocationID"
JOIN zones zdo
	ON t."DOLocationID" = zdo."LocationID"
WHERE
    (CAST(lpep_pickup_datetime AS DATE) > DATE '2019-09-30'
    AND CAST(lpep_pickup_datetime AS DATE) < DATE '2019-11-01')
    AND zpu."Zone" = 'East Harlem North'
ORDER BY
	tip_amount DESC
LIMIT 1;
```

**answer**: JFK Airport

## Question 7

**answer:** `terraform init, terraform apply -auto-approve, terraform destroy`
