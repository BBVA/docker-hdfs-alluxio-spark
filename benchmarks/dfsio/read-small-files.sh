#!/usr/bin/env bash

source dfsio.sh


run_test() {
	local num_files=$1; shift
	
	write "small-files-dfsio-write-cache-through-${num_files}-1g" "6" "42" "${num_files}" "1gb" "CACHE_THROUGH"
	
	wait_job "small-files-dfsio-write-cache-through-${num_files}-1g"
	
	read "small-files-dfsio-read-cache-through-${num_files}-1g" "6" "42" "${num_files}" "1gb" "CACHE"
	
	wait_job "small-files-dfsio-read-cache-through-${num_files}-1g"

}

run_test 7
