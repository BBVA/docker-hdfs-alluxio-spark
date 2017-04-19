#!/usr/bin/env bash

# Optional varaible
cluster_name="$3"

set -o errexit
set -o pipefail
set -o nounset
set -o errtrace


# main script mandatory params
node="$1"
action="$2"

set +o nounset

if [ "${cluster_name}z" == "z" ]; then
	cluster_name=${HOSTNAME}
fi


# https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/ClusterSetup.html

HADOOP_PREFIX=/opt/hadoop
HADOOP_CONF_DIR=${HADOOP_PREFIX}/etc/hadoop

# stars a name node
name_node() {
	local action="$1"
	local cluster_name="$2"

	case $action in
		start)
			if [ ! -d /data/${cluster_name}/ ]; then
				# The first time you bring up HDFS, it must be formatted. Format a new distributed filesystem as hdfs:
				mkdir -p /data/${cluster_name}
				$HADOOP_PREFIX/bin/hdfs namenode -format ${cluster_name}
			fi
			# Start the HDFS NameNode with the following command on the designated node as hdfs:
			$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config ${HADOOP_CONF_DIR} --script hdfs start namenode
		;;
		stop)
			# Stop the NameNode with the following command, run on the designated NameNode as hdfs:
			$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config ${HADOOP_CONF_DIR} --script hdfs stop namenode
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

data_node() {
	local action="$1"
	local cluster_name="$2"

	case $action in
		start)
			if [ ! -d /data/${cluster_name}/ ]; then
				mkdir -p /data/${cluster_name}
			fi
			# Start a HDFS DataNode with the following command on each designated node as hdfs:
			$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config ${HADOOP_CONF_DIR} --script hdfs start datanode
		;;
		stop)
			# Run a script to stop a DataNode as hdfs:
			$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config ${HADOOP_CONF_DIR} --script hdfs stop datanode
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

httpfs_node() {
	local action="$1"
	local cluster_name="$2"

	case $action in
		start)
			# Start a HDFS DataNode with the following command on each designated node as hdfs:
			$HADOOP_PREFIX/sbin/httpfs.sh start
		;;
		stop)
			# Run a script to stop a DataNode as hdfs:
			$HADOOP_PREFIX/sbin/httpfs.sh stop
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


config() {
	vars=(${CONF_VARS})
	files=(${CONF_FILES})
	for i in "${!vars[@]}"; do
		conf=${vars[i]}
		file=${files[i]}
		echo "${!conf}" > $file
	done
}

hadoop_handler() {
	local node="$1"
	local action="$2"
	local cluster_name="$3"

	case $node in
		namenode)
			name_node ${action} ${cluster_name}
		;;
		datanode)
			data_node ${action} ${cluster_name}
		;;
		httpfs)
			httpfs_node ${action} ${cluster_name}
		;;
		*)
			echo This component is not implemented, see boot.sh
		;;
	esac
}

setup_username() {
	export USER_ID=$(id -u)
	export GROUP_ID=$(id -g)
	cat /etc/passwd > /tmp/passwd
	cat /etc/group > /tmp/group
	echo "openshift:x:${USER_ID}:${GROUP_ID}:OpenShift Dynamic user:${ALLUXIO_PREFIX}:/bin/bash" >> /tmp/passwd
	echo "openshift:x:${GROUP_ID}:openshift" >> /tmp/group
	export LD_PRELOAD=/usr/lib/libnss_wrapper.so
	export NSS_WRAPPER_PASSWD=/tmp/passwd
	export NSS_WRAPPER_GROUP=/tmp/group
}

shut_down() {
	echo "Calling shutdown! $1"
	hadoop_handler ${node} stop ${cluster_name}
}

trap "shut_down sigkill" SIGKILL
trap "shut_down sigterm" SIGTERM
trap "shut_down sighup" SIGHUP
trap "shut_down sigint" SIGINT
# trap "shut_down sigexit" EXIT


setup_username
config

echo "The ${node} is swtching to ${action} with ${cluster_name} id"
hadoop_handler ${node} ${action} ${cluster_name}

sleep 2s
tail -f /opt/hadoop/logs/*
