#!/bin/bash

set -e
# defaults
net=${NET:-"hasz"}
nodes=${NODES:-2}
volume=${VOLUME:-"/tmp/data"}


# check network existence and create it if necessary
# we need this network for the automatic service discovery in docker engine
docker network inspect ${net} > /dev/null 2>&1

if [ $? -eq 1 ]; then
	net_id=$(docker network create ${net})
	echo "Created network ${net} with id ${net_id}"
fi

# bring up namenode and show its url
mkdir -p ${volume}/spark-master

spark_master_id=$(docker run --shm-size 2g -d -v ${volume}/spark-master:/data -p 8080:8080 -p 7077:7077 --name spark-master -h spark-master --network=${net}  spark master start hdfs-namenode)

sleep 2s

ip=$(docker inspect --format '{{ .NetworkSettings.Networks.'${net}'.IPAddress }}' ${spark_master_id})

echo Master started in:
echo http://$ip:7077

for n in $(seq 1 1 ${nodes}); do
	echo Starting node ${n}
	mkdir -p ${volume}/spark-worker${n}
	datanode_id=$(docker run --shm-size 2g -d -v ${volume}/spark-worker${n}:/data --name spark-worker${n} -h spark-worker${n} --network=${net} spark slave start spark-master)
done
