#!/bin/bash

./get_data.sh
./duplicate_data.sh data.csv out_dup.csv 5000000000
./add_headers.sh repo/data/0x10c.csv out_dup.csv

rm out.csv
mv out_dup.csv out.csv
