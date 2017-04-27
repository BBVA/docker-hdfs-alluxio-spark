# hdfs

This image contains hadoop 2.7.3 distribution but its only used to bring up hdfs services.

# Local usage

You'll need a volume to store the data in /data inside the container. Create it in $PWD when using the provided scripts. 

 * starts a single namenode to be used as hdfs service master namenode
    $ start_namenode.sh [namenode] [/tmp/data]
 * starts a data node to be used with the namenode already launched. Use it as many times as needed to bring up multiple datanodes.
    $ start_datanode.sh [namenode] [/tmp/data]

Shown params are optional and those are their default values.

namenode_fqdn is the hdfs namenode endpoint and must be resolvable by all the instances. The scripts work with regular dockers by linking the containers between them using the docker run command.

