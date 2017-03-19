#!/usr/bin/env bash




# basic project data
export project="has"
export repository="ssh://git@globaldevtools.bbva.com:7999/bglh/docker-hdfs-alluxio-spark.git"
export secretname="sshcert"

# https://docs.openshift.org/latest/dev_guide/builds/build_inputs.html
oc login -u system:admin

# Create persisten volumes
oc process -f  oc-persistentvolume-hostpath.yaml | oc create -f -

oc login -u developer

# Create new oc project
oc new-project "${project}"

# Upload ssh key to access the git using ssh://
oc secrets new-sshauth ${secretname} --ssh-privatekey=$HOME/.ssh/id_rsa

# Create builds for each docker image
for c in "hdfs" "alluxio" "spark"; do
    oc process -v REPOSITORY=${repository} \
                -v CONTEXTDIR="${c}" \
                -v SECRETNAME="${secretname}" \
                -v ID="${c}" \
                -f oc-build-has.yaml | oc create -f -
done
 
 # Deploy HDFS namenode 
export hdfs_image=$(oc get is/hdfs --template="{{ .status.dockerImageRepository }}" --namespace ${project})
oc process -v IMAGE=${hdfs_image} -v STORAGE="1Gi" -f "oc-deploy-hdfs-namenode.yaml" | oc create -f -


# Deploy Alluxio master
export alluxio_image=$(oc get is/alluxio --template="{{ .status.dockerImageRepository }}" --namespace ${project})
oc process -v IMAGE=${alluxio_image} -v STORAGE="1Gi" -f "oc-deploy-alluxio-master.yaml" | oc create -f -


# Deploy Spark master
export spark_image=$(oc get is/spark --template="{{ .status.dockerImageRepository }}" --namespace ${project})
oc process -v IMAGE=${spark_image} -v STORAGE="1Gi" -f "oc-deploy-spark-master.yaml" | oc create -f -

# Deploy a single worker 0
oc process -v ID=0 -v IMAGE_SPARK="${spark_image}" -v IMAGE_ALLUXIO="${alluxio_image}" -v IMAGE_HDFS="${hdfs_image}" -v STORAGE="1Gi" -f "oc-deploy-has-node.yaml" | oc create -f -

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


