#!/usr/bin/env bash

volume=${1:-"/tmp/data"}
name=${2:-"namenode"}

mkdir -p $volume

id=$(sudo docker run -d -v ${volume}:/data --name ${name} -h ${name}  hdfs namenode start ${name})

sleep 2s

ip=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $id)

echo Access namenode console in:
echo http://$ip:50070
