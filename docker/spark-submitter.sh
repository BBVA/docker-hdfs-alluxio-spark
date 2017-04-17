#!/bin/bash

JAR_FILE=${1}
MAIN_CLASS=${2}
SPARK_MASTER=${3}
INPUT_FILE=${4}
OUTPUT_FILE=${5}

ENTRY_COMMAND="/opt/spark/bin/spark-submit --class ${MAIN_CLASS} --master ${SPARK_MASTER} /opt/app.jar --spark ${SPARK_MASTER} --input ${INPUT_FILE} --output ${OUTPUT_FILE}"
docker run -ti --rm -v $(readlink -f ${JAR_FILE}):/opt/app.jar --network=hasz --entrypoint bash spark ${ENTRY_COMMAND}
