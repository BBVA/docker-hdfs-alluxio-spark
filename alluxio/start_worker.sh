#!/usr/bin/env bash

master=${1:-"master"}
namenode=${2:-"namenode"}

sudo docker run -d --link ${namenode} --link master alluxio slave start ${master} 
