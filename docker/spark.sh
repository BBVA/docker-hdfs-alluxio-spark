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

set -e
# defaults
net=${NET:-"hasz"}
nodes=${NODES:-2}
volume=${VOLUME:-"/tmp/data"}

export HADOOP_CONF_DIR=/opt/spark/conf

export SPARK_MASTER_WEBUI_PORT=${SPARK_MASTER_WEBUI_PORT:-8080}
export SPARK_WORKER_MEMORY=${SPARK_WORKER_MEMORY:-1g}
export SPARK_WORKER_PORT=${SPARK_WORKER_PORT:-35000}
export SPARK_WORKER_WEBUI_PORT=${SPARK_WORKER_WEBUI_PORT:-8081}
export SPARK_DAEMON_MEMORY=${SPARK_DAEMON_MEMORY:-1g}


# check network existence and create it if necessary
# we need this network for the automatic service discovery in docker engine
docker network inspect ${net} > /dev/null 2>&1

if [ $? -eq 1 ]; then
	net_id=$(docker network create ${net})
	echo "Created network ${net} with id ${net_id}"
fi

# bring up namenode and show its url
mkdir -p ${volume}/spark-master

spark_master_id=$(docker run --shm-size 2g -d \
		-v ${volume}/spark-master:/data \
		-p 8080:8080 \
		-p 7077:7077 \
		--name spark-master \
		-h spark-master \
		--network=${net}  \
		-e HADOOP_CONF_DIR \
		-e SPARK_MASTER_WEBUI_PORT \
		-e SPARK_WORKER_MEMORY \
		-e SPARK_WORKER_PORT \
		-e SPARK_WORKER_WEBUI_PORT \
		-e SPARK_DAEMON_MEMORY \
		spark master start hdfs-namenode)

sleep 2s

ip=$(docker inspect --format '{{ .NetworkSettings.Networks.'${net}'.IPAddress }}' ${spark_master_id})

echo Master started in:
echo http://$ip:8080

for n in $(seq 1 1 ${nodes}); do
	echo Starting node ${n}
	mkdir -p ${volume}/spark-worker${n}
	datanode_id=$(docker run --shm-size 2g -d \
		-v ${volume}/spark-worker${n}:/data \
		--name spark-worker${n} \
		-h spark-worker${n} \
		--network=${net} \
		-e HADOOP_CONF_DIR \
		-e SPARK_MASTER_WEBUI_PORT \
		-e SPARK_WORKER_MEMORY \
		-e SPARK_WORKER_PORT \
		-e SPARK_WORKER_WEBUI_PORT \
		-e SPARK_DAEMON_MEMORY \
		spark slave start spark-master)
done
