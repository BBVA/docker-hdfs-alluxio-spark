#!/bin/bash

# Copyright 2017 Banco Bilbao Vizcaya Argentaria S.A.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o nounset -o errexit
export PATH=/usr/sbin:/usr/bin:$PATH

#Dirs to create
export HDFS_DIRS="spark/eventlogs jobs data"

#Get Minishif IP addr
export MINISHIFT_IP=$(minishift ip)

#Set params..
export ALLUXIO_PROXY=http://alluxio-master-rest-has.${MINISHIFT_IP}.nip.io
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
