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


# main script params

node="$1"
action="$2"
cluster_name="$3"


export SPARK_HOME=/opt/spark
export SPARK_CONF_DIR=${SPARK_HOME}/conf
export HADOOP_CONF_DIR=/opt/spark/conf

# SPARK_MASTER_PORT is also defined by openshift to a value incompatible
# so we need to foce it here
export SPARK_MASTER_PORT=7077

mkdir -p ${SPARK_HOME}/logs/

master_node() {
	local action="${1}"

	case $action in
		start)
			${SPARK_HOME}/sbin/start-master.sh
		;;
		stop)
			${SPARK_HOME}/sbin/stop-master.sh
		;;
		*)
			echo "Action not supported"
			;;
	esac

}

slave_node() {
	local action="${1}"

	case $action in
		start)
			${SPARK_HOME}/sbin/start-slave.sh --host $(hostname -f) spark://${cluster_name}:${SPARK_MASTER_PORT}
			;;
		stop)
			${SPARK_HOME}/sbin/stop-slave.sh
			;;
		*)
			echo "Action not supported"
			;;
	esac
}

history_node() {
	local action="${1}"

	case $action in
		start)
			${SPARK_HOME}/sbin/start-history-server.sh
			;;
		stop)
			${SPARK_HOME}/sbin/stop-history-server.sh
			;;
		*)
			echo "Action not supported"
			;;
	esac
}

spark_handler() {
	local node="$1"
	local action="$2"

	case $node in
		master)
			master_node ${action}
		;;
		slave)
			slave_node ${action}
		;;
		history)
			history_node ${action}
		;;
	esac
}

setup_username() {
	export USER_ID=$(id -u)
	export GROUP_ID=$(id -g)
	cat /etc/passwd > /tmp/passwd
	echo "openshift:x:${USER_ID}:${GROUP_ID}:OpenShift Dynamic user:${SPARK_HOME}:/bin/bash" >> /tmp/passwd
	export LD_PRELOAD=/usr/lib/libnss_wrapper.so
	export NSS_WRAPPER_PASSWD=/tmp/passwd
	export NSS_WRAPPER_GROUP=/etc/group
}


shut_down() {
	echo "Calling shutdown! $1"
	spark_handler ${node} stop
}

trap "shut_down sigkill" SIGKILL
trap "shut_down sigterm" SIGTERM
trap "shut_down sighup" SIGHUP
trap "shut_down sigint" SIGINT
# trap "shut_down sigexit" EXIT

setup_username
spark_handler ${node} ${action} ${cluster_name}

sleep 2s
tail -f /opt/spark/logs/*
