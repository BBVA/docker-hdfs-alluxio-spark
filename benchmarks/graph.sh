#!/bin/bash

set -u
set -a 
set -e

file=$(mktemp)

interval="$1"
shift
range="$1"
shift
command="$@"
start=$(date +"%s")

cat > $file.plot << EOF
set xrange [0:$range]
set terminal dumb
plot "$file.dat" using 1:2 with lines
pause 1
reread
EOF

writedata() {
        echo writedata
        while true; do
                now=$(date +"%s")
                value=$(eval $command)
                key=$(echo $now-$start | bc) #let key=$now-$start
                echo $key $value >> $file.dat
                sleep $interval
        done
}


cleanup() {
        echo Cleaning up
        [[ -z "$(jobs -p)" ]] || kill $(jobs -p)
}

trap "cleanup" INT

writedata &
sleep 2
gnuplot $file.plot

