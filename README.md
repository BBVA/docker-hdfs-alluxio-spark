# HDFS ALLUXIO SPARK ZEPELLIN

This repository contains the docker images and the Openshift code to bring up a a complete HASZ environment.

Please complete this document if you find errors or lack information. Just git push it! :)

# Local environment

Because this is used for development, tweaking images, etc. its recommended to be generous with the minishift parameters.

```sh
minishift start --vm-driver=kvm --memory 10480 --cpus 4 --disk-size 100g
```

Docker images are optimized for development, and not for deployment, that is, images build fast, but require more disk space. The 20g of the the default vm minishift brings up becomes full in two or three builds.

# Docker images

The folders called `hdfs`, `alluxio`, `spark` and `zeppelin` contain the Dockerfiles and boot.sh script for each container.

We tried to not make assumptions about the platform that will run this images, so they should work in a local docker installtion, kubernetes, openshift or whatever. Of course the programs from the images have certain communications and storage requirements and **you MUST tailor them for your needs**.

Also you need to be familiar with HDFS, alluxio, spark and zepelling. Do not expect everything to work without reading first how those programs operate in a general way.

The images also are prepared for graceful shutdown of each component.

Finally, its important to note that an image could act as a different component, normaly master or worker of its software component.

# General images information

## about boot.sh

In general, this script is composed of three sections:

 - environment set up and parameters parsing
 - handlers definition
 - starting code

All scripts accept similar general sintax:

```
boot.sh type action name
```

Where `type` is the node type like namenode, master, worker, etc. `action` is start, stop, status, etc. and name is used as the master's name, either for set up or to join the cluster.

## about dockerfiles

All Dockerfiles are based in the official ubuntu docker image, and contains the minimum commands required to run the software. Please, be aware that some tools might be lacking like ip utils, dns utils, etc. If you need to customize the image for debbuging purposes, either modify the Dockerfile or compose your image from one of ours.

## about configurations

All components are configured using their correspondant configuration files which are included in the images at build time. There are no dynamic configuration tools or support for dynamic configuration storages like consul, etcd, S3, etc. So everytime a change of config is needed, a new version of the image must be build.

Dockerfiles are layed for this purpose, so rebuild an image with a config change is cheap in space and time.

This approach ensures full compatibility with whatever system as far as it supports docker images.

## about data locality and pods

Data locality is achieved by naming everything. All the components should be reachable by name, and that name needs to be also the hostname of the component.

To achieve this in openshift, several assumptions are made:
 - workers of hdfs, alluxio and spark run toghether on the same pod, sharing hostname and ip address
 - all workers have an openshift service of their own to be able to communicate with the rest of the cluster
 - the openshift service and the hostname of the pod must be equal
 - all the nodes that accept as a parameter its local name, shoud be set up that way using the FQDN, for example with the output of `hostname -f`

Data locality is only achieved between all the components only when using PODs, as all the workers must share hostname in order to be aware of the data locality.

TODO: Testing in docker/swarm environment needs to be done to clarify data locality options on this environment.

# Docker images

## HDFS image

Contains the version of the complete hadoop 2.7.3 distribution. It is uncompressed in /opt/haddop.

The boot.sh accepts the following parameters:

boot.sh node_type action cluster_name

The HDFS configuration files are added to the Docker image on build time.

