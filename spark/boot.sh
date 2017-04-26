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
SPARK_MASTER_HOST=${cluster_name}

export SPARK_HOME=/opt/spark
export SPARK_CONF_DIR=${SPARK_HOME}/conf

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
	local action="${1}"

	case $action in
		start)
			${SPARK_HOME}/sbin/start-slave.sh --host $(hostname -f) spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT}
			;;
		stop)
			${SPARK_HOME}/sbin/stop-slave.sh
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

history_node() {
	local action="${1}"

	case $action in
		start)
			${SPARK_HOME}/sbin/start-history-server.sh
			;;
		stop)
			${SPARK_HOME}/sbin/stop-history-server.sh
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


config() {
	vars=(${CONF_VARS})
	files=(${CONF_FILES})
	for i in "${!vars[@]}"; do
		conf=${vars[i]}
		file=${files[i]}
		echo "${!conf}" > $file
	done
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
config

echo "The ${node} is swtching to ${action}"

spark_handler ${node} ${action} ${cluster_name}

sleep 2s
tail -f /opt/spark/logs/*
