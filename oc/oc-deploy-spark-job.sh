#!/usr/bin/env bash

name="$1"
submit_args="$2"

# basic project data
export project="has"

oc login -u developer

export spark_submitter_image=$(oc get is/spark-submitter --template="{{ .status.dockerImageRepository }}" --namespace ${project})
oc process -p IMAGE=${spark_submitter_image} -p STORAGE="1Gi" -p NAME=${name} -p SUBMIT_ARGS=${submit_args} -f "oc-deploy-spark-submitter.yaml" | oc create -f -
