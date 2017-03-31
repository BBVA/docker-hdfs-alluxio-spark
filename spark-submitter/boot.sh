#!/usr/bin/env bash

export SPARK_HOME=/opt/spark

executable=$SPARK_HOME/bin/spark-submit
job_path=/tmp/spark-job.jar
job_args=""
submit_args=("$@")

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
for ((i=${#submit_args[@]}; i>0; i--)); do
	if [[ ${submit_args[$i-1]} == http://* ]]; then
		echo "Downloading ${!i-1}"
		wget -O $job_path ${!i-1}
		chmod a+r $job_path
    submit_args="${submit_args[@]:0:(($i))} $job_path ${submit_args[@]:(($i))}"
    break
	fi
done

execution="$executable $submit_args"

echo "Submitting Spark job with: $execution"
exec $execution
