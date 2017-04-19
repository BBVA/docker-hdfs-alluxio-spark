#!/bin/bash

source ../conf/hadoop.sh
source ../conf/spark.sh

set -e
# defaults
net=${NET:-"hasz"}
nodes=${NODES:-2}
volume=${VOLUME:-"/tmp/data"}
CONF_FILES="${SPARK_CONF_FILES[@]}"
CONF_VARS="${SPARK_CONF_VARS[@]}"

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
									-e CONF_FILES="${CONF_FILES}" \
									-e CONF_VARS="${CONF_VARS}" \
									-e CORE_SITE_CONF \
									-e HDFS_SITE_CONF \
									-e SPARK_CONF \
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
							-e CONF_FILES="${CONF_FILES}" \
							-e CONF_VARS="${CONF_VARS}" \
							-e CORE_SITE_CONF \
							-e HDFS_SITE_CONF \
							-e SPARK_CONF \
							-e HADOOP_CONF_DIR \
							-e SPARK_MASTER_WEBUI_PORT \
							-e SPARK_WORKER_MEMORY \
							-e SPARK_WORKER_PORT \
							-e SPARK_WORKER_WEBUI_PORT \
							-e SPARK_DAEMON_MEMORY \
							spark slave start spark-master)
done
