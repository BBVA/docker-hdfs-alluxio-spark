# Zeppelin

Zeppelin is uncompressed in /opt/zeppelin.

The boot.sh accepts the following parameters:
```sh
boot.sh node_type action cluster_name
```

And the following environment variables for zeppelin configuration:
```sh
export ZEPPELIN_PORT=${ZEPPELIN_PORT:-8080}
export ZEPPELIN_NOTEBOOK_DIR=${ZEPPELIN_NOTEBOOK_DIR:-/data}
export ZEPPELIN_NOTEBOOK_PUBLIC=${ZEPPELIN_NOTEBOOK_PUBLIC:-false}
```

The default configuration for Zeppelin, Spark interpreter, Alluxio and HDFS can be found in `interpreter.json`, `spark-defaults.conf`, `alluxio-site.properties`, `hdfs-site.xml` and `core-site.xml` respectively.

**NOTE:**The interpreter needs to have the `spark/eventlogs` folder created in HDFS before the first job is executed or the interpreter will crash.

**NOTE: The current image includes its default configuration in the "interpreters.json" file. In order to run zeppelin jobs in a local environment (minishift), spark.executor.memory property must be set accordingly to the memory assigned to each worker, the default value is 1g if not modified.**

**Version 1.2.0 of alluxio is needed in order to work with the combination of libraries the version 0.7.1 of zeppelin ships by default. If you need a newer version, you will need to build your own zeppelin distribution and docker image**
