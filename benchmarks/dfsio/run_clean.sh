#!/usr/bin/env bash

oc_dir=${OC_DIR:-"../../oc"}

job_name="${1:-"dfsio-clean"}"

cd $oc_dir

exec bash oc-deploy-spark-job.sh $job_name \
  --master spark://spark-master:7077 \
  --class com.bbva.spark.benchmarks.dfsio.TestDFSIO \
  --driver-memory 1g \
  --executor-memory 1g \
  --total-executor-cores 1 \
  --executor-cores 1 \
  --packages org.alluxio:alluxio-core-client:1.4.0 \
  "http://hdfs-httpfs:14000/webhdfs/v1/jobs/dfsio.jar?op=OPEN&user.name=openshift" \
  clean --outputDir  alluxio://alluxio-master:19998/benchmarks/DFSIO
