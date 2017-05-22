#!/bin/bash
set -o nounset -o errexit
export PATH=/usr/sbin:/usr/bin:$PATH

#Dirs to create
export HDFS_DIRS="spark/eventlogs jobs data"

#Get Minishif IP addr
export MINISHIFT_IP=$(minishift ip)

#Set params..
export ALLUXIO_PROXY=http://alluxio-master-rest-has.${MINISHIFT_IP}.io
export HUSER=openshift
export HTTPFS=http://hdfs-httpfs-has.${MINISHIFT_IP}.nip.io

echo "This is your config:"
echo -e "Alluxio proxy: ${ALLUXIO_PROXY}\nUsername: ${HUSER}\nHTTPFS URL: ${HTTPFS}\n"

#Create dirs..
for i in $HDFS_DIRS
do
  echo -e "Creating dir $i"
  ./httpfs.sh mkdir $i
done
