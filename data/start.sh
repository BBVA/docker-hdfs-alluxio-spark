#!/bin/bash

./get_data.sh
./concatenate_data.sh repo/data out.csv
./duplicate_data.sh out.csv out_dup.csv 5000000000
./add_headers.sh repo/data/0x10c.csv out_dup.csv

rm out.csv
mv out_dup.csv out.csv
