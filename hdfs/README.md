# HDFS

This image contains hadoop 2.7.3 distribution but its only used to bring up hdfs services. It is uncompressed in /opt/hadoop.

The HDFS configuration files are added to the Docker image on build time.

Be aware of the `dfs.namenode.datanode.registration.ip-hostname-check=false` property. As stated in [here](https://log.rowanto.com/why-datanode-is-denied-communication-with-namenode/), is needed if there is no inverse name resolution for data nodes in an HDFS set up. This is common in container based solutions!.

Defaults are tested to work with Docker, Minishift and Openshift 3.4.

To deploy HDFS into a local docker installation, please read the ```../docker/hdfs.sh``` script.

There are more configurations and tweaks in the configuration files. Please read them carefully before using this config files, specially the naming schemes of nodes.

