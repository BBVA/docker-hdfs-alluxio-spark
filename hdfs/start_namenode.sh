#!/usr/bin/env bash

volume=${1:-"/tmp/data"}
name=${2:-"namenode"}

createNetwork() {
  sudo docker network inspect alluxio > /dev/null 2>&1

  if [ $? -eq 1 ]; then
    local network=$(sudo docker network create --attachable alluxio)
    echo "Created network alluxio $network"
  fi
}

createNetwork

mkdir -p $volume

id=$(sudo docker run -d -v ${volume}:/data --name ${name} -h ${name} --network=alluxio  hdfs namenode start ${name})

sleep 2s

ip=$(sudo docker inspect --format '{{ .NetworkSettings.Networks.alluxio.IPAddress }}' $id)

echo Access namenode console in:
echo http://$ip:50070
