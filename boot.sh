#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o errtrace


HADOOP_PREFIX=/opt/hadoop
HADOOP_CONF_DIR=${HADOOP_PREFIX}/etc/hadoop

# https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/ClusterSetup.html
mkdir -p /opt/hadoop/pid

HADOOP_PID_DIR="/opt/hadoop/pid"
HADOOP_LOG_DIR=""
HADOOP_HEAPSIZE="1000MB"
YARN_HEAPSIZE="1000MB"

HADOOP_NAMENODE_OPTS=""
HADOOP_DATANODE_OPTS=""
HADOOP_SECONDARYNAMENODE_OPTS=""
YARN_RESOURCEMANAGER_OPTS=""
YARN_NODEMANAGER_OPTS=""
YARN_PROXYSERVER_OPTS=""
HADOOP_JOB_HISTORYSERVER_OPTS=""

YARN_RESOURCEMANAGER_HEAPSIZE=""
YARN_NODEMANAGER_HEAPSIZE=""
YARN_PROXYSERVER_HEAPSIZE=""
HADOOP_JOB_HISTORYSERVER_HEAPSIZE=""

# etc/hadoop/core-site.xml
fs.defaultFS=""
io.file.buffer.size="131072"

# etc/hadoop/hdfs-site.xml
# namenode
dfs.namenode.name.dir=""
dfs.hosts=""
dfs.hosts.exclude=""
dfs.blocksize="268435456"
dfs.namenode.handler.count="100"

# datanode
dfs.datanode.data.dir=""

# etc/hadoop/yarn-site.xml
# Configurations for ResourceManager and NodeManager
yarn.acl.enable="false"
yarn.admin.acl=""
yarn.log-aggregation-enable="false"

# ResourceManager
yarn.resourcemanager.address
yarn.resourcemanager.scheduler.address
yarn.resourcemanager.resource-tracker.address
yarn.resourcemanager.admin.address
yarn.resourcemanager.webapp.address
yarn.resourcemanager.hostname
yarn.resourcemanager.scheduler.class
yarn.scheduler.minimum-allocation-mb
yarn.scheduler.maximum-allocation-mb
yarn.resourcemanager.nodes.include-path
yarn.resourcemanager.nodes.exclude-path

# NodeManager
yarn.nodemanager.resource.memory-mb
yarn.nodemanager.vmem-pmem-ratio
yarn.nodemanager.local-dirs
yarn.nodemanager.log-dirs
yarn.nodemanager.log.retain-seconds="10800"
yarn.nodemanager.remote-app-log-dir
yarn.nodemanager.remote-app-log-dir-suffix
yarn.nodemanager.aux-services

# HistoryServer
yarn.log-aggregation.retain-seconds	-1
yarn.log-aggregation.retain-check-interval-seconds

# etc/hadoop/mapred-site.xml
mapreduce.framework.name="yarn"
mapreduce.map.memory.mb="1536"
mapreduce.map.java.opts="-Xmx1024M"
mapreduce.reduce.memory.mb="3072"
mapreduce.reduce.java.opts="-Xmx2560M"
mapreduce.task.io.sort.mb="512"
mapreduce.task.io.sort.factor="100"
mapreduce.reduce.shuffle.parallelcopies="50"

# MapRedurer JobHistoryServer
mapreduce.jobhistory.address=":10020"
mapreduce.jobhistory.webapp.address=":8888"
mapreduce.jobhistory.intermediate-done-di
mapreduce.jobhistory.done-dir

# Monitoring Health NodeManager
yarn.nodemanager.health-checker.script.path=""
yarn.nodemanager.health-checker.script.opts=""
yarn.nodemanager.health-checker.script.interval-ms=""
yarn.nodemanager.health-checker.script.timeout-ms=""

# etc/hadoop/slaves
# Not used in java-base functionality, so no ssh

# https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/RackAwareness.html
topology.script.file.name
topology.node.switch.mapping.impl


# Remeber docs: https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/ClusterSetup.html

name_node() {
	local action="$1"
	local cluster_name="$2"
	
	case $action:
		start)
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
		init)
			# The first time you bring up HDFS, it must be formatted. Format a new distributed filesystem as hdfs: 
			$HADOOP_PREFIX/bin/hdfs namenode -format $cluster_name
		*)
		echo "Action not supported"
	esac
	
}

data_node() {
	local action="$1"
	local cluster_name="$2"
	
	case $action:
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
	esac
}

resrouce_manager() {
	local action="$1"
	local cluster_name="$2"
	
	case $action:
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
	esac			
}

node_manger() {
	local action="$1"
	local cluster_name="$2"
	
	case $action:
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
	esac			
}

webproxy_server() {
	local action="$1"
	local cluster_name="$2"
	
	case $action:
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
	esac					
}

jobhistory_server() {
	local action="$1"
	local cluster_name="$2"
	
	case $action:
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
	esac					
}

local action="$1"
local node="$2"
local cluster_name="$3"

case $node:
	namenode)
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
