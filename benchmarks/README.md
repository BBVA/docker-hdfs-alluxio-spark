# Spark-Alluxio-HDFS benchmarks

These benchmarks have been run on an Openshift cluster with 7 workers. Each worker stack was composed of a Spark worker instance, an Alluxio
worker and a HDFS datanode. (TODO explain cluster capacity and topology)

Each datanode had replication factor configured to 3x.

## List of scenarios

### Clean benchmarks

```bash
bash oc-deploy-spark-job.sh clean-dfsio \
--master spark://spark-master:7077 \
--class com.bbva.spark.benchmarks.dfsio.TestDFSIO \
--driver-memory 1g \
--executor-memory 1g \
--packages org.alluxio:alluxio-core-client:1.4.0 \
"http://hdfs-httpfs:14000/webhdfs/v1/jobs/dfsio.jar?op=OPEN&user.name=openshift" \
clean --outputDir  alluxio://alluxio-master:19998/benchmarks/DFSIO
```

### Write benchmarks

##### Number of files: 10. File size: 1gb. Write type: MUST_CACHE. Max. cores: 7

```bash
bash oc-deploy-spark-job.sh dfsio \
--master spark://spark-master:7077 \
--class com.bbva.spark.benchmarks.dfsio.TestDFSIO \
--total-executor-cores 7 \
--executor-cores 1 \
--driver-memory 1g \
--executor-memory 2g \
--conf spark.locality.wait=30s \
--conf 'spark.driver.extraJavaOptions=-Dalluxio.user.file.writetype.default=MUST_CACHE' \
--conf 'spark.executor.extraJavaOptions=-Dalluxio.user.file.writetype.default=MUST_CACHE' \
--packages org.alluxio:alluxio-core-client:1.4.0 \
"http://hdfs-httpfs:14000/webhdfs/v1/jobs/dfsio.jar?op=OPEN&user.name=openshift" \
write --numFiles 10 --fileSize 1gb --outputDir  alluxio://alluxio-master:19998/benchmarks/DFSIO
```
