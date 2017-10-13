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

INPUT_FILE=${1:-out.csv}
OUTPUT_FILE=${2:-out_dup.csv}
SIZE_IN_BYTES=${3:-50000000000}

echo "Duplicating ${INPUT_FILE} to fill ${SIZE_IN_BYTES} bytes"

if [ ! -f ${OUTPUT_FILE} ]; then
  touch ${OUTPUT_FILE};
fi

while [ "$(stat -c%s ${OUTPUT_FILE})" -le "${SIZE_IN_BYTES}" ]; do
  cat ${INPUT_FILE} >> ${OUTPUT_FILE};
done

echo "Done"
