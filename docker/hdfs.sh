#!/bin/bash

set -e
# defaults
net=${NET:-"hasz"}
nodes=${NODES:-3}
volume=${VOLUME:-"/tmp/data"}


# check network existence and create it if necessary
# we need this network for the automatic service discovery in docker engine
docker network inspect ${net} > /dev/null 2>&1

if [ $? -eq 1 ]; then
	net_id=$(docker network create ${net})
	echo "Created network ${net} with id ${net_id}"
fi

# bring up namenode and show its url
mkdir -p ${volume}/hdfs-namenode
hdfs_master_id=$(docker run -d -v ${volume}/hdfs-namenode:/data -p 50070:50070 --name hdfs-namenode -h hdfs-namenode --network=${net}  hdfs namenode start hdfs-namenode)

sleep 2s

ip=$(docker inspect --format '{{ .NetworkSettings.Networks.'${net}'.IPAddress }}' ${hdfs_master_id})

echo Master started in:
echo http://$ip:50070

for n in $(seq 1 1 ${nodes}); do
	echo Starting node ${n}
	mkdir -p ${volume}/hdfs-datanode${n}
	datanode_id=$(docker run -d -v ${volume}/hdfs-datanode${n}:/data --name hdfs-datanode${n} -h hdfs-datanode${n} --network=${net} hdfs datanode start hdfs-namenode)
done
