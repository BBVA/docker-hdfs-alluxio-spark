#!/usr/bin/env bash

export SPARK_HOME=/opt/spark

executable=$SPARK_HOME/bin/spark-submit
job_args=
submit_args="$@"

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

if [ -n "$JOB_JAR_URL" ]; then
  wget -O /spark-job.jar JOB_JAR_URL
	job_args="$job_args /spark-job.jar"
fi

if [ -n "$JOB_JAR_ARGS" ]; then
	job_args="$job_args JOB_JAR_ARGS"
fi

execution="$executable $submit_args $job_args"

echo "Submitting Spark job with: $execution"
exec $execution
