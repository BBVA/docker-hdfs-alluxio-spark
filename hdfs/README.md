# hdfs

This image contains hadoop 2.7.3 distribution but its only used to bring up hdfs services. It is uncompressed in /opt/hadoop.

The HDFS configuration files are added to the Docker image on build time.

Be aware of the `dfs.namenode.datanode.registration.ip-hostname-check=false` property. As stated in [here](https://log.rowanto.com/why-datanode-is-denied-communication-with-namenode/), is needed if there is no inverse name resolution for data nodes in an HDFS set up.

Defaults are tested to work with docker and minishift.

## Local usage

You'll need a volume to store the data in /data inside the container. Create it in $PWD when using the provided scripts.

 * starts a single namenode to be used as hdfs service master namenode
    $ start_namenode.sh [namenode] [/tmp/data]
 * starts a data node to be used with the namenode already launched. Use it as many times as needed to bring up multiple datanodes.
    $ start_datanode.sh [namenode] [/tmp/data]

Shown params are optional and those are their default values.

namenode_fqdn is the hdfs namenode endpoint and must be resolvable by all the instances. The scripts work with regular dockers by linking the containers between them using the docker run command.
