#!/usr/bin/env bash

set -o errexit
set -o pipefail
# set -o nounset
set -o errtrace

# https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/ClusterSetup.html

HADOOP_PREFIX=/opt/hadoop
HADOOP_CONF_DIR=${HADOOP_PREFIX}/etc/hadoop

core_site_default=(
	'fs.defaultFS=hdfs://127.0.0.1:8022'
	'io.file.buffer.size=131072'
)

hdfs_site_default=(
	'dfs.namenode.name.dir=/data/namenode/'
	'dfs.blocksize=268435456'
	'dfs.namenode.handler.count=100'
)

if [ "${CORE_SITE_CONF}z" == "z" ]; then
	CORE_SITE_CONF=$core_site_default
fi

if [ "${HDFS_SITE_CONF}z" == "z" ]; then
	HDFS_SITE_CONF=$hdfs_site_default
fi

name_node() {
	local action="$1"
	local cluster_name="$2"
	
	case $action in
		start)
			dir=`get_value_var "dfs.namenode.name.dir" "${HDFS_SITE_CONF}"`
			if [ ! -d $dir ]; then
				# The first time you bring up HDFS, it must be formatted. Format a new distributed filesystem as hdfs: 
				$HADOOP_PREFIX/bin/hdfs namenode -format $cluster_name
			fi
			# Start the HDFS NameNode with the following command on the designated node as hdfs:
			$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode
		;;
		stop)
			# Stop the NameNode with the following command, run on the designated NameNode as hdfs:
			$HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs stop namenode
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
			# Start a HDFS DataNode with the following command on each designated node as hdfs:
			$HADOOP_PREFIX/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
		;;
		stop)
			# Run a script to stop a DataNode as hdfs:
			$HADOOP_PREFIX/sbin/hadoop-daemons.sh --config $HADOOP_CONF_DIR --script hdfs stop datanode
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

resrouce_manager() {
	local action="$1"
	local cluster_name="$2"
	
	case $action in 
		start)	
			# Start the YARN with the following command, run on the designated ResourceManager as yarn:
			$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager
		;;
		stop)
			# Stop the ResourceManager with the following command, run on the designated ResourceManager as yarn:
			$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop resourcemanager
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

node_manger() {
	local action="$1"
	local cluster_name="$2"
	
	case $action in 
		start)	
			# Run a script to start a NodeManager on each designated host as yarn:
			$HADOOP_YARN_HOME/sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR start nodemanager
		;;
		stop)
			# Run a script to stop a NodeManager on a slave as yarn:
			$HADOOP_YARN_HOME/sbin/yarn-daemons.sh --config $HADOOP_CONF_DIR stop nodemanager
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

webproxy_server() {
	local action="$1"
	local cluster_name="$2"
	
	case $action in 
		start)	
			# Start a standalone WebAppProxy server. Run on the WebAppProxy server as yarn. If multiple servers are used with load balancing it should be run on each of them:
			$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start proxyserver
		;;
		stop)
			# Stop the WebAppProxy server. Run on the WebAppProxy server as yarn. If multiple servers are used with load balancing it should be run on each of them:
			$HADOOP_YARN_HOME/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR stop proxyserver
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

jobhistory_server() {
	local action="$1"
	local cluster_name="$2"
	
	case $action in 
		start)	
			# Start the MapReduce JobHistory Server with the following command, run on the designated server as mapred:
			$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver
		;;
		stop)
			# Stop the MapReduce JobHistory Server with the following command, run on the designated server as mapred:
			$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR stop historyserver
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
	local file="$1"
	shift
	local conf="$@"
	for p in "${conf[@]}"; do
		prop=$(echo $p | cut -f 1 -d '=')
		val=$(echo $p | cut -f 2 -d '=')
		./configure.py $file $prop $val
	done
}

get_value_var() {
	local name="$1"
	shift
	local conf="$@"
	for p in "${conf[@]}"; do
		prop=$(echo $p | cut -f 1 -d '=')
		val=$(echo $p | cut -f 2 -d '=')
		if [ "$prop" == "$name" ]; then
			echo $val
		else
		 	echo error readgin $name variable. Panic
		 	exit -2
		fi
	done
}


node="$1"
action="$2"
cluster_name="$3"

case $node in
	namenode)
		config "${HADOOP_CONF_DIR}/core-site.xml" ${CORE_SITE_CONF}
		config "${HADOOP_CONF_DIR}/hdfs-site.xml" ${HDFS_SITE_CONF}
		name_node $action $cluster_name
	;;
	datanode)
		date_node $action $cluster_name
	;;
	resourcemanager)
		resource_manager $action $cluster_name
	;;
	nodemanager)
		node_manager $action $cluster_name
	;;
	webproxyserver)
		webproxy_server $action $cluster_name
	;;
	jobhistoryserver)
		jobhistory_server $action $cluster_name
	;;
esac

tail -f /opt/hadoop/logs/*
