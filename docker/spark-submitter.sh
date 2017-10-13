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

JAR_FILE=${1}
MAIN_CLASS=${2}
SPARK_MASTER=${3}
INPUT_FILE=${4}
OUTPUT_FILE=${5}

ENTRY_COMMAND="/opt/spark/bin/spark-submit --class ${MAIN_CLASS} --driver-memory 1g --executor-memory 1g --total-executor-cores 2 --executor-cores 1 --conf spark.memory.storageFraction=0.1 --conf spark.memory.fraction=0.9 --master ${SPARK_MASTER} /opt/app.jar --input ${INPUT_FILE} --output ${OUTPUT_FILE}"
#echo $ENTRY_COMMAND
docker run -ti --rm -v $(readlink -f ${JAR_FILE}):/opt/app.jar --network=hasz --entrypoint bash spark ${ENTRY_COMMAND}
