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

type="$1"; shift
file="$1"; shift
term="$1"; shift
header="$1"; shift
fields="$1"; shift

N=$(echo ${fields} | tr -dc "," | wc -c )
((N=N + 1))

data=$(mktemp)

echo "${header}" > ${data}
cat ${file} | grep ${term} | sort -t, -k${fields[0]} -n | cut -d, -f${fields}  | sed 's/,/ /g'>> ${data}

case "$type" in
	text)
		gnuplot -p -e "set term dumb;plot for [col=2:$N]  '$data' u 1:col w l t columnheader"
		rm -f $data
		;;
	x11)
		gnuplot -p -e "plot for [col=2:$N]  '$data' u 1:col w l t columnheader"
		rm -f $data
		;;
	png)
		gnuplot -p -e "set term png size 1024,768;plot for [col=2:$N]  '$data' u 1:col w l t columnheader"
		rm -f $data
		;;
	*)
		echo usage:
		echo 	plot.sh type file term header fields
		;;

esac
