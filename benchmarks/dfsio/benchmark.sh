#!/usr/bin/env bash

# Copyright 2017 Banco Bilbao Vizcaya Argentaria S.A.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source dfsio.sh

size=${1:-"1gb"}

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

for wc in ${write_cache[@]}; do
	for rc in ${read_cache[@]}; do
		for n in $(seq 7 7 42); do
			run_test ${size} ${n} ${wc} ${rc}
			sleep 5
		done
	done
done
