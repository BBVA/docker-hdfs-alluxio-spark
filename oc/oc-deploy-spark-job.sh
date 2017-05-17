#!/usr/bin/env bash

name="$1"
shift
args="$@"
submit_args="${args[@]}"

# basic project data
export project="has"
export spark_submitter_image=$(oc get is/spark-submitter --template="{{ .status.dockerImageRepository }}" --namespace ${project})

# Deploy Spark Job
if [ -z ${MINISHIFT+x} ]; then
    oc process \
    -p IMAGE=${spark_submitter_image} \
    -p NAME=${name} \
    -p SUBMIT_ARGS="${submit_args}" \
    -f "oc-deploy-spark-submitter.yaml" | oc create -f -
else
    ./remove_cluster_stuff.py oc-deploy-spark-submitter.yaml | oc process \
    -p IMAGE=${spark_submitter_image} \
    -p NAME=${name} \
    -p SUBMIT_ARGS="${submit_args}" \
    -f - | oc create -f -
fi
