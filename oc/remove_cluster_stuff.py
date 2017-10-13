#!/usr/bin/env python3

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

import sys
import os
try:
    import yaml
except ImportError as err:
    raise ImportError("Missing pyyaml. Install with pip install pyyaml.")
import json

def clean_persistent_volume_claim(tree, i):
    del tree["objects"][i]

def clean_deployment_affinity(tree, i):
    del tree["objects"][i]["spec"]["template"]["metadata"]["annotations"]["scheduler.alpha.kubernetes.io/affinity"]

def clean_deployment_volume_claim(tree, i):
    if "volumes" in tree["objects"][i]["spec"]["template"]["spec"]:
        for j,v in enumerate(tree["objects"][i]["spec"]["template"]["spec"]["volumes"]):
            if "persistentVolumeClaim" in v:
                del tree["objects"][i]["spec"]["template"]["spec"]["volumes"][j]["persistentVolumeClaim"]
                tree["objects"][i]["spec"]["template"]["spec"]["volumes"][j]["emptyDir"] = {}

with open(sys.argv[1], 'r') as stream:
    try:
        parsed_yaml = yaml.load(stream)
        for i,v in enumerate(parsed_yaml["objects"]):
            if v["kind"] == "PersistentVolumeClaim":
                clean_persistent_volume_claim(parsed_yaml, i)
            if v["kind"]  == "DeploymentConfig":
                clean_deployment_affinity(parsed_yaml, i)
                clean_deployment_volume_claim(parsed_yaml, i)
            if v["kind"] == "Job":
                clean_deployment_affinity(parsed_yaml, i)


        print(json.dumps(parsed_yaml))
    except yaml.YAMLError as exc:
        print(exc)
