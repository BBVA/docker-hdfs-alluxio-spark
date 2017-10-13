#!/usr/bin/env bash

# Copyright 2017 Banco Bilbao Vizcaya Argentaria S.A.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

name="$1"
shift
args="$@"
submit_args="${args[@]}"

# basic project data
export project="spark"
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
