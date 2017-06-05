# Openshift
The folder `oc` contains all the openshift code to bring up the deployments, routers, persistent volumes, etc. for all the components of the system.

## Caveats
In order to support openshift, and its various possible configurations, we:
- do not modify /etc/hosts, /etc/passwd or /etc/groups. Use NSS-WRAPPER as stated in openshift docs as required by HDFS.
- do use Services abstraction in order to communicate workers and master. Every worker has a worker service, and every master has a master service.
- do not require any special configuration of openshift, or user with special privileges
- do require kubernetes v1.4 for the scheduling code to work. If you have kubernetes >1.4, that deployment code must be changed.
- do require every worker to be deployed to not share host with any other worker or master. This is needed to support host-nat-based SDN like flannel and others due to requirements of HDFS protocol.

The images are built inside openshift and expect a repository layout and file location inside the repository. Do not move the Docker files or the config files without updating the build code for openshift, or the process will fail. In any case, they may take some time to build depending on your internet connection.

The deployments might not be started automatically, so proceed to deploy manually when the images are ready.


## Local Environment
### Prerequisites
The general procedure to bring this up is:
- install virtualbox, kvm, xhype or other virtualization tool supported by docker-machine
- install docker-machine and the drivers you need for virtualbox, kvm, etc.
- install `minishift` command  and openshift cli `oc` command and put them in your path
- start a minishift cluster: `minishift start --vm-driver=virtualbox --cpus 4 --memory 10240 --disk-size 100G`

### Deployment
`oc-minishift.sh` deploys three workers with 512MB of RAM for alluxio and 512MB of RAM for spark workers,  this scenario expects a single VM minishift deployment. Using oc-minishift.sh removes all the volume and affinity/antiaffinity configuration to allow for a correct deployment of the cluster in a single node.


## Cluster Environment
The script `oc-cluster.sh` contains the deployment set up for a 10 node cluster with the following layout:
* 3 master nodes: HDFS Namenode, Alluxio Master, Spark Master and Zeppelin driver
* 7 worker nodes: each contains an HDFS datanode, Alluxio worker and Spark slave.

They are deployed with antiaffinity rules to avoid workers landing on master nodes and have more than 1 worker in a single node.

All nodes are comprised of 8 cores and 16GB of RAM, 6GB of RAM for Alluxio 6GB for Spark and 6 for HDFS. There is a a persistent volume claim of 500Gi for the whole cluster. The resource allocations must be tuned to support your installation.

Please read the yaml for current layout and further details.
