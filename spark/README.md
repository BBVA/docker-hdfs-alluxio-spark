# Spark

Spark distribution is uncompressed in /opt/spark.

The boot.sh accepts the following parameters:

```sh
boot.sh node_type action cluster_name
```

Most of the configuration is on the spark-defaults.conf file added to the Docker image. But please consider configuring your executors with the following parameters:

```sh
--master spark://spark-master:7077 \
--class com.bbva.spark.benchmarks.dfsio.TestDFSIO \
--total-executor-cores $total_executor_cores \
--executor-cores $executor_cores_per_executor \
--driver-memory 1g \
--executor-memory 1g \
--conf spark.locality.wait=30s \
--conf spark.driver.extraJavaOptions=-Dalluxio.user.file.writetype.default=$write_type \
--conf spark.executor.extraJavaOptions=-Dalluxio.user.file.writetype.default=$write_type \
--conf spark.driver.extraJavaOptions=-Dalluxio.user.file.readtype.default=$read_type \
--conf spark.executor.extraJavaOptions=-Dalluxio.user.file.readtype.default=$read_type \
--packages org.alluxio:alluxio-core-client:1.4.0 \
```
If not set, you can see in that snippet the default values for each variable. More can be added by following the spark conifguration guideline.
