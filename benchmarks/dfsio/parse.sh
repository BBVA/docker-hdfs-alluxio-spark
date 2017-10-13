#!/bin/bash

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

# ----- TestDFSIO ----- : read
# 12            Date & time: Mon May 22 10:19:51 UTC 2017
# 13       Number of files: 21
# 14 Total MBytes processed: 21504
# 15     Throughput mb/sec: 59.31303457996254
# 16 Average IO rate mb/sec: 93.74904
# 17 IO rate std deviation: 92.96005736672606
# 18    Test exec time sec: 33.183


parse() {
	 awk -v pod="$1" 'BEGIN{
		i=0
	}
	/INFO TestDFSIO\$: $/ ,/^\n/ {
	 split($0, kva, ": ")
	 kv[i]=kva[2]
	 i++
	 }END {
	 	printf("%s,",pod);
	 	for  (k in kv) {
	 		printf("%s,", kv[k]);
	 	}
	 	printf("\n");
	 }'
}


pods=$(oc get pods -l type=driver --template="{{ range .items }}{{.metadata.name }} {{end }}")

for pod in $pods; do
	podstr=$(echo $pod | sed 's/-/,/g')
	oc logs $pod | parse $podstr
done
