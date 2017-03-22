#!/bin/bash

REPOSITORY=${1:-https://github.com/umbrae/reddit-top-2.5-million.git}
DEST_FOLDER=${2:-repo}

echo "Cloning repository ${REPOSITORY} into ${DEST_FOLDER}"

if [ ! -d "${DEST_FOLDER}" ]; then
  git clone ${REPOSITORY} ${DEST_FOLDER}
else
  echo "Repository ${REPOSITORY} already cloned"
fi
