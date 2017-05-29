#!/bin/bash

set -e
# defaults
net=${NET:-"hasz"}
nodes=${NODES:-1}
volume=${VOLUME:-"/tmp/data"}

export SPARK_EXECUTOR_MEMORY=${SPARK_EXECUTOR_MEMORY:-1g}
export SPARK_APP_NAME=${SPARK_APP_NAME:-"Zeppelin"}
export SPARK_CORES_MAX=${SPARK_CORES_MAX:-1}

# check network existence and create it if necessary
# we need this network for the automatic service discovery in docker engine
docker network inspect ${net} > /dev/null 2>&1

if [ $? -eq 1 ]; then
	net_id=$(docker network create ${net})
	echo "Created network ${net} with id ${net_id}"
fi

# bring up namenode and show its url
mkdir -p ${volume}/zeppelin
zeppelin_id=$(docker run -d \
		-v ${volume}/zeppelin:/data \
		-p 8081:8080 \
		--name zeppelin \
		-h zeppelin \
		--network=${net} \
		-e SPARK_EXECUTOR_MEMORY \
		-e SPARK_APP_NAME \
		-e SPARK_CORES_MAX \
		zeppelin master start zeppelin)

ip=$(docker inspect --format '{{ .NetworkSettings.Networks.'${net}'.IPAddress }}' ${zeppelin_id})

echo Zeppelin started in:
echo http://$ip:8080
