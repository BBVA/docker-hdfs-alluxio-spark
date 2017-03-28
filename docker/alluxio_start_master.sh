#!/usr/bin/env bash

name=${1:-"alluxio-master"}

createNetwork() {
  sudo docker network inspect alluxio > /dev/null 2>&1

  if [ $? -eq 1 ]; then
    local network=$(sudo docker network create alluxio)
    echo "Created network alluxio $network"
  fi
}

createNetwork

id=$(sudo docker run -d --name ${name} -h ${name} --network=alluxio alluxio master start)

sleep 2s

ip=$(sudo docker inspect --format '{{ .NetworkSettings.Networks.alluxio.IPAddress }}' $id)

echo Access alluxio master console in:
echo http://$ip:19999
