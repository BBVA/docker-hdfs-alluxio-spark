# Alluxio

Alluxio distribution is uncompressed in /opt/alluxio.

The boot.sh accepts the following parameters:

```sh
boot.sh node_type action cluster_name
```

And the following environment variables for alluxio configuration:

```sh
    export ALLUXIO_WORKER_MEMORY_SIZE=${ALLUXIO_WORKER_MEMORY_SIZE:-"1024MB"}
    export ALLUXIO_RAM_FOLDER=${ALLUXIO_RAM_FOLDER:-"/mnt/ramdisk"}
    export ALLUXIO_UNDERFS_ADDRESS=${ALLUXIO_UNDERFS_ADDRESS:-"hdfs://hdfs-namenode:8020"}
```

If not set, you can see in that snippet the default values for each variable. More can be added by following the alluxio configuration guideline.
