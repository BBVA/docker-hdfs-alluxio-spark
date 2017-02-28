#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o errtrace

SPARK=/opt/spark
ALLUXIO=/opt/alluxio
HAADOOP=/opt/hadoop
ALLUXIO_HADDOP=/opt/alluxio_hadoom


export PATH=${PATH}:${SPARK}/bin

cp -a ${SPARK}/conf/spark-defaults.conf.template ${SPARK}/conf/spark-defaults.conf
cat > ${SPARK}/conf/spark-defaults.conf <<EOF
spark.driver.extraClassPath ${ALLUXIO}/core/client/target/alluxio-core-client-1.4.0-jar-with-dependencies.jar
spark.executor.extraClassPath ${ALLUXIO}/opt/alluxio/core/client/target/alluxio-core-client-1.4.0-jar-with-dependencies.jar
EOF

cp -a ${ALLUXIO}/conf/alluxio-site.properties.template ${ALLUXIO}/conf/alluxio-site.properties
cat > ${ALLUXIO}/conf/alluxio-site.properties <<EOF
alluxio.underfs.address=$SWIFT_ADDRESS
alluxio.network.thrift.frame.size.bytes.max=16384000
fs.swift.user=$SWIFT_USER
fs.swift.tenant=$SWIFT_TENANT
fs.swift.password=$SWIFT_PASSWORD
fs.swift.auth.url=$SWIFT_AUTHURL
fs.swift.use.public.url=$SWIFT_PUBLICURL
fs.swift.auth.method=$SWIFT_AUTHMETHOD
fs.swift.region=$SWIFT_REGION

alluxio.worker.tieredstore.levels=2

alluxio.worker.tieredstore.level0.alias=MEM
alluxio.worker.tieredstore.level0.dirs.path=/mnt/ramdisk
alluxio.worker.tieredstore.level0.dirs.quota=alluxio.worker.memory.size
alluxio.worker.tieredstore.level0.reserved.ratio=0.1

alluxio.worker.tieredstore.level1.alias=SSD
alluxio.worker.tieredstore.level1.dirs.path=/ssd
alluxio.worker.tieredstore.level1.dirs.quota=30GB
alluxio.worker.tieredstore.level1.reserved.ratio=0.1
EOF

sed -i 's/alluxio.worker.memory.size/${alluxio.worker.memory.size}/g' ${ALLUXIO}/conf/alluxio-site.properties

if [ echo "$HOSTNAME" | grep -qi ${SERVICE_NAME} ]; then


fi
 
