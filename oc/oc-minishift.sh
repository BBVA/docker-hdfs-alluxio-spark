#!/usr/bin/env bash

# basic project data
export project="has"
export repository="https://github.com/BBVA/docker-hdfs-alluxio-spark.git"
#export secretname="sshcert"

nodes=${1:-"3"}
# https://docs.openshift.org/laremove_cluster_stuff/dev_guide/builds/build_inputs.html

# Create new oc project
oc new-project "${project}"

# Upload ssh key to access the git using ssh://
#oc secrets new-sshauth ${secretname} --ssh-privatekey=$HOME/.ssh/id_rsa

# Create builds for each docker image
for c in "hdfs" "alluxio" "spark" "spark-submitter" "zeppelin"; do
	oc process -p REPOSITORY=${repository} \
		-p CONTEXTDIR="${c}" \
		-p SECRETNAME="${secretname}" \
		-p ID="${c}" \
		-f oc-build-has.yaml | oc create -f -
done

# Deploy HDFS namenode
export hdfs_image=$(oc get is/hdfs --template="{{ .status.dockerImageRepository }}" --namespace ${project})
./remove_cluster_stuff.py "oc-deploy-hdfs-namenode.yaml" | oc process \
	-p IMAGE=${hdfs_image} \
	-f - | oc create -f -

# Deploy HDFS httpfs node
./remove_cluster_stuff.py "oc-deploy-hdfs-httpfs.yaml" | oc process \
	-p IMAGE=${hdfs_image} \
	-f - | oc create -f -

# Deploy Alluxio master
export alluxio_image=$(oc get is/alluxio --template="{{ .status.dockerImageRepository }}" --namespace ${project})
./remove_cluster_stuff.py "oc-deploy-alluxio-master.yaml" | oc process \
	-p IMAGE=${alluxio_image} \
	-p ALLUXIO_WORKER_MEMORY_SIZE="512MB" \
	-f - | oc create -f -

# Deploy Spark master
export spark_image=$(oc get is/spark --template="{{ .status.dockerImageRepository }}" --namespace ${project})
./remove_cluster_stuff.py "oc-deploy-spark-master.yaml" | oc process \
	-p IMAGE=${spark_image} \
	-p SPARK_MASTER_WEBUI_PORT="8080" \
	-p SPARK_WORKER_MEMORY="512M" \
	-p SPARK_WORKER_PORT="35000" \
	-p SPARK_WORKER_WEBUI_PORT="8081" \
	-p SPARK_DAEMON_MEMORY="512M" \
	-f - | oc create -f -

  # Deploy splark history server
./remove_cluster_stuff.py "oc-deploy-spark-history.yaml" | oc process \
	-p IMAGE=${spark_image} \
	-f - | oc create -f -


# Deploy workers
for id in $(seq 1 1 ${nodes}); do
	./remove_cluster_stuff.py "oc-deploy-has-node.yaml" | oc process -p ID=${id} \
		-p IMAGE_SPARK="${spark_image}" \
		-p IMAGE_ALLUXIO="${alluxio_image}" \
		-p IMAGE_HDFS="${hdfs_image}" \
		-p "HDFS_MEMORY=512M" \
		-p ALLUXIO_WORKER_MEMORY_SIZE="512MB" \
		-p SPARK_MASTER_WEBUI_PORT="8080" \
		-p SPARK_WORKER_MEMORY="512M" \
		-p SPARK_WORKER_PORT="35000" \
		-p SPARK_WORKER_WEBUI_PORT="8081" \
		-p SPARK_DAEMON_MEMORY="512M" \
		-f - | oc create -f -
done

# Deploy a Zeppelin client
export zeppelin_image=$(oc get is/zeppelin --template="{{ .status.dockerImageRepository }}" --namespace ${project})
./remove_cluster_stuff.py "oc-deploy-zeppelin.yaml" | oc process -p ID=0 \
	-p IMAGE=${zeppelin_image} \
	-p SPARK_EXECUTOR_MEMORY="512M" \
  -p SPARK_APP_NAME="ZeppelinMinishift" \
  -p SPARK_CORES_MAX="1" \
	-f - | oc create -f -

# HDFS ports
# MASTER 8020, 8022, 50070,
# SLAVES 50010, 50075, 50020

# ALLUXIO ports
# MASTER 19999, 19998
# SLAVES 29998, 29999, 30000

# SPARK ports
# MASTER 7077, 6066, 8080
# SLAVE 35000, 8081
# DRIVER 51000-51016, 51100,51116, 51200-51216, 51300-51316, 51400-51416, 51500-51516,51600-51616
