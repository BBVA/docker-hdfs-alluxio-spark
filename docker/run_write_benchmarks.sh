#!/bin/bash

# Copyright 2017 Banco Bilbao Vizcaya Argentaria S.A.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

JAR_FILE=${1};shift;
WRITE_TYPE=${1};shift;
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
--conf spark.driver.extraJavaOptions=-Dalluxio.user.file.writetype.default=$WRITE_TYPE \
--conf spark.executor.extraJavaOptions=-Dalluxio.user.file.writetype.default=$WRITE_TYPE \
/opt/app.jar \
write --numFiles $NUM_FILES --fileSize $FILE_SIZE --outputDir  alluxio://alluxio-master:19998/benchmarks/DFSIO"

#echo $ENTRY_COMMAND
docker run -ti --rm -v $(readlink -f ${JAR_FILE}):/opt/app.jar --network=hasz --entrypoint bash spark-submitter ${ENTRY_COMMAND}
