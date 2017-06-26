# Spark-Alluxio-HDFS benchmarks

This folder contains a synthetic benchmark aimed to check performance of the cluster in several scenarios. It's based on [DFSIO](http://blog.unit1127.com/blog/2013/08/28/benchmarks/) benchmark for HDFS and adapted to work in this environment using Spark.

These benchmarks were run on an Openshift cluster with 7 worker nodes. Each worker stack was composed of a Spark worker instance, an Alluxio worker and an HDFS datanode. (TODO explain cluster capacity and topology)

Each datanode had replication factor configured to 3x.

## Scenarios

The scenarios are designed to write and read from/to alluxio in several configurations of caching and file size and number. The resources available for Spark are also taken into account to measure the effect of concurrency and paralelization. So far the benchmarks defined are the following:

* [TestDFSIO](./dfsio/README.md)

