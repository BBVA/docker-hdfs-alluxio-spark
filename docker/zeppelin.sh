#!/bin/bash

set -e
# defaults
net=${NET:-"hasz"}
nodes=${NODES:-1}
volume=${VOLUME:-"/tmp/data"}


# check network existence and create it if necessary
# we need this network for the automatic service discovery in docker engine
docker network inspect ${net} > /dev/null 2>&1

if [ $? -eq 1 ]; then
	net_id=$(docker network create ${net})
	echo "Created network ${net} with id ${net_id}"
fi

# bring up namenode and show its url
mkdir -p ${volume}/zeppelin
zeppelin_id=$(docker run -d -v ${volume}/zeppelin:/data -p 8081:8080 --name zeppelin -h zeppelin --network=${net} zeppelin master start zeppelin)

ip=$(docker inspect --format '{{ .NetworkSettings.Networks.'${net}'.IPAddress }}' ${zeppelin_id})

echo Zeppelin started in:
echo http://$ip:8080
