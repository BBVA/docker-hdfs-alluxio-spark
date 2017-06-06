# Docker

This folder contains all the scripts used to bring up the whole thing in a docker installation under linux.

Please read them to use them. Feel free to complete this documentation.


# Benchmarks

To launch the benchmarks on local docker cluster you can use the following scripts:

*Write benchmark*
```sh
sudo ./run_write_benchmarks.sh ../../spark-benchmarks/dfsio/target/scala-2.11/spark-benchmarks-dfsio-0.1.0-with-dependencies.jar CACHE_THROUGH 2 200mb
```


*Read benchmark*
```sh
sudo ./run_read_benchmarks.sh ../../spark-benchmarks/dfsio/target/scala-2.11/spark-benchmarks-dfsio-0.1.0-with-dependencies.jar CACHE 2 200mb
```

**NOTE:** To run the benchmarks you need to create the folders `/spark/eventlogs`, `/jobs` and `/data`. You can use the following scripts from this folder changing the `HTTPFS` url with your local httpfs url:
```sh
export HTTPFS=http://172.18.0.5:14000

../data/httpfs.sh mkdir spark/eventlogs
../data/httpfs.sh mkdir jobs
../data/httpfs.sh mkdir data
```
