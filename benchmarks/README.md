# Spark-Alluxio-HDFS benchmarks

These benchmarks have been run on an Openshift cluster with 7 workers. Each worker stack was composed of a Spark worker instance, an Alluxio
worker and a HDFS datanode. (TODO explain cluster capacity and topology)

Each datanode had replication factor configured to 3x.

1. [TestDFSIO](../dfsio/README.md)
