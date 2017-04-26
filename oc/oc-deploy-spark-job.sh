#!/usr/bin/env bash

source ../conf/hadoop.sh
source ../conf/alluxio.sh
source ../conf/spark.sh

export SUBMITTER_CONF_VARS="CORE_SITE_CONF HDFS_SITE_CONF ALLUXIO_CONF SPARK_CONF"
export SUBMITTER_CONF_FILES="/opt/spark/conf/core-site.xml /opt/spark/conf/hdfs-site.xml /opt/spark/conf/alluxio-site.properties /opt/spark/conf/spark-defaults.conf"

name="$1"
shift
args="$@"
submit_args="${args[@]}"

# basic project data
export project="has"

# Deploy Spark Job
export spark_submitter_image=$(oc get is/spark-submitter --template="{{ .status.dockerImageRepository }}" --namespace ${project})
oc process \
  -p IMAGE=${spark_submitter_image} \
  -p SUBMITTER_CONF_FILES="${SUBMITTER_CONF_FILES}" \
  -p SUBMITTER_CONF_VARS="${SUBMITTER_CONF_VARS}" \
  -p CORE_SITE_CONF="${CORE_SITE_CONF}" \
  -p HDFS_SITE_CONF="${HDFS_SITE_CONF}" \
  -p ALLUXIO_CONF="${ALLUXIO_CONF}" \
  -p SPARK_CONF="${SPARK_CONF}" \
  -p HADOOP_CONF_DIR="/opt/spark/conf" \
  -p NAME=${name} \
  -p SUBMIT_ARGS="${submit_args}" \
  -f "oc-deploy-spark-submitter.yaml" | oc create -f -
