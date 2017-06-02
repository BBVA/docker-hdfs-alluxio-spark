#!/bin/bash

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
