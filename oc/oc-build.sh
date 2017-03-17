#!/usr/bin/env bash




# basic project data
export project="has"
export repository="ssh://git@globaldevtools.bbva.com:7999/bglh/docker-hdfs-alluxio-spark.git"
export secretname="sshcert"

# https://docs.openshift.org/latest/dev_guide/builds/build_inputs.html
oc login -u system:admin

oc create -f oc-persistentvolume-hostpath.yaml

oc login -u developer
# Create new oc project
oc new-project "${project}"

# Upload ssh key to access the git using ssh://
oc secrets new-sshauth ${secretname} --ssh-privatekey=$HOME/.ssh/id_rsa



for c in "hdfs" "alluxio" "spark"; do
    oc process -v REPOSITORY=${repository} \
                -v CONTEXTDIR="${c}" \
                -v SECRETNAME="${secretname}" \
                -v ID="${c}" \
                -f oc-build-has.yaml | oc create -f -
done

set -e
 
image=$(oc get is/hdfs --template="{{ .status.dockerImageRepository }} --namespace ${project}")
oc process -v IMAGE=${image} -v STORAGE="1Gi" -f "oc-deploy-hdfs-namenode.yaml" | oc create -f -


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


