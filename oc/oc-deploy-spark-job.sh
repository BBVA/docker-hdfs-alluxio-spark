#!/usr/bin/env bash

name="$1"
shift
args="$@"
submit_args="${args[@]}"

# basic project data
export project="has"

export spark_submitter_image=$(oc get is/spark-submitter --template="{{ .status.dockerImageRepository }}" --namespace ${project})
oc process -p IMAGE=${spark_submitter_image} -p NAME=${name} -p SUBMIT_ARGS="${submit_args}" -f "oc-deploy-spark-submitter.yaml" | oc create -f -
