# Data

This folder contains scripts to download and extend datasets for test porpuses. It also contains 2 scripts to manipulate HDFS and Alluxio filesystems from the command line, making use of their HTTP API.

* `httpfs.sh` allows to upload | rm | mkdir | ls | get files and directories inside HDFS.
* `alluxiofs.sh` allows to upload | rm | mkdir | ls | get | free | persist files and directories in Alluxio. The opload option also allows to distribute the files among all the worker nodes and persist the files to the underlying filesystem (HDFS). Use -h option for usage information.
