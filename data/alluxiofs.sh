#!/bin/bash

set -x
action="$1"
local_file="$2"
remote_filepath="$3"

alluxio_proxy=${ALLUXIO_PROXY:-"http://alluxio-master-rest-has.eurocloud.hyperscale.io"}

debug="-v"
case $action in
    upload)
         curl $debug -L -X PUT \
            -T ${local_file} \
            -H "Expect:" \
            -H "accept-encoding: gzip, deflate" \
            -H "Connection: keep-alive" \
            -H "Content-Type: application/octet-stream" \
            -H "Transfer-Encoding: chunked" \
            -H "Cache-Control: no-cache" \
            "${alluxio_proxy}/webhdfs/v1/${remote_filepath}?op=CREATE&user.name=${user}"
    ;;
    ls)
        remote_filepath=${local_file}
        curl -L $debug -X POST \
            "${alluxio_proxy}/api/v1/paths/${remote_filepath}/list-status"
    ;;
    mkdir)
        remote_filepath=${local_file}
        curl -L $debug -X POST -H "Content-Type: application/json" -d '{"recursive":"true"}' \
         "${alluxio_proxy}/api/v1/paths/${remote_filepath}/create-directory"
    ;;
    rm)
        remote_filepath=${local_file}
        curl -L $debug -H "Content-Type: application/json" -X POST -d '{"recursive":"true"}'  \
        "${alluxio_proxy}/api/v1/paths/${remote_filepath}/delete"
    ;;
    get)
        remote_filepath=${local_file}
        curl -L $debug -X GET \
        "${alluxio_proxy}/webhdfs/v1/${remote_filepath}?op=OPEN&user.name=${user}"
    ;;
    *)
      echo "Invalid action: ${action}"
      exit 1
    ;;
esac
