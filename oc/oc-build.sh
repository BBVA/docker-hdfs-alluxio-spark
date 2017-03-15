#!/usr/bin/env bash

# basic project data
export PROJECT="has"
export REPO="ssh://git@globaldevtools.bbva.com:7999/bglh/docker-hdfs-alluxio-spark.git"


# https://docs.openshift.org/latest/dev_guide/builds/build_inputs.html
oc login -u system:admin

oc create -f oc-pv-hp.yaml

oc login -u developer
# Create new oc project
oc new-project ${ṔROJECT}

# Upload ssh key to access the git using ssh://
oc secrets new-sshauth sshsecret --ssh-privatekey=$HOME/.ssh/id_rsa

# Create new build from the repo url for hdfs docker image
oc new-build ${REPO} --context-dir="hdfs" --name="has-hdfs" 

# set source secret, beware new-build --build-secrets is not 
# the same as source secret, and if set incorrectly, images
# couldn't be pushed to the internal registry. Lets OC handle those
# default secrets
oc set build-secret --source bc/has-hdfs sshsecret

# Same process for alluxio and spark images
oc new-build ${REPO} --context-dir="alluxio" --name="has-alluxio" 
oc set build-secret --source bc/has-alluxio sshsecret

oc new-build ${REPO} --context-dir="spark" --name="has-spark"
oc set build-secret --source bc/has-spark sshsecret

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


