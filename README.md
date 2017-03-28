# HDFS ALLUXIO SPARK ZEPELLIN

This repository contains the docker images and the Openshift code to bring up a a complete HASZ environment.

Please complete this document if you find errors or lack information. Just git push it! :)

# Local environment

Because this is using for development, tweaking images, etc. its recommended to be generous with the minishift parameters.

    minishift start --vm-driver=kvm --memory 10480 --cpus 4 --disk-size 100g

Docker images are optimized for development, and not for deployment, that is, images build fast, but require more disk space. The 20g of the the default vm minishift brings up becomes full in two or three builds. 

# Docker images

The folders called ```hdfs```, ```alluxio```, ```spark``` and ```zeppelin``` contain the Dockerfiles and boot.sh script for each container.

We tried to not make assumptions about the platform that will run this images, so they should work in a local docker installtion, kubernetes, openshift or whatever. Of course the programs from the images have certain communications and storage capabilities and **you MUST tailor them for your needs**.

Also you need to be familiar with HDFS, alluxio, spark and zepelling. Do not expect everything to work without reading first how those programs operate in a general way.

The images also are prepared for graceful shutdown of each component.

Finally, its important to note that an image could act as a different component, normaly master or worker of its software component.

# General boot.sh

In general, this script is composed of three sections:

 - environment set up and parameters parsing
 - handlers definition
 - starting code

All scripts accept similar general sintax:

    boot.sh type action name

Where ```type``` is the node type like namenode, master, worker, etc. ```action``` is start, stop, status, etc. and name is used as the master's name, either for set up or to join the cluster.

# HDFS image

Contains the version of the complete hadoop 2.7.3 distribution. It is uncompressed in /opt/haddop.

The boot.sh accepts the following parameters:

boot.sh node_type action cluster_name

And the following environment variables for hadoop configuration:

    CORE_SITE_CONF=(
        "property=value" < -- syntax reference only
        "fs.defaultFS=hdfs://hdfs-namenode:8020"
        "io.file.buffer.size=131072"
    )

    HDFS_SITE_CONF=(
        "property=value" < -- syntax reference only
        "dfs.namenode.name.dir=file:///data/hdfs-namenode/"
        "dfs.blocksize=268435456"
        "dfs.namenode.handler.count=100"
        "dfs.namenode.servicerpc-address=hdfs://hdfs-namenode:8022"
        "dfs.namenode.datanode.registration.ip-hostname-check=false"
    )

