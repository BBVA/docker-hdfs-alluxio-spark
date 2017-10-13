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

alluxio_master="$1"

cat << EOF  | oc rsh  ${alluxio_master}
cd /tmp
echo Downloading....
wget https://s3.amazonaws.com/alluxio-sample/datasets/sample-1g.gz
wget https://s3.amazonaws.com/alluxio-sample/datasets/sample-2g.gz
echo Uncompressing....
gunzip sample-1g.gz
gunzip sample-2g.gz
cd /opt/alluxio/bin
echo Uploading....
./alluxio fs mkdir /data
./alluxio fs -Dalluxio.user.file.write.location.policy.class=alluxio.client.file.policy.RoundRobinPolicy copyFromLocal /tmp/sample-1g /data/sample-1g
./alluxio fs -Dalluxio.user.file.write.location.policy.class=alluxio.client.file.policy.RoundRobinPolicy copyFromLocal /tmp/sample-2g /data/sample-2g
echo Deleting temporal files...
rm /tmp/sample-1g
rm /tmp/sample-2g
EOF
