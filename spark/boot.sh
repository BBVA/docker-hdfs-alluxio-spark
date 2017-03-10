#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
set -o errtrace


# main script params

node="$1"
action="$2"

set +o nounset

# https://hadoop.apache.org/docs/r2.7.3/hadoop-project-dist/hadoop-common/ClusterSetup.html


SPARK_PREFIX=/opt/spark
SPARK_CONF_DIR=${SPARK_PREFIX}/conf
mkdir -p ${SPARK_PREFIX}/logs/

master_node() {
	local action="$1"

	case $action in
		start)
			${SPARK_PREFIX}/sbin/start-master.sh
		;;
		stop)
      ${SPARK_PREFIX}/sbin/stop-master.sh
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

	case $action in
    start)
			${SPARK_PREFIX}/sbin/start-slave.sh spark://spark-master:7077
		;;
		stop)
      ${SPARK_PREFIX}/sbin/stop-slave.sh
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
		prop=$(echo ${p} | cut -f 1 -d '=')
		val=$(echo ${p} | cut -f 2 -d '=')
		./configure.py $file ${prop} ${val}
	done
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
