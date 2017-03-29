#!/bin/bash

action="$1"
local_file="$2"
remote_filepath="$3"

user="openshift"
httpfs=${HTTPFS:-"http://hdfs-httpfs-dashboard-hasz.192.168.42.95.nip.io"}

debug="-v -i"
case $action in
    upload)
        cat ${local_file}| curl $debug -X PUT \
            -T . \
            -H "Expect:" \
            -H "accept-encoding: gzip, deflate" \
            -H "Connection: keep-alive" \
            -H "Content-Type: application/octet-stream" \
            -H "Transfer-Encoding: chunked" \
            -H "Cache-Control: no-cache" \
            "${httpfs}/webhdfs/v1/${remote_filepath}?op=CREATE&user.name=${user}"
    ;;
    ls)
        remote_filepath=${local_file}
        curl -L $debug -X GET \
            "${httpfs}/webhdfs/v1/${remote_filepath}?op=LISTSTATUS&data=true&user.name=${user}"
    ;;
    mkdir)
        remote_filepath=${local_file}
        curl -L $debug -X PUT \
         "${httpfs}/webhdfs/v1/user/${user}/${remote_filepath}?op=MKDIRS&user.name=${user}"
    ;;
    rm)
        remote_filepath=${local_file}
        curl -L $debug -X DELETE \
        "${httpfs}/webhdfs/v1/user/${user}/${remote_filepath}?op=DELETE&user.name=${user}&recursive=true"
    ;;
esac
