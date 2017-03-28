#!/bin/bash

action="$1"
local_file="$2"
remote_filepath="$3"

user="root"
httpfs=${HTTPFS:-"http://hdfs-httpfs-dashboard-hasz.192.168.42.95.nip.io"}
pod="hdfs-httpfs-1-d62yr"
case $action in 
    upload)
        curl -L -v -X PUT \
        -T ${local_file} \
        -H "Host: ${pod}" \
        -H "Content-Type: application/octet-stream" \
        -H "Transfer-Encoding:chunked" \
         "${httpfs}/webhdfs/v1/user/${user}/${remote_filepath}?op=CRE‌​ATE&data=true&user.name=${user}" 
    ;;
    mkdir)
        curl -L -v -X PUT \
        -T ${local_file} \
        -H "Host: ${pod}" \
         "${httpfs}/webhdfs/v1/user/${user}/${remote_filepath}?op=MKDIRS&user.name=${user}" 
    ;;
esac
