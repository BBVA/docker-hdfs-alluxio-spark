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
