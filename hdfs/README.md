# hadfs

This image contains hadoop 2.7.3 distribution but its only used to bring up hdfs services.


# Usage

General usage:

You'll need a volume to store the data in /data inside the container.

sudo docker run -ti --rm 
	-v $PWD/data:/data 
	--name container_name 
	-h container_hostname 
	hdfs_image_name node_type action clustername

To run a name node in foreground:

sudo docker run -ti --rm -v $PWD/data:/data --name namenode -h namenode dhas namenode start namenode

To start a datanode:

sudo docker run -ti --rm -v $PWD/data:/data --name data0 -h data0 --link namenode dhas datanode start namenode

- datanode needs to resolve the namenode container name by DNS



