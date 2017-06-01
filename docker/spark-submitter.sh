#!/bin/bash

JAR_FILE=${1}
MAIN_CLASS=${2}
SPARK_MASTER=${3}
INPUT_FILE=${4}
OUTPUT_FILE=${5}

ENTRY_COMMAND="/opt/spark/bin/spark-submit --class ${MAIN_CLASS} --driver-memory 1g --executor-memory 1g --total-executor-cores 2 --executor-cores 1 --conf spark.memory.storageFraction=0.1 --conf spark.memory.fraction=0.9 --master ${SPARK_MASTER} /opt/app.jar --input ${INPUT_FILE} --output ${OUTPUT_FILE}"
#echo $ENTRY_COMMAND
docker run -ti --rm -v $(readlink -f ${JAR_FILE}):/opt/app.jar --network=hasz --entrypoint bash spark ${ENTRY_COMMAND}
