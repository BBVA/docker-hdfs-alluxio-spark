#!/usr/bin/env bash

export SPARK_HOME=/opt/spark

executable=$SPARK_HOME/bin/spark-submit
job_path=/spark-job.jar
job_args=""
submit_args=""

setup_username() {
	export USER_ID=$(id -u)
	export GROUP_ID=$(id -g)
	cat /etc/passwd > /tmp/passwd
	echo "openshift:x:${USER_ID}:${GROUP_ID}:OpenShift Dynamic user:${SPARK_HOME}:/bin/bash" >> /tmp/passwd
	export LD_PRELOAD=/usr/lib/libnss_wrapper.so
	export NSS_WRAPPER_PASSWD=/tmp/passwd
	export NSS_WRAPPER_GROUP=/etc/group
}

setup_username

# Extract jar URL argument and download
for ((i=$#; i>0; i--)); do
	if [[ ${!i} == http* ]]; then
		echo "Downloading ${!i}"
		wget -O $job_path ${!i}
    submit_args="${@:1:((i-1))} $job_path ${@:((i+1))}"
    break
	fi
done

execution="$executable $submit_args"

echo "Submitting Spark job with: $execution"
exec $execution
