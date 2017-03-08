#!/usr/bin/env bash

volume=${1:-"/tmp/data"}
name=${2:-"namenode"}

mkdir -p $volume

sudo docker run -d -v ${volume}:/data --link ${name} hdfs datanode start ${name}
