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

We tried to not make assumptions about the platform that will run this images, so they should work in a local docker installation, kubernetes, openshift or whatever. Of course the programs from the images have certain communications and storage requirements and **you MUST tailor them for your needs**.

Also you need to be familiar with HDFS, alluxio, spark and zepelling. Do not expect everything to work without reading first how those programs operate in a general way.

The images also are prepared for graceful shutdown of each component.

Finally, its important to note that an image could act as a different component, normally master or worker of its software component.

# General images information

## About boot.sh
In general, this script is composed of three sections:

 - environment set up and parameters parsing
 - handlers definition
 - starting code

All scripts accept similar general syntax:

```
boot.sh type action name
```

Where `type` is the node type like namenode, master, worker, etc. `action` is start, stop, status, etc. and name is used as the master's name, either for set up or to join the cluster.

## About dockerfiles
All Dockerfiles are based in the official ubuntu docker image, and contains the minimum commands required to run the software. Please, be aware that some tools might be lacking like ip utils, dns utils, etc. If you need to customize the image for debugging purposes, either modify the Dockerfile or compose your image from one of ours.

## About configurations
All components are configured using their correspondent configuration files which are included in the images at build time. There are no dynamic configuration tools or support for dynamic configuration storages like consul, etcd, S3, etc. So every time a change of config is needed, a new version of the image must be build.

Dockerfiles are layered for this purpose, so rebuild an image with a config change is cheap in space and time.

This approach ensures full compatibility with whatever system as far as it supports docker images.

## About data locality and pods
Data locality is achieved by naming everything. All the components should be reachable by name, and that name needs to be also the hostname of the component.

To achieve this in openshift, several assumptions are made:
 - workers of hdfs, alluxio and spark run together on the same pod, sharing hostname and ip address
 - all workers have an openshift service of their own to be able to communicate with the rest of the cluster
 - the openshift service and the hostname of the pod must be equal
 - all the nodes that accept as a parameter its local name, should be set up that way using the FQDN, for example with the output of `hostname -f`

Data locality is only achieved between all the components only when using PODs, as all the workers must share hostname in order to be aware of the data locality.

TODO: Testing in docker/swarm environment needs to be done to clarify data locality options on this environment.

# Docker images
Files for each image is contained in their own folder.  

## HDFS
Contains the version of the complete hadoop 2.7.3 distribution.

Documentation specific to this component can be found [here](hdfs/README.md).

## Alluxio
Contains the version of the complete alluxio 1.4.0 distribution. It is uncompressed in /opt/alluxio.

Documentation specific to this component can be found [here](alluxio/README.md).

## Spark
Contains the version of the complete spark 2.1.0 distribution with hdfs 2.7 build.

Documentation specific to this component can be found [here](spark/README.md).

## Zeppelin
Contains the version of the complete zeppelin 0.7.1 binary distribution with all interpreters (~700MB).

Documentation specific to this component can be found [here](zeppelin/README.md).

## Spark Submitter
TODO

Documentation specific to this component can be found [here](spark-submitter/README.md).

# Openshift
The folder `oc` contains all the openshift code to bring up the deployments, routers, persistent volumes, etc. for all the components of the system.

Documentation specific to this component can be found [here](oc/README.md).

# Data
This folder contains scripts to download and extend datasets for test porpuses. It also contains 2 scripts to manipulate HDFS and Alluxio filesystems from the command line, making use of their HTTP API.

Documentation specific to this component can be found [here](data/README.md).

# Benchmarks
This folder contains a synthetic benchmark aimed to check performance of the cluster in several scenarios. It's based on [DFSIO](http://blog.unit1127.com/blog/2013/08/28/benchmarks/) benchmark for HDFS and adapted to work in this environment using Spark.

Documentation specific to this component can be found [here](benchmarks/README.md).

# Docker
This folder contains all the scripts used to bring up the whole thing in a docker installation under linux.

Documentation specific to this component can be found [here](docker/README.md).


# TODO
 * test new deployment option using PetSets / StatefulSets, reducing the services needed.
 * simplify the zeppelin configuration, it would be cool to automate it
 * test everything from the very beginning and fix any issue
 * test more complex analysis to see if there are any networking issues
 * make the data upload process easier to the cluster
 * deploy on real cluster
