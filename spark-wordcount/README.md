



bash oc-deploy-spark-job.sh dfsio --master spark://spark-master:7077 --class com.bbva.spark.benchmarks.dfsio.TestDFSIO --driver-memory 1g --executor-memory 2g --conf 'spark.driver.extraJavaOptions=-Dalluxio.user.file.writetype.default=CACHE_THROUGH' --conf 'spark.executor.extraJavaOptions=-Dalluxio.user.file.writetype.default=CACHE_THROUGH' --packages org.alluxio:alluxio-core-client:1.4.0 "http://hdfs-httpfs:14000/webhdfs/v1/jobs/dfsio.jar?op=OPEN&user.name=openshift" write --numFiles 10 --fileSize 100mb --outputDir  alluxio://alluxio-master:19998/benchmarks/DFSIO

bash oc-deploy-spark-job.sh dfsio --master spark://spark-master:7077 --class com.bbva.spark.benchmarks.dfsio.TestDFSIO --driver-memory 1g --executor-memory 2g --packages org.alluxio:alluxio-core-client:1.4.0 "http://hdfs-httpfs:14000/webhdfs/v1/jobs/dfsio.jar?op=OPEN&user.name=openshift" clean --outputDir  alluxio://alluxio-master:19998/benchmarks/DFSIO

bash oc-deploy-spark-job.sh dfsio --master spark://spark-master:7077 --class com.bbva.spark.benchmarks.dfsio.TestDFSIO --total-executor-cores 7 --executor-cores 1 --driver-memory 1g --executor-memory 2g --conf 'spark.driver.extraJavaOptions=-Dalluxio.user.file.writetype.default=CACHE_THROUGH' --conf 'spark.executor.extraJavaOptions=-Dalluxio.user.file.writetype.default=CACHE_THROUGH' --packages org.alluxio:alluxio-core-client:1.4.0 "http://hdfs-httpfs:14000/webhdfs/v1/jobs/dfsio.jar?op=OPEN&user.name=openshift" write --numFiles 10 --fileSize 1gb --outputDir  alluxio://alluxio-master:19998/benchmarks/DFSIO
