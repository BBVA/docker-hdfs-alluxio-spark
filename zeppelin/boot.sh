#!/usr/bin/env bash

cluster_name="$3"

set -o errexit
set -o pipefail
set -o nounset
set -o errtrace


# main script params

node="$1"
action="$2"


if [ "${cluster_name}z" == "z" ]; then
	cluster_name=${HOSTNAME}
fi
ZEPPELIN_MASTER_HOST=${cluster_name}

set +o nounset

# http://zeppelin.apache.org/docs/0.7.0/install/install.html
# http://zeppelin.apache.org/docs/0.7.0/install/configuration.html

export ZEPPELIN_PORT=${ZEPPELIN_PORT:-8080}
export ZEPPELIN_NOTEBOOK_DIR=${ZEPPELIN_NOTEBOOK_DIR:-/data/zeppelin}
export ZEPPELIN_NOTEBOOK_PUBLIC=${ZEPPELIN_NOTEBOOK_PUBLIC:-false}
export ZEPPELIN_HOME=/opt/zeppelin
export SPARK_HOME=/opt/spark
export ALLUXIO_HOME=${SPARK_HOME}
export HADOOP_CONF_DIR=${SPARK_HOME}/conf

mkdir -p ${ZEPPELIN_HOME}/logs/
mkdir -p ${ZEPPELIN_NOTEBOOK_DIR}

master_node() {
	local action="${1}"
	local cluster_name="${2}"

	case $action in
		start)
			${ZEPPELIN_HOME}/bin/zeppelin-daemon.sh start
		;;
		stop)
			${ZEPPELIN_HOME}/bin/zeppelin-daemon.sh stop
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


zeppelin_handler() {
	local node="$1"
	local action="$2"

	echo "spark_handler():${node} ${action}"
	case $node in
		master)
			master_node ${action}
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
	zeppelin_handler ${node} stop
}

trap "shut_down sigkill" SIGKILL
trap "shut_down sigterm" SIGTERM
trap "shut_down sighup" SIGHUP
trap "shut_down sigint" SIGINT
# trap "shut_down sigexit" EXIT

setup_username
echo "The ${node} is swtching to ${action}"
zeppelin_handler ${node} ${action} ${cluster_name}

sleep 2s
tail -f /opt/zeppelin/logs/*
