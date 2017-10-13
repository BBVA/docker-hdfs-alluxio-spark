#!/usr/bin/env bash

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

set -o errexit
set -o pipefail
set -o nounset
set -o errtrace

# main script mandatory params
node="$1"
action="$2"
cluster_name="$3"

# https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/ClusterSetup.html

export HADOOP_PREFIX=/opt/hadoop
export HADOOP_CONF_DIR=${HADOOP_PREFIX}/etc/hadoop
export HTTPFS_HTTP_PORT=${HTTPFS_HTTP_PORT:-14000}
export HTTPFS_ADMIN_PORT=${HTTPFS_ADMIN_PORT:-14001}

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
		*)
		echo "Action not supported"
		;;
	esac
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
	echo "openshift:x:${USER_ID}:${GROUP_ID}:OpenShift Dynamic user:${HADOOP_PREFIX}:/bin/bash" >> /tmp/passwd
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
hadoop_handler ${node} ${action} ${cluster_name}

sleep 2s
tail -f /opt/hadoop/logs/*
