#!/usr/bin/env bash

source dfsio-hdfs.sh

size=${1:-"1gb"}

run_test() {
	local file_size=$1; shift
	local num_files=$1; shift
	local write_cache=$1; l_write_cache=$(echo $write_cache | tr A-Z a-z | sed 's/_/-/g'); shift
	local read_cache=$1; l_read_cache=$(echo $read_cache | tr A-Z a-z | sed 's/_/-/g'); shift
	local cores=$(echo ${num_files}/7 | bc)
	local total_cores=${num_files}

	dfsio_write "dfsio-hdfs-write-${l_read_cache}-${l_write_cache}-${num_files}-${file_size}" "${cores}" "${total_cores}" "${num_files}" "${file_size}" "${write_cache}"

	dfsio_wait_job "dfsio-hdfs-write-${l_read_cache}-${l_write_cache}-${num_files}-${file_size}"

	dfsio_read "dfsio-hdfs-read-${l_read_cache}-${l_write_cache}-${num_files}-${file_size}" "${cores}" "${total_cores}" "${num_files}" "${file_size}" "${read_cache}"

	dfsio_wait_job "dfsio-hdfs-read-${l_read_cache}-${l_write_cache}-${num_files}-${file_size}"

}


write_cache=("CACHE_THROUGH" "THROUGH")
read_cache=("CACHE" "NO_CACHE")

for wc in ${write_cache[@]}; do
	for rc in ${read_cache[@]}; do
		for n in $(seq 7 7 42); do
			run_test ${size} ${n} ${wc} ${rc}
			sleep 5
		done
	done
done
