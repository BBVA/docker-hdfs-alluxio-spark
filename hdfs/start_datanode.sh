#!/usr/bin/env bash

node=${1:-0}
volume=${2:-"/tmp/data"}
name=${3:-"namenode"}

mkdir -p $volume

sudo docker run -d -v ${volume}:/data --link ${name} --name data${node} -h data${node} hdfs datanode start ${name}
