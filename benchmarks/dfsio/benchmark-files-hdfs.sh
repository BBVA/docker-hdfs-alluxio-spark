#!/usr/bin/env bash

source dfsio-hdfs.sh

run_test() {
	local file_size=$1; shift
	local num_files=$1; shift
	local write_cache=$1; l_write_cache=$(echo $write_cache | tr A-Z a-z | sed 's/_/-/g'); shift
	local read_cache=$1; l_read_cache=$(echo $read_cache | tr A-Z a-z | sed 's/_/-/g'); shift
	local cores=$(echo ${num_files}/7 | bc)
	local total_cores=${num_files}

	dfsio_write "dfsio-write-${l_read_cache}-${l_write_cache}-${num_files}-${file_size}" "${cores}" "${total_cores}" "${num_files}" "${file_size}" "${write_cache}"

	dfsio_wait_job "dfsio-write-${l_read_cache}-${l_write_cache}-${num_files}-${file_size}"

	dfsio_read "dfsio-read-${l_read_cache}-${l_write_cache}-${num_files}-${file_size}" "${cores}" "${total_cores}" "${num_files}" "${file_size}" "${read_cache}"

	dfsio_wait_job "dfsio-read-${l_read_cache}-${l_write_cache}-${num_files}-${file_size}"

}


write_cache=("CACHE_THROUGH" "THROUGH")
read_cache=("CACHE" "NO_CACHE")
size=("1gb" "10gb" "20gb" "30gb" "40gb" "50gb" "60gb" "70gb" "80gb" "90gb" "100gb")

for wc in ${write_cache[@]}; do
	for rc in ${read_cache[@]}; do
    for s in ${size[@]}; do
  		run_test ${s} 7 ${wc} ${rc}
  		sleep 5
    done
	done
done
