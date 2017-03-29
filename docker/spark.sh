#!/bin/bash

set -e
# defaults
net=${NET:-"hasz"}
nodes=${NODES:-3}
volume=${VOLUME:-"/tmp/data"}


# check network existence and create it if necessary
# we need this network for the automatic service discovery in docker engine 
sudo docker network inspect ${net} > /dev/null 2>&1

if [ $? -eq 1 ]; then
	net_id=$(sudo docker network create ${net})
	echo "Created network ${net} with id ${net_id}"
fi

# bring up namenode and show its url
mkdir -p ${volume}/spark-master
spark_master_id=$(sudo docker run -d -v ${volume}/spark-master:/data --name spark-master -h spark-master --network=${net}  spark master start hdfs-namenode)

sleep 2s

ip=$(sudo docker inspect --format '{{ .NetworkSettings.Networks.'${net}'.IPAddress }}' ${spark_master_id})

echo Master started in:
echo http://$ip:7077

for n in $(seq 1 1 ${nodes}); do
	echo Starting node ${n}
	mkdir -p ${volume}/spark-worker${n}
	datanode_id=$(sudo docker run -d -v ${volume}/spark-worker${n}:/data --name spark-worker${n} -h spark-worker${n} --network=${net} spark slave start spark-master)
done
