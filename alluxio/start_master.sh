#!/usr/bin/env bash

name=${1:-"master"}
hdfs_name=${2:-"namenode"}



id=$(sudo docker run -d --name ${name} -h ${name}  --link ${hdfs_name} alluxio master start ${name})

sleep 2s

ip=$(sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' $id)

echo Access namenode console in:
echo http://$ip:19999