Be aware of the `dfs.namenode.datanode.registration.ip-hostname-check=false` property. As stated in [here](https://log.rowanto.com/why-datanode-is-denied-communication-with-namenode/), is needed if there is no inverse name resolution for data nodes in an HDFS set up.

Defaults are tested to work with docker and minishift.

## ALLUXIO image

Contains the version of the complete alluxio 1.4.0 distribution. It is uncompressed in /opt/alluxio.

The boot.sh accepts the following parameters:

boot.sh node_type action cluster_name

And the following environment variables for alluxio configuration:

```sh
    export ALLUXIO_WORKER_MEMORY_SIZE=${ALLUXIO_WORKER_MEMORY_SIZE:-"1024MB"}
    export ALLUXIO_RAM_FOLDER=${ALLUXIO_RAM_FOLDER:-"/mnt/ramdisk"}
    export ALLUXIO_UNDERFS_ADDRESS=${ALLUXIO_UNDERFS_ADDRESS:-"hdfs://hdfs-namenode:8020"}
```

If not set, you can see in that snippet the default values for each variable. More can be added by following the alluxio conifguration guideline.

## SPARK image

Contains the version of the complete spark 2.1.0 distribution with hdfs 2.7 build. It is uncompressed in /opt/spark.

The boot.sh accepts the following parameters:

boot.sh node_type action cluster_name

Most of the configuration is on the spark-defaults.conf file added to the Docker image. But please consider configuring your executors with the following parameters:

```sh
--master spark://spark-master:7077 \
--class com.bbva.spark.benchmarks.dfsio.TestDFSIO \
--total-executor-cores $total_executor_cores \
--executor-cores $executor_cores \
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

## ZEPPELIN image

Contains the version of the complete zeppelin 0.7.0 binary   distribution with all interpreters (~700MB). It is uncompressed in /opt/zeppelin.

The boot.sh accepts the following parameters:

boot.sh node_type action cluster_name

And the following environment variables for zeppelin configuration:
```sh
export ZEPPELIN_PORT=${ZEPPELIN_PORT:-8080}
export ZEPPELIN_NOTEBOOK_DIR=${ZEPPELIN_NOTEBOOK_DIR:-/data}
export ZEPPELIN_NOTEBOOK_PUBLIC=${ZEPPELIN_NOTEBOOK_PUBLIC:-false}
```

In order for the spark interpreter to work with this set up, you need to make the following configurations once zeppelin is started. In the spark interpreter configuration, edit and add the following propertie, values:
```
spark.driver.port, 51000
spark.fileserver.port, 51100
spark.broadcast.port, 51200
spark.replClassServer.port, 51300
spark.blockManager.port, 51400
spark.executor.port, 51500
spark.ui.port,4040
alluxio.security.authentication.type, SIMPLE
```

Modify the following properties:
```
zeppelin.spark.useHiveContext, false
master, spark://spark-master:7077
```   

Add the following artifact to connect to alluxio:
```
org.alluxio:alluxio-core-client:1.2.0
```

**NOTE: The current image includes all previous parameters by default in the "interpreters.json" file. In order to run zeppelin jobs in local (minishift), spark.executor.memory property must be set to 512m or less (less than the available memory for the workers), default value is 1g.**

**Version 1.2.0 of alluxio is needed in order to work with the combination of libraries the version 0.7.0 of zeppelin ships by default. If you need a newer version, you will need to build your own zeppelin distribution and docker image**

# Openshift

The folder `oc` contains all the templates and scripts to deploy and work these tools in an openshift cluster.

There are some peculiarities to take into account:

- In order to support openshift, and its various possible configurations, we:
  - do not modify /etc/hosts, /etc/passwd or /etc/groups. Use NSS-WRAPPER as stated in openshift docs as required by HDFS.
  - do use Services abstraction in order to communicate workers and master. Every worker has a worker service, and every master has a master service.
  - do not require any special configuration of openshift, or user with special privileges
  - do require kubernetes v1.4 for the scheduling code to work. If you have kuerbenets >1.4, that deployment code must be changed.
  - do require every worker to be deployed to not share host with any other worker or master. This is needed to support host-nat-based SDN like flannel and others due to requirements of HDFS protocol.

The script `oc-cluster.sh` contains the deployment set up for a 10 node cluster with 16GB of ram on each node and a persistent volume claim of 500Gi accross the cluster. The resource allocations must be tuned to support your installation. Meanwhile the script `oc-minishit.sh` contains the code to deploy the system in a local instance of minishift, set up as stated.

The images are build inside openshift and expect a repository layout like this one. Do not move the Docker files or the config files without updating the build code for openshift, or the process will fail.

# oc

This folder contains all the openshift code to bring up the deployments, routers, persistent volumes, etc. for all the components of the system.

The general procedure to bring this up is:

 - install virtualbox, kvm, xhype or other virtualization tool supported by docker-machine
 - install docker-machine and the drivers you need for virtualbox, kvm, etc.
 - install `minishift` command  and openshift cli `oc` command and put them in your path
 - start a minishift cluster: `minishift start --vm-driver=virtualbox --cpus 4 --memory 10240 --disk-size 100G`
 - run bash oc-build.sh to bring up all the components

Please note that images are built in your minishift installation, it might take some time. Also The deployments might not be started automatically, so proceed to deploy manually when the images are ready.

`oc-cluster.sh` is used to deploy a production-grade cluster, 7 workers, and 3 masters, with antiaffinity rules, also with 6GB of RAM for alluxio workers and 6GB of RAM for spark workers. Please read the yaml for current layout and futher details. On the other hand,  `oc-minishift.sh` deploys three workers with 512MB of RAM for alluxio and 512MB of RAM for spark workers,  this scenario expects a single VM minishift deployment. Using oc-minishift.sh removes all the volume and affinity/antiaffinity configuration to allow for a correct deployment of the cluster in a single node.

# Data

This folder contains scripts to download and extend datasets for test porpuses. It also contains 2 scripts to manipulate HDFS and Alluxio filesystems from the command line, making use of their HTTP API.

* `httpfs.sh` allows to upload | rm | mkdir | ls | get files and directories inside HDFS.
* `alluxiofs.sh` allows to upload | rm | mkdir | ls | get | free | persist files and directories in Alluxio. The opload option also allows to distribute the files among all the worker nodes and persist the files to the underlying filesystem (HDFS).

# Benchmarks

This folder contains a synthetic benchmark aimed to check performance of the cluster in several scenarios. It's based on [DFSIO](http://blog.unit1127.com/blog/2013/08/28/benchmarks/) benchmark for HDFS and adapted to work in this environment using Spark.

## Scenarios

The scenarios are designed to write and read from/to alluxio in several configurations of caching and file size and number. The resources available for Spark are also taken into account to measure the effect of concurrency and paralelization. So far the benchmarks defined are the following:

* Write files of 1GB into Alluxio using write-type `CACHE_TRHOUGH` to HDFS. Read the same files from Alluxio using readtype `CACHE`.

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
