#!/usr/bin/env bash

cluster_name="$3"

set -o errexit
set -o pipefail
set -o nounset
set -o errtrace

# main script params

node="$1"
action="$2"

set +o nounset

if [ "${cluster_name}z" == "z" ]; then
	cluster_name=${HOSTNAME}
fi

# http://www.alluxio.org/docs/1.4/en/Configuration-Settings.html

export ALLUXIO_PREFIX=/opt/alluxio

export ALLUXIO_WORKER_MEMORY_SIZE=${ALLUXIO_WORKER_MEMORY_SIZE:-"1024MB"}
export ALLUXIO_RAM_FOLDER=${ALLUXIO_RAM_FOLDER:-"/mnt/ramdisk"}
export ALLUXIO_UNDERFS_ADDRESS=${ALLUXIO_UNDERFS_ADDRESS:-"hdfs://hdfs-namenode:8020"}

set +o nounset

master_node() {
	local action="$1"
	local cluster_name="$2"

	case $action in
		start)
			export ALLUXIO_MASTER_HOSTNAME=${cluster_name}
			config_hdfs "${HADOOP_CONF_DIR}/core-site.xml" ${CORE_SITE_CONF[@]}
			config_hdfs "${HADOOP_CONF_DIR}/hdfs-site.xml" ${HDFS_SITE_CONF[@]}
			if [ ! -f /opt/alluxio/conf/alluxio-env.sh ]; then
				${ALLUXIO_PREFIX}/bin/alluxio bootstrapConf ${cluster_name}
			fi
			if [ ! -d /opt/alluxio/journal/ ]; then
				mkdir -p /opt/alluxio/journal/
				${ALLUXIO_PREFIX}/bin/alluxio format
			fi
			${ALLUXIO_PREFIX}/bin/alluxio-start.sh master
			${ALLUXIO_PREFIX}/bin/alluxio-start.sh proxy
		;;
		stop)
			${ALLUXIO_PREFIX}/bin/alluxio-stop.sh proxy
			${ALLUXIO_PREFIX}/bin/alluxio-stop.sh master
		;;
		status)
			# I would love a status report
			echo "Not implemented"
		;;
		*)
		echo "Action not supported"
		;;
	esac

}

slave_node() {
	local action="$1"
	local cluster_name="$2"

	case $action in
		start)
			export ALLUXIO_MASTER_HOSTNAME=${cluster_name}
			config_hdfs "${HADOOP_CONF_DIR}/core-site.xml" ${CORE_SITE_CONF[@]}
			config_hdfs "${HADOOP_CONF_DIR}/hdfs-site.xml" ${HDFS_SITE_CONF[@]}
			${ALLUXIO_PREFIX}/bin/alluxio-start.sh worker NoMount
		;;
		stop)
			${ALLUXIO_PREFIX}/bin/alluxio-stop.sh worker
		;;
		status)
			# I would love a status report
			echo "Not implemented"
		;;
		*)
		echo "Action not supported"
		;;
	esac
}

config_alluxio() {
	local file="${1}"
	shift
	local conf=("${@}")
	for p in "${conf[@]}"; do
		echo ${p} >> ${file}
	done
}

config_hdfs() {
	local file="${1}"
	shift
	local conf=("${@}")
	echo "<configuration>" > ${file}
	for p in "${conf[@]}"; do
		prop=$(echo ${p} | cut -f 1 -d '=')
		val=$(echo ${p} | cut -f 2 -d '=')
		echo "$file: $prop = $val"
		echo "<property>" >> ${file}
		echo "<name>${prop}</name><value>${val}</value>" >> ${file}
		echo "</property>" >> ${file}
	done
	echo "</configuration>" >> ${file}
}


alluxio_handler() {
	local node="$1"
	local action="$2"
	local cluster_name="$3"
	echo "alluxio_handler():${node} ${action} ${cluster_name}"
	case $node in
		master)
			master_node ${action} ${cluster_name}
		;;
		slave)
			slave_node ${action} ${cluster_name}
		;;
	esac
}

setup_username() {
	export USER_ID=$(id -u)
	export GROUP_ID=$(id -g)
	cat /etc/passwd > /tmp/passwd
	echo "openshift:x:${USER_ID}:${GROUP_ID}:OpenShift Dynamic user:${ALLUXIO_PREFIX}:/bin/bash" >> /tmp/passwd
	export LD_PRELOAD=/usr/lib/libnss_wrapper.so
	export NSS_WRAPPER_PASSWD=/tmp/passwd
	export NSS_WRAPPER_GROUP=/etc/group
}

shut_down() {
	echo "Calling shutdown! $1"
	alluxio_handler ${node} stop ${cluster_name}
}

default_properties=(
	"alluxio.security.authentication.type=SIMPLE"
	"alluxio.security.authorization.permission.enabled=true"
	"alluxio.user.block.size.bytes.default=32MB"
  "alluxio.user.file.write.location.policy.class=alluxio.client.file.policy.RoundRobinPolicy"
  "alluxio.user.file.writetype.default=CACHE_THROUGH"
)

# default config
# For httpfs config
# https://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/Superusers.html
# insecure defaults
core_site_default=(
	"fs.defaultFS=hdfs://${cluster_name}:8020"
	"io.file.buffer.size=131072"
	"hadoop.proxyuser.openshift.hosts=172.16.0.0/12,10.0.0.0/8"
	"hadoop.proxyuser.openshift.groups=openshift,root"
	"hadoop.proxyuser.root.hosts=172.16.0.0/12,10.0.0.0/8"
	"hadoop.proxyuser.root.groups=root"
)

# https://log.rowanto.com/why-datanode-is-denied-communication-with-namenode/
# disable remote host name check, enable in production with a correct service
# discovery reverse dns set up
hdfs_site_default=(
	"dfs.namenode.name.dir=file:///data/${cluster_name}/"
	"dfs.blocksize=33554432"
	"dfs.namenode.handler.count=100"
	"dfs.namenode.servicerpc-address=hdfs://${cluster_name}:8022"
	"dfs.namenode.datanode.registration.ip-hostname-check=false"
	"dfs.datanode.data.dir=/data/${cluster_name}"
	"dfs.client.use.datanode.hostname=true"
	"dfs.datanode.use.datanode.hostname=true"
)

if [ "${CORE_SITE_CONF}z" == "z" ]; then
	CORE_SITE_CONF=${core_site_default[@]}
fi

if [ "${HDFS_SITE_CONF}z" == "z" ]; then
	HDFS_SITE_CONF=${hdfs_site_default[@]}
fi

trap "shut_down sigkill" SIGKILL
trap "shut_down sigterm" SIGTERM
trap "shut_down sighup" SIGHUP
trap "shut_down sigint" SIGINT
# trap "shut_down sigexit" EXIT


setup_username

config_alluxio "${ALLUXIO_PREFIX}/conf/alluxio-site.properties" "${default_properties[@]}"
alluxio_handler ${node} ${action} ${cluster_name}

sleep 2s
tail -f /opt/alluxio/logs/*
