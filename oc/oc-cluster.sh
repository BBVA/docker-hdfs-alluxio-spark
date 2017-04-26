#!/usr/bin/env bash

source ../conf/hadoop.sh
source ../conf/alluxio.sh
source ../conf/spark.sh



# basic project data
export project="has"
export repository="ssh://git@globaldevtools.bbva.com:7999/bglh/docker-hdfs-alluxio-spark.git"
export secretname="sshcert"
nodes=${1:-"7"}
# https://docs.openshift.org/latest/dev_guide/builds/build_inputs.html

# Create new oc project
oc new-project "${project}"

# Upload ssh key to access the git using ssh://
oc secrets new-sshauth ${secretname} --ssh-privatekey=$HOME/.ssh/id_rsa

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
oc process \
  -p IMAGE=${hdfs_image} \
  -p CONF_FILES="${HADOOP_CONF_FILES}" \
  -p CONF_VARS="${HADOOP_CONF_VARS}" \
  -p CORE_SITE_CONF="${CORE_SITE_CONF}" \
  -p HDFS_SITE_CONF="${HDFS_SITE_CONF}" \
  -p HTTPFS_HTTP_PORT="${HTTPFS_HTTP_PORT}" \
  -p HTTPFS_ADMIN_PORT="${HTTPFS_ADMIN_PORT}" \
  -f "oc-deploy-hdfs-namenode.yaml" | oc create -f -



# Deploy HDFS httpfs node
oc process \
  -p IMAGE=${hdfs_image} \
  -p CONF_FILES="${HADOOP_CONF_FILES}" \
  -p CONF_VARS="${HADOOP_CONF_VARS}" \
  -p CORE_SITE_CONF="${CORE_SITE_CONF}" \
  -p HDFS_SITE_CONF="${HDFS_SITE_CONF}" \
  -p HTTPFS_HTTP_PORT="${HTTPFS_HTTP_PORT}" \
  -p HTTPFS_ADMIN_PORT="${HTTPFS_ADMIN_PORT}" \
  -f "oc-deploy-hdfs-httpfs.yaml" | oc create -f -

# Deploy Alluxio master
export alluxio_image=$(oc get is/alluxio --template="{{ .status.dockerImageRepository }}" --namespace ${project})
oc process \
  -p IMAGE=${alluxio_image} \
  -p CONF_FILES="${ALLUXIO_CONF_FILES}" \
  -p CONF_VARS="${ALLUXIO_CONF_VARS}" \
  -p CORE_SITE_CONF="${CORE_SITE_CONF}" \
  -p HDFS_SITE_CONF="${HDFS_SITE_CONF}" \
  -p ALLUXIO_CONF="${ALLUXIO_CONF}" \
  -p ALLUXIO_WORKER_MEMORY_SIZE="${ALLUXIO_WORKER_MEMORY_SIZE}" \
  -p ALLUXIO_RAM_FOLDER="${ALLUXIO_RAM_FOLDER}" \
  -p ALLUXIO_UNDERFS_ADDRESS="${ALLUXIO_UNDERFS_ADDRESS}" \
  -p HADOOP_CONF_DIR="/opt/alluxio/conf" \
	-f "oc-deploy-alluxio-master.yaml" | oc create -f -


# Deploy Spark master
export spark_image=$(oc get is/spark --template="{{ .status.dockerImageRepository }}" --namespace ${project})
oc process \
  -p IMAGE=${spark_image} \
  -p CONF_FILES="${SPARK_CONF_FILES}" \
  -p CONF_VARS="${SPARK_CONF_VARS}" \
  -p CORE_SITE_CONF="${CORE_SITE_CONF}" \
  -p HDFS_SITE_CONF="${HDFS_SITE_CONF}" \
  -p SPARK_CONF="${SPARK_CONF}" \
  -p HADOOP_CONF_DIR="/opt/spark/conf" \
  -p SPARK_MASTER_WEBUI_PORT="${SPARK_MASTER_WEBUI_PORT}" \
  -p SPARK_WORKER_MEMORY="${SPARK_WORKER_MEMORY}" \
  -p SPARK_WORKER_PORT="${SPARK_WORKER_PORT}" \
  -p SPARK_WORKER_WEBUI_PORT="${SPARK_WORKER_WEBUI_PORT}" \
  -p SPARK_DAEMON_MEMORY="${SPARK_DAEMON_MEMORY}" \
	-f "oc-deploy-spark-master.yaml" | oc create -f -

