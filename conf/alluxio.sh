
export alluxio_master="alluxio_master"

export ALLUXIO_CONF_VARS="CORE_SITE_CONF HDFS_SITE_CONF ALLUXIO_CONF"
export ALLUXIO_CONF_FILES="/opt/alluxio/conf/core-site.xml /opt/alluxio/conf/hdfs-site.xml /opt/alluxio/conf/alluxio-site.properties"


export ALLUXIO_WORKER_MEMORY_SIZE=${ALLUXIO_WORKER_MEMORY_SIZE:-"1024MB"}
export ALLUXIO_RAM_FOLDER=${ALLUXIO_RAM_FOLDER:-"/mnt/ramdisk"}
export ALLUXIO_UNDERFS_ADDRESS=${ALLUXIO_UNDERFS_ADDRESS:-"hdfs://hdfs-namenode:8020"}
# export HADOOP_CONF_DIR="${ALLUXIO_PREFIX}/conf/"

read -r -d '' ALLUXIO_CONF <<EOF
	alluxio.security.authentication.type=SIMPLE
	alluxio.security.authorization.permission.enabled=true
	alluxio.user.block.size.bytes.default=32MB
  alluxio.user.file.write.location.policy.class=alluxio.client.file.policy.RoundRobinPolicy
  alluxio.user.file.writetype.default=MUST_CACHE
	alluxio.master.hostname=alluxio-master
EOF
export ALLUXIO_CONF
