#!/bin/bash

OUTPUT_FILE=${1:-data.csv}

if [ ! -f "${OUTPUT_FILE}" ]; then
  echo "Downloading data file"
  wget https://data.cityofchicago.org/api/views/ijzp-q8t2/rows.csv?accessType=DOWNLOAD -o tmp
  head -n 1 tmp | sed -e 's/\s/_/g' > ${OUTPUT_FILE}
  tail -n+2 tmp >> ${OUTPUT_FILE}
  rm tmp
else
  echo "Data source already downloaded..."
fi

# mkdir -p /tmp/spark-events; rm -r /data/out_parquet*; rm -rf /tmp/spark-events/*; $SPARK_HOME/bin/spark-submit --master local[1] --class CSVToParquet  --executor-memory 1024G /assembly/sparky-assembly-1.0.jar --spark local[1] --input /data/data.csv --output /data/out_parquet
