#!/bin/bash

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

oc_dir=${OC_DIR:-"../../oc"}

function dfsio_wait_job() {
	local job_name="$1"; shift
	echo checking $job_name
	sleep 5
	while [ $? -eq 0 ]; do
		sleep 5
		oc get jobs  --template "{{range .items}}{{ if .status.active }}busy{{ end }}{{ end }}" | grep -q busy
	done
}

function dfsio_write() {
	local job_name="$1"; shift
	local cores="$1"; shift
	local total_cores="$1"; shift
	local num_files="$1"; shift
	local file_size="$1"; shift

	pushd $oc_dir
		bash oc-deploy-spark-job.sh $job_name \
			--master spark://spark-master:7077 \
			--class com.bbva.spark.benchmarks.dfsio.TestDFSIO \
			--total-executor-cores $total_cores \
			--executor-cores $cores \
			--driver-memory 1g \
			--executor-memory 1g \
			--conf spark.locality.wait=30s \
			"http://hdfs-httpfs:14000/webhdfs/v1/jobs/dfsio.jar?op=OPEN&user.name=openshift" \
			write \
      --numFiles $num_files \
      --fileSize $file_size \
      --outputDir hdfs://hdfs-namenode:8020/benchmarks/DFSIO \
      --hadoopProps fs.defaultFS=hdfs://hdfs-namenode:8020
	popd
}

function dfsio_read() {
	local job_name="$1"; shift
	local cores="$1"; shift
	local total_cores="$1"; shift
	local num_files="$1"; shift
	local file_size="$1"; shift

	pushd $oc_dir
		bash oc-deploy-spark-job.sh $job_name \
			--master spark://spark-master:7077 \
			--class com.bbva.spark.benchmarks.dfsio.TestDFSIO \
			--total-executor-cores $total_cores \
			--executor-cores $cores \
			--driver-memory 1g \
			--executor-memory 1g \
			--conf spark.locality.wait=30s \
			"http://hdfs-httpfs:14000/webhdfs/v1/jobs/dfsio.jar?op=OPEN&user.name=openshift" \
			read \
      --numFiles $num_files \
      --fileSize $file_size \
      --inputDir  hdfs://hdfs-namenode:8020/benchmarks/DFSIO \
      --hadoopProps fs.defaultFS=hdfs://hdfs-namenode:8020
	popd
}

function dfsio_clean() {
	local job_name="${1:-"dfsio-clean"}"

	pushd $oc_dir
		bash oc-deploy-spark-job.sh $job_name \
			--master spark://spark-master:7077 \
			--class com.bbva.spark.benchmarks.dfsio.TestDFSIO \
			--driver-memory 1g \
			--executor-memory 1g \
			--total-executor-cores 1 \
			--executor-cores 1 \
			"http://hdfs-httpfs:14000/webhdfs/v1/jobs/dfsio.jar?op=OPEN&user.name=openshift" \
			clean \
      --outputDir hdfs://hdfs-namenode:8020/benchmarks/DFSIO \
      --hadoopProps fs.defaultFS=hdfs://hdfs-namenode:8020
		popd
}
