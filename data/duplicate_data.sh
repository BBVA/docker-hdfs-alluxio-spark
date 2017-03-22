#!/bin/bash

INPUT_FILE=${1:-out.csv}
OUTPUT_FILE=${2:-out_dup.csv}
SIZE_IN_BYTES=${3:-50000000000}

echo "Duplicating ${INPUT_FILE} to fill ${SIZE_IN_BYTES} bytes"

if [ ! -f ${OUTPUT_FILE} ]; then
  touch ${OUTPUT_FILE};
fi

while [ "$(stat -c%s ${OUTPUT_FILE})" -le "${SIZE_IN_BYTES}" ]; do
  cat ${INPUT_FILE} >> ${OUTPUT_FILE};
done

echo "Done"
