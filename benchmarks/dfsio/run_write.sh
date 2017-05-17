#!/usr/bin/env bash

oc_dir=${OC_DIR:-"../../oc"}

write_type="$1"
num_files="$2"
file_size="$3"

job_name=$(echo "dfsio-write-${read_type}-${num_files}-${file_size}" | sed "s/_/-/g" | tr A-Z a-z)

executor_cores="1"
total_executor_cores="7"

cd $oc_dir

exec bash oc-deploy-spark-job.sh $job_name \
  --master spark://spark-master:7077 \
  --class com.bbva.spark.benchmarks.dfsio.TestDFSIO \
  --total-executor-cores $total_executor_cores \
  --executor-cores $executor_cores \
  --driver-memory 1g \
  --executor-memory 1g \
  --conf spark.locality.wait=30s \
  --conf spark.driver.extraJavaOptions=-Dalluxio.user.file.writetype.default=$write_type \
  --conf spark.executor.extraJavaOptions=-Dalluxio.user.file.writetype.default=$write_type \
  --packages org.alluxio:alluxio-core-client:1.4.0 \
  "http://hdfs-httpfs:14000/webhdfs/v1/jobs/dfsio.jar?op=OPEN&user.name=openshift" \
  write --numFiles $num_files --fileSize $file_size --outputDir  alluxio://alluxio-master:19998/benchmarks/DFSIO
