# Spark

This image contains Spark 2.1.0 distribution is uncompressed in /opt/spark.

In this folder there are a copy of the HDFS and Alluxio configuration files. This is done as a conveniencie to build the docker image, but beaware that these needs to match the ones deployed with HDFS.

Spark is also configured using a configuration file ```spark-defaults.conf``` which is added to the image at build time.


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
If not set, you can see in that snippet the default values for each variable. More can be added by following the Spark conifguration guideline [here](https://spark.apache.org/docs/latest/configuration.html).

