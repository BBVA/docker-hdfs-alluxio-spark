#!/bin/bash

set -e
# defaults
net=${NET:-"hasz"}
nodes=${NODES:-2}
volume=${VOLUME:-"/tmp/data"}

export ALLUXIO_WORKER_MEMORY_SIZE=512MB
export HADOOP_CONFIG_DIR=/opt/alluxio/conf

# check network existence and create it if necessary
# we need this network for the automatic service discovery in docker engine
docker network inspect ${net} > /dev/null 2>&1

if [ $? -eq 1 ]; then
	net_id=$(docker network create ${net})
	echo "Created network ${net} with id ${net_id}"
fi

# bring up namenode and show its url
mkdir -p ${volume}/alluxio-master
alluxio_master_id=$(docker run --shm-size 2g -d \
	-v ${volume}/alluxio-master:/data \
	-p 19999:19999 \
	-p 19998:19998 \
	--name alluxio-master \
	-h alluxio-master \
	--network=${net}  \
	-e ALLUXIO_WORKER_MEMORY_SIZE \
	-e HADOOP_CONFIG_DIR \
	alluxio master start alluxio-master)

sleep 2s

ip=$(docker inspect --format '{{ .NetworkSettings.Networks.'${net}'.IPAddress }}' ${alluxio_master_id})

echo Master started in:
echo http://$ip:19999

for n in $(seq 1 1 ${nodes}); do
	echo Starting node ${n}
	mkdir -p ${volume}/alluxio-worker${n}
	datanode_id=$(docker run --shm-size 2g -d \
		-v ${volume}/alluxio-worker${n}:/data \
		--name alluxio-worker${n} \
		-h alluxio-worker${n} \
		--network=${net} \
		-e ALLUXIO_WORKER_MEMORY_SIZE \
		-e HADOOP_CONFIG_DIR \
		alluxio slave start alluxio-master)
done


