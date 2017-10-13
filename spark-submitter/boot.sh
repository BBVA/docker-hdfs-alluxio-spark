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

sleep 3

export SPARK_HOME=/opt/spark
export SPARK_CONF_DIR=${SPARK_HOME}/conf
export ALLUXIO_HOME=${SPARK_HOME}
export HADOOP_CONF_DIR=/opt/spark/conf

executable=$SPARK_HOME/bin/spark-submit
job_path=/tmp/spark-job.jar
job_args=""
submit_args=($@)

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
for ((i=${#submit_args[@]+1}; i>0; i--)); do
	if [[ ${submit_args[$i]} == http://* ]]; then
		echo "Downloading ${submit_args[i]}"
		wget -O $job_path ${submit_args[i]}
		chmod a+r $job_path
    submit_args="${submit_args[@]:0:(($i))} $job_path ${submit_args[@]:(($i+1))}"
    break
	fi
done

execution="$executable $submit_args"

echo "Submitting Spark job with: $execution"
exec $execution
