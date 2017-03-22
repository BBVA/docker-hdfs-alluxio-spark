#!/bin/bash

HEADER_FILE=${1}
OUTPUT_FILE=${2:-out_dup.csv}

echo "Adding headers to ${OUTPUT_FILE}"

HEADER=$(head -n 1 ${HEADER_FILE})

echo "${HEADER}" > tmp.csv
cat ${OUTPUT_FILE} >> tmp.csv

rm ${OUTPUT_FILE}
mv tmp.csv ${OUTPUT_FILE}
