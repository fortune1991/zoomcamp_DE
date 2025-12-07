import dlt
import duckdb
from dlt.sources.helpers.rest_client import RESTClient
from dlt.sources.helpers.rest_client.paginators import PageNumberPaginator

@dlt.resource(name="rides", write_disposition="append")
def ny_taxi(
    cursor_date=dlt.sources.incremental(
        "Trip_Dropoff_DateTime",   # field to track for incremental loading, our timestamp
        )
    ):
    client = RESTClient(
        base_url="https://us-central1-dlthub-analytics.cloudfunctions.net",
        paginator=PageNumberPaginator(
            base_page=1,
            total_path=None
        )
    )

    for page in client.paginate("data_engineering_zoomcamp_api"): # This is the API end point name. It's appended to the base URL above automatically by dlt
        yield page

# define new dlt pipeline
pipeline = dlt.pipeline(pipeline_name="ny_taxi", destination="duckdb", dataset_name="ny_taxi_data")

# run the pipeline with the new resource
load_info = pipeline.run(ny_taxi()) # This is the ny_taxi function
print(load_info)

# explore loaded data
pipeline.dataset().rides.df()

# Correct DuckDB connection
db_path = "/Users/michaelfortune/Developer/projects/zoomcamp_de/dlt_workshop/ny_taxi.duckdb"
conn = duckdb.connect(db_path)

# Set search path to the dataset
dataset = pipeline.dataset_name  # "ny_taxi_data"
conn.sql(f"SET search_path = '{dataset}'")

# Q2
with pipeline.sql_client() as client:
    res = client.execute_sql("""
        SHOW TABLES;
    """)
    print(res)

# Q3
with pipeline.sql_client() as client:
    res = client.execute_sql("""
        SELECT COUNT(*) AS row_count FROM rides;
    """)
    print(res)

# Q4
with pipeline.sql_client() as client:
    res = client.execute_sql("""
        SELECT
        AVG(date_diff('minute', trip_pickup_date_time, trip_dropoff_date_time))
        FROM rides;
    """)
    print(res)