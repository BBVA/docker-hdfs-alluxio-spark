# Data

This folder contains scripts to manage data for test porpuses. It also contains scripts to manipulate HDFS and Alluxio filesystems from the command line, making use of their HTTP API.

* `httpfs.sh` allows to upload | rm | mkdir | ls | get files and directories inside HDFS.
* `alluxiofs.sh` allows to upload | rm | mkdir | ls | get | free | persist files and directories in Alluxio. The upload option also allows to distribute the files among all the worker nodes and persist the files to the underlying filesystem (HDFS). Use -h option for usage information.

* The other scripts were used for testing, and as ephemeral tools, and have been included for reference. Please read the scripts before usage, as they probably need to be adapted for your needs.


