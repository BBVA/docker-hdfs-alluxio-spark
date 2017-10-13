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

#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o errtrace

# main script params

node="$1"
action="$2"
cluster_name="$3"


# http://www.alluxio.org/docs/1.4/en/Configuration-Settings.html

export ALLUXIO_WORKER_MEMORY_SIZE=${ALLUXIO_WORKER_MEMORY_SIZE:-"1024MB"}
export ALLUXIO_UNDERFS_ADDRESS=${ALLUXIO_UNDERFS_ADDRESS:-"hdfs://hdfs-namenode:8020"}
export ALLUXIO_PREFIX=/opt/alluxio
export HADOOP_CONF_DIR=/opt/alluxio/conf

master_node() {
	local action="$1"
	local cluster_name="$2"

	case $action in
		start)
			export ALLUXIO_MASTER_HOSTNAME=${cluster_name}
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

alluxio_handler() {
	local node="$1"
	local action="$2"
	local cluster_name="$3"

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


trap "shut_down sigkill" SIGKILL
trap "shut_down sigterm" SIGTERM
trap "shut_down sighup" SIGHUP
trap "shut_down sigint" SIGINT
# trap "shut_down sigexit" EXIT

setup_username
alluxio_handler ${node} ${action} ${cluster_name}

sleep 2s
tail -f /opt/alluxio/logs/*
