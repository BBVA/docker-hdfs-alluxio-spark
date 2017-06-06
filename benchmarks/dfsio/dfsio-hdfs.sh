#!/bin/bash

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
	local write_type="$1"; shift

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
	local read_type="$1"; shift

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
      --inputDir  hdfs://hdfs-namenode:8020/benchmarks/DFSIO
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