Be aware of the ```dfs.namenode.datanode.registration.ip-hostname-check=false``` property. As stated in [here](https://log.rowanto.com/why-datanode-is-denied-communication-with-namenode/), is needed if there is no inverse name resolution for data nodes in an HDFS set up.

Defaults are tested to be fine with docker and minishift.

# ALLUXIO image

Contains the version of the complete alluxio 1.4.0 distribution. It is uncompressed in /opt/alluxio.

The boot.sh accepts the following parameters:

boot.sh node_type action cluster_name

And the following environment variables for alluxio configuration:

    export ALLUXIO_WORKER_MEMORY_SIZE=${ALLUXIO_WORKER_MEMORY_SIZE:-"1024MB"}
    export ALLUXIO_RAM_FOLDER=${ALLUXIO_RAM_FOLDER:-"/mnt/ramdisk"}
    export ALLUXIO_UNDERFS_ADDRESS=${ALLUXIO_UNDERFS_ADDRESS:-"hdfs://hdfs-namenode:8020"}

If not set, you can see in that snipper the default values for each variable. More can be added by following the alluxio conifguration guideline.

# SPARK image

Contains the version of the complete spark 2.1.0 distribution with hdfs 2.7 build. It is uncompressed in /opt/spark.

The boot.sh accepts the following parameters:

boot.sh node_type action cluster_name

And the following environment variables for spark configuration:

    # WARNING: SPARK_MASTER_PORT is also defined by openshift to a value incompatible
    # so this value is harcoded.
    export SPARK_MASTER_PORT=7077
    export SPARK_MASTER_WEBUI_PORT=${SPARK_MASTER_WEBUI_PORT:-8080}

    export SPARK_WORKER_MEMORY=${SPARK_WORKER_MEMORY:-"1g"}
    export SPARK_WORKER_PORT=${SPARK_WORKER_PORT:-35000}
    export SPARK_WORKER_WEBUI_PORT=${SPARK_WORKER_WEBUI_PORT:-8081}

    export SPARK_DAEMON_MEMORY=${SPARK_DAEMON_MEMORY:-"1g"}

If not set, you can see in that snipper the default values for each variable. More can be added by following the spark conifguration guideline.

# ZEPPELIN image

Contains the version of the complete zeppelin 0.7.0 binary   distribution with all interpreters (~700MB). It is uncompressed in /opt/zeppelin.

The boot.sh accepts the following parameters:

boot.sh node_type action cluster_name

And the following environment variables for zeppelin configuration:

    export ZEPPELIN_PORT=${ZEPPELIN_PORT:-8080}
    export ZEPPELIN_NOTEBOOK_DIR=${ZEPPELIN_NOTEBOOK_DIR:-/data}
    export ZEPPELIN_NOTEBOOK_PUBLIC=${ZEPPELIN_NOTEBOOK_PUBLIC:-false}

In order for the spark interpreter to work with this set up, you need to make the following configurations once zeppelin is started. In the spark interpreter configuration, edit and add the following propertie, values:

    spark.driver.port, 51000
    spark.fileserver.port, 51100
    spark.broadcast.port, 51200
    spark.replClassServer.port, 51300
    spark.blockManager.port, 51400
    spark.executor.port, 51500
    spark.ui.port,4040
    alluxio.security.authentication.type, SIMPLE

Add the following artifact to connect to alluxio:
    org.alluxio:alluxio-core-client:1.2.0

**Version 1.2.0 of alluxio is needed in order to work with the combination of libraries the version 0.7.0 of zeppelin ships by default. If you need a newer version, you will need to build your own zeppelin distribution and docker image**

# sparky

This contains a Scala application that counts lines on a textFile given the apropriate alluxio url.

Read the source code, and try it like:

    sbt "runMain (sparky | AlluxioExperiment | CSVToParquet) --spark spark://spark-master-dashboard-has.192.168.99.100.nip.io --input alluxio://alluxio-master-dashboard-has.192.168.99.100.nip.io/README.txt [--output outputFile]"

To test it agains the minishift cluster.

# oc

This folder contains all the openshift code to bring up the deployments, routers, persistent volumes, etc. for all the components of the system.

The general procedure to bring this up is:

 - install virtualbox, kvm, xhype or other virtualization tool supported by docker-machine
 - install docker-machine and the drivers you need for virtualbox, kvm, etc.
 - install ```minishift``` command  and openshift cli ```oc``` command and put them in your path
 - stat a minishift cluster: ```minishift start --vm-driver=virtualbox --cpus 4 --memory 8192```
 - run bash oc-build.sh to bring up all the components

Please note that images are built in your minishift installation, it might take some time. Also The deployments might not be started automatically, so proceed to deploy manually when the images are ready.

## notes on data locality

Data locality is achieves by naming everything. All the components should be reachable by name, and that name needs to be also the hostname of the component.

To achieve this in openshift, several assumptions are made:
 - workers of hdfs, alluxio and spark run toghether on the same pod, sharing hostname and ip address
 - all workers have a openshift service of their own to be able to communicate with the rest of the cluster
 - the openshift service and the hostname of the pod must be equal
 - all the nodes that accept as a parameter its local name, shoud be set up that way using the FQDN, for example with the output of ```hostname -f```


# docker

This folder contains all the scripts used to bring up the whole thing in a docker installation under linux.

Please read them to use them. Feel free to complete this documentation.


# TODO

 * test new deployment option using PetSets / StatefulSets, reducing the services needed.
 * simplify the zeppelin configuration, it would be cool to automate it
 * test everything from the very begining and fix any issue
 * test more complex analisys to see if there are any networking issues
 * make the data upload process easier to the cluster
 * deploy on real cluster