# Deploy splark history server
oc process \
  -p IMAGE=${spark_image} \
  -p CONF_FILES="${SPARK_CONF_FILES}" \
  -p CONF_VARS="${SPARK_CONF_VARS}" \
  -p CORE_SITE_CONF="${CORE_SITE_CONF}" \
  -p HDFS_SITE_CONF="${HDFS_SITE_CONF}" \
  -p SPARK_CONF="${SPARK_CONF}" \
  -p HADOOP_CONF_DIR="/opt/spark/conf" \
  -f "oc-deploy-spark-history.yaml" | oc create -f -


# Deploy three workers
for id in $(seq 1 1 ${nodes}); do
    oc process -p ID=${id} \
      -p IMAGE_SPARK="${spark_image}" \
      -p IMAGE_ALLUXIO="${alluxio_image}" \
      -p IMAGE_HDFS="${hdfs_image}" \
      -p "HDFS_MEMORY=1GB" \
      -p HDFS_CONF_FILES="${HADOOP_CONF_FILES}" \
      -p HDFS_CONF_VARS="${HADOOP_CONF_VARS}" \
      -p CORE_SITE_CONF="${CORE_SITE_CONF}" \
      -p HDFS_SITE_CONF="${HDFS_SITE_CONF}" \
      -p HTTPFS_HTTP_PORT="${HTTPFS_HTTP_PORT}" \
      -p HTTPFS_ADMIN_PORT="${HTTPFS_ADMIN_PORT}" \
      -p ALLUXIO_CONF_FILES="${ALLUXIO_CONF_FILES}" \
      -p ALLUXIO_CONF_VARS="${ALLUXIO_CONF_VARS}" \
      -p ALLUXIO_CONF="${ALLUXIO_CONF}" \
      -p ALLUXIO_WORKER_MEMORY_SIZE="6GB" \
      -p ALLUXIO_RAM_FOLDER="${ALLUXIO_RAM_FOLDER}" \
      -p ALLUXIO_UNDERFS_ADDRESS="${ALLUXIO_UNDERFS_ADDRESS}" \
      -p ALLUXIO_HADOOP_CONF_DIR="/opt/alluxio/conf" \
      -p SPARK_HADOOP_CONF_DIR="/opt/spark/conf" \
      -p SPARK_CONF_FILES="${SPARK_CONF_FILES}" \
      -p SPARK_CONF_VARS="${SPARK_CONF_VARS}" \
      -p SPARK_CONF="${SPARK_CONF}" \
      -p SPARK_MASTER_WEBUI_PORT="${SPARK_MASTER_WEBUI_PORT}" \
      -p SPARK_WORKER_MEMORY="6GB" \
      -p SPARK_WORKER_PORT="${SPARK_WORKER_PORT}" \
      -p SPARK_WORKER_WEBUI_PORT="${SPARK_WORKER_WEBUI_PORT}" \
      -p SPARK_DAEMON_MEMORY="${SPARK_DAEMON_MEMORY}" \
    	-f "oc-deploy-has-node.yaml" | oc create -f -
done

# Deploy a Zeppelin client
export zeppelin_image=$(oc get is/zeppelin --template="{{ .status.dockerImageRepository }}" --namespace ${project})
oc process -p ID=0 \
	-p IMAGE=${zeppelin_image} \
	-f "oc-deploy-zeppelin.yaml" | oc create -f -

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
