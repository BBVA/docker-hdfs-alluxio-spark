#!/bin/bash

DATA_FOLDER=${1:-./data}
OUTPUT_FILE=${2:-out.csv}

echo "Concatenating files in ${DATA_FOLDER}"

for file in $(ls ${DATA_FOLDER}); do
  tail -n +2 ${DATA_FOLDER}/${file} >> ${OUTPUT_FILE};
done
