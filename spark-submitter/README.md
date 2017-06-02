# Spark Submitter

Contains the version of the complete spark 2.1.0 distribution with hdfs 2.7 build and default confiuration and scripts to run spark jobs on the cluster.

## How to run jobs



## Example

From this folder, run the following commands to create the wordcount job example using spark-submitter in a local minishift.

First export the following environment variables
```sh
export ALLUXIO_PROXY=http://alluxio-master-rest-has.192.168.42.42.nip.io
export HTTPFS=http://hdfs-httpfs-has.192.168.42.42.nip.io
export HUSER=openshift
export MINISHIFT=true
```
**NOTE:** Replace the `...192.168.42.42` segment with the appropiate ip where you have your local minishift. You can also find the full url by using the openshift ui. To do so, open your OpenShift web console and go to your project, in `Aplications/Routes` tab you will find all your applications routes.

Next we will create some folders we will need for our job:
```sh
../data/httpfs.sh mkdir spark/eventlogs
../data/httpfs.sh mkdir jobs
../data/httpfs.sh mkdir data
```

Then we upload our job and a sample file:
```sh
../data/httpfs.sh upload ../spark-wordcount/target/scala-2.11/spark-wordcount-1.0-with-dependencies.jar jobs/spark-wordcount.jar

../data/httpfs.sh upload ../README.md data/README.md
```

And finally, when all the previous steps are finished, we can launch our work, for that we have to move to the oc folder and then run the job:
```sh
cd ../oc

bash oc-deploy-spark-job.sh wordcount "--master spark://spark-master:7077 --class com.bbva.spark.WordCount --driver-memory 512m --executor-memory 512m --packages org.alluxio:alluxio-core-client:1.4.0 http://hdfs-httpfs:14000/webhdfs/v1/jobs/spark-wordcount.jar?op=OPEN&user.name=openshift -i alluxio://alluxio-master:19998/data/README.md -o alluxio://alluxio-master:19998/data/README.md-copy"
```
