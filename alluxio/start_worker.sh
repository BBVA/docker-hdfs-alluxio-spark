#!/usr/bin/env bash

node=${1:-0}
master=${2:-"master"}
namenode=${3:-"namenode"}

sudo docker run -d --link ${namenode} --link ${master} --name slave${node} -h data${node} alluxio slave start ${master} 
