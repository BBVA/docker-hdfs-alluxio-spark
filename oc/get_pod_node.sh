#!/bin/bash

oc get pods --template='pod - nodename {{ printf "\n" }}{{ range .items }}{{.metadata.name }} - {{ .spec.nodeName }} {{printf "\n"}} {{end}}'

