#!/usr/bin/env bash

source dfsio-hdfs.sh

size=${1:-"1gb"}

run_test() {
	local file_size=$1; shift
	local num_files=$1; shift
	local cores=$(echo ${num_files}/7 | bc)
	local total_cores=${num_files}

	dfsio_write "dfsio-hdfs-write-${num_files}-${file_size}" "${cores}" "${total_cores}" "${num_files}" "${file_size}"

	dfsio_wait_job "dfsio-hdfs-write-${num_files}-${file_size}"

	dfsio_read "dfsio-hdfs-read-${num_files}-${file_size}" "${cores}" "${total_cores}" "${num_files}" "${file_size}"

	dfsio_wait_job "dfsio-hdfs-read-${num_files}-${file_size}"

}

for n in $(seq 7 7 42); do
	run_test ${size} ${n}
	sleep 5
done
