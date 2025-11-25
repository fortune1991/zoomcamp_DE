import argparse
import os
import pandas as pd
from sqlalchemy import create_engine
from time import time

def main(params):
    user = params.user
    password = params.password
    host = params.host
    port = params.port
    db = params.db
    table_name = params.table_name
    url = params.url

    csv_name = "output.csv"

    # Download the CSV file
    os.system(f"wget {url} -O {csv_name}")
    
    # Create DB connection
    engine = create_engine(f'postgresql://{user}:{password}@{host}:{port}/{db}')
    engine.connect()


    # Create iterator from CSV
    df_iter = pd.read_csv(csv_name, iterator=True, chunksize=100000)

    # Create df from iterator
    df = next(df_iter)

    # Convert dates from strings to pd timestamps
    if "tpep_pickup_datetime" in df.columns and "tpep_dropoff_datetime" in df.columns:
        df.tpep_pickup_datetime = pd.to_datetime(df.tpep_pickup_datetime)
        df.tpep_dropoff_datetime = pd.to_datetime(df.tpep_dropoff_datetime)

    # Use title row to create table
    df.head(n=0).to_sql(name=table_name, con=engine, if_exists='replace')

    # Ingest first chunk of data
    df.to_sql(name=table_name, con=engine, if_exists='append')

    print("ingested first chunk...")

    # Use a loop to ingest rest of data
    while True:
        t_start = time()
        df = next(df_iter)

        if "tpep_pickup_datetime" in df.columns and "tpep_dropoff_datetime" in df.columns:
            df["tpep_pickup_datetime"] = pd.to_datetime(df["tpep_pickup_datetime"])
            df["tpep_dropoff_datetime"] = pd.to_datetime(df["tpep_dropoff_datetime"])

        df.to_sql(name=table_name, con=engine, if_exists='append')

        t_end = time()

        print("inserted another chunk... took %.3f seconds" % (t_end - t_start))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Ingest CSV data to Postgres')

    # user
    parser.add_argument('--user', help='username for postgres')
    # password
    parser.add_argument('--password', help='password for postgres')
    # host
    parser.add_argument('--host', help='host for postgres')
    # port
    parser.add_argument('--port', help='port for postgres')
    # database name
    parser.add_argument('--db', help='database name for postgres')
    # table name
    parser.add_argument('--table_name', help='table name for postgres')
    # url of the csv
    parser.add_argument('--url', help='url of the csv file')

    args = parser.parse_args()

    main(args)


