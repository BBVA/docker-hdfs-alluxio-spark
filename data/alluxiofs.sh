#!/bin/bash

action="$1"
local_file="$2"
remote_filepath="$3"

alluxio_proxy=${ALLUXIO_PROXY:-"http://alluxio-master-rest-has.eurocloud.hyperscale.io"}

function usage() {
  echo -e "Usage: alluxiofs.sh <action> <[local_file | remote_file | remote_path] remote_file>"
  echo -e "Actions:"
  echo -e "  mkdir <remote_path> \t\t\t\tcreates a directory hierarchy"
  echo -e "  ls <remote_path> \t\t\t\tlist files in a remote path stored"
  echo -e "  upload <local_file> <remote_file> \t\tuploads a file"
  echo -e "  upload-persisted <local_file> <remote_file> \tuploads a file and persists it in alluxio's underfs"
  echo -e "  free <remote_file | remote_path> \t\tremoves a file or directory from alluxio's memory"
  echo -e "  rm <remote_file | remote_path> \t\tremoves a file or directory from alluxio's memory and it's underfs"
  echo -e "  persist <remote_file | remote_path> \t\tpersists a file or directory to alluxio's underfs"
  echo -e "  get <remote_file> \t\t\t\tdownloads a file stored in alluxio"
}

function upload {
  local options=${1}

  stream_id=$(curl $debug -L -X POST -H "Content-Type: application/json" \
      -d '{"locationPolicyClass":"alluxio.client.file.policy.RoundRobinPolicy"}' "${alluxio_proxy}/api/v1/paths/${remote_filepath}/create-file")

  re='^[0-9]+$'
  if ! [[ ${stream_id} =~ $re ]] ; then
     echo "error: ${stream_id}" >&2; exit 1
  fi

  curl $debug -L -H "Content-Type: application/octet-stream" -X POST \
      -d @${local_file} \
      "${alluxio_proxy}/api/v1/streams/${stream_id}/write"

  curl $debug -L -X POST \
      "${alluxio_proxy}/api/v1/streams/${stream_id}/close"
}

function persist {
  remote_filepath=${1}
  curl -L $debug -X POST -H "Content-Type: application/json" \
      -d '{"persisted": true}' \
      "${alluxio_proxy}/api/v1/paths/${remote_filepath}/set-attribute"
}

debug="-s"

case $action in
    upload)
        upload
    ;;

    upload-persisted)
        upload
        persist ${remote_filepath}
    ;;

    persist)
        persist ${local_file}
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

    free)
        remote_filepath=${local_file}
        curl -L $debug -H "Content-Type: application/json" -X POST -d '{"recursive":"true"}'  \
        "${alluxio_proxy}/api/v1/paths/${remote_filepath}/free"
    ;;

    get)
        remote_filepath=${local_file}
        stream_id=$(curl $debug -L -X POST \
            "${alluxio_proxy}/api/v1/paths/${remote_filepath}/open-file")

        re='^[0-9]+$'
        if ! [[ ${stream_id} =~ $re ]] ; then
           echo "error: ${stream_id}" >&2; exit 1
        fi

        curl $debug -L -X POST \
            "${alluxio_proxy}/api/v1/streams/${stream_id}/read"

        curl $debug -L -X POST \
            "${alluxio_proxy}/api/v1/streams/${stream_id}/close"
    ;;
    "-h")
        usage
        exit 0
    ;;
    *)
      echo "Invalid action: ${action}"
      usage
      exit 1
    ;;
esac
