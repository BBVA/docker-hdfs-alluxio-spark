#!/usr/bin/env bash

name="$1"
shift
args="$@"
submit_args="${args[@]}"

# basic project data
export project="has"

# Deploy Spark Job
export spark_submitter_image=$(oc get is/spark-submitter --template="{{ .status.dockerImageRepository }}" --namespace ${project})
./remove_affinity.py "oc-deploy-spark-submitter.yaml" | oc process \
  -p IMAGE=${spark_submitter_image} \
  -p NAME=${name} \
  -p SUBMIT_ARGS="${submit_args}" \
  -f - | oc create -f -
