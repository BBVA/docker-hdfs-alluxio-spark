# Spark Submitter

Contains the version of the complete spark 2.1.0 distribution with hdfs 2.7 build and default confiuration and scripts to run spark jobs on the cluster.

## How to run jobs
In the `oc` folder exists an script `oc-deploy-spark-job.sh` to run spark jobs on the cluster (external or minishift).

The script works like this:
```sh
bash oc-deploy-spark-job.sh <job_name> "[spark_parameters] <spark_job> [job_parameters]"
```

For the purpose of our tests and benchmarks we use the following parameters:
```sh
bash oc-deploy-spark-job.sh \
wordcount \                                         # Job name
"--master spark://spark-master:7077 \               # Spark master url
--class com.bbva.spark.WordCount \                  # Main class of the job
--driver-memory 512m \                              # Driver memory
--executor-memory 512m \                            # Executor memory
--packages org.alluxio:alluxio-core-client:1.4.0 \  # Alluxio client library
http://hdfs-httpfs:14000/webhdfs/v1/jobs/spark-wordcount.jar?op=OPEN&user.name=openshift \ # Spark job jar
-i alluxio://alluxio-master:19998/data/README.md \  # Job parameters
-o alluxio://alluxio-master:19998/data/README.md-copy"
```
