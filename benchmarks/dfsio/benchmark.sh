#!/usr/bin/env bash

source dfsio.sh

size=${1:-"1gb"}

run_test() {
	local file_size=$1; shift
	local num_files=$1; shift
	local write_cache=$1; shit
	local read_cache=$1; shift
	
	write "dfsio-write-${write_cache}-${num_files}-${file_size}" "6" "42" "${num_files}" "${file_size}" "${write_cache}" 
	
	wait_job "dfsio-write-${write_cache}-${num_files}-${file_size}"
	
	read "dfsio-read-${read_cache}-${num_files}-${file_size}" "6" "42" "${num_files}" "${file_size}" "${read_cache}"
	
	wait_job "dfsio-read-${read_cache}-${num_files}-${file_size}"

}


write_cache=("CACHE_THROUGH","THROUGH")
read_cache=( "CACHE", "NO_CACHE")

for wc in ${write_cache}; do
	for rc in ${read_cache}; do
		for n in $(seq 7 7 42); do
			run_test ${size} ${n} ${wc} ${rc}
			sleep 60
		done
	done
done



