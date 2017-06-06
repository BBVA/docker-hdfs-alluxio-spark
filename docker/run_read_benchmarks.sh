#!/bin/bash

JAR_FILE=${1};shift;
READ_TYPE=${1};shift;
NUM_FILES=${1};shift;
FILE_SIZE=${1}

ENTRY_COMMAND="/opt/spark/bin/spark-submit \
--master spark://spark-master:7077 \
--class com.bbva.spark.benchmarks.dfsio.TestDFSIO \
--driver-memory 512m \
--executor-memory 512m \
--total-executor-cores 2 \
--executor-cores 1 \
--packages org.alluxio:alluxio-core-client:1.4.0 \
--conf spark.locality.wait=30s \
--conf spark.driver.extraJavaOptions=-Dalluxio.user.file.readtype.default=$READ_TYPE \
--conf spark.executor.extraJavaOptions=-Dalluxio.user.file.readtype.default=$READ_TYPE \
/opt/app.jar \
read --numFiles $NUM_FILES --fileSize $FILE_SIZE --inputDir  alluxio://alluxio-master:19998/benchmarks/DFSIO"

#echo $ENTRY_COMMAND
docker run -ti --rm -v $(readlink -f ${JAR_FILE}):/opt/app.jar --network=hasz --entrypoint bash spark-submitter ${ENTRY_COMMAND}
