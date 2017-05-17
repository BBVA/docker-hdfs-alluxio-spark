# Spark-Alluxio-HDFS benchmarks

These benchmarks were run on an Openshift cluster with 7 worker nodes. Each worker stack was composed of a Spark worker instance, an Alluxio worker and an HDFS datanode. (TODO explain cluster capacity and topology)

Each datanode had replication factor configured to 3x.

## Benchmarks

1. [TestDFSIO](./dfsio/README.md)
