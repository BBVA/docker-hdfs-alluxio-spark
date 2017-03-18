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

set +o nounset

# https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/ClusterSetup.html


export SPARK_HOME=/opt/spark
export SPARK_CONF_DIR=${SPARK_HOME}/conf

# export SPARK_MASTER_HOST=${SPARK_MASTER_HOST:-"spark-master"}
# SPARK_MASTER_PORT is also defined by openshift to a value incompatible 
export SPARK_MASTER_PORT=7077
export SPARK_MASTER_WEBUI_PORT=${SPARK_MASTER_WEBUI_PORT:-8080}

export SPARK_WORKER_MEMORY=${SPARK_WORKER_MEMORY:-"1g"}
export SPARK_WORKER_PORT=${SPARK_WORKER_PORT:-35000}
export SPARK_WORKER_WEBUI_PORT=${SPARK_WORKER_WEBUI_PORT:-8081}

export SPARK_DAEMON_MEMORY=${SPARK_DAEMON_MEMORY:-"1g"}

mkdir -p ${SPARK_HOME}/logs/

master_node() {
	local action="${1}"
	local cluster_name="${2}"
	
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
			${SPARK_HOME}/sbin/start-slave.sh spark://${SPARK_MASTER_HOST}:${SPARK_MASTER_PORT}
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


get_value_var() {
	local name="$1"
	shift
	local conf="$@"
	for p in "${conf[@]}"; do
		prop=$(echo ${p} | cut -f 1 -d '=')
		val=$(echo ${p} | cut -f 2 -d '=')
		if [ "${prop}" == "${name}" ]; then
			echo ${val}
		else
		 	echo error reading ${name} variable. Panic
		 	exit -2
		fi
	done
}

spark_handler() {
	local node="$1"
	local action="$2"

	echo "spark_handler():${node} ${action}"
	case $node in
		master)
			master_node ${action}
		;;
		slave)
			slave_node ${action}
		;;
	esac
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


echo "The ${node} is swtching to ${action}"
spark_handler ${node} ${action} ${cluster_name}

sleep 2s
tail -f /opt/spark/logs/*
