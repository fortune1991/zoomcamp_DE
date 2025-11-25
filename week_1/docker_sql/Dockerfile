FROM python:3.9

RUN apt-get install wget
RUN pip install pandas sqlalchemy psycopg2

WORKDIR /app
COPY upload_data_v003.py upload_data_v003.py

ENTRYPOINT [ "python", "upload_data_v003.py" ]