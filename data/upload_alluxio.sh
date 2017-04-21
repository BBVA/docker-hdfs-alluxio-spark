#!/bin/bash

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

