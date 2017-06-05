#!/bin/bash

oc delete jobs $(oc get jobs  --template "{{range .items}}{{ .metadata.name  }} {{ end }}")
oc delete dc $(oc get dc  --template "{{range .items}}{{ .metadata.name }}
{{end}}" | grep dfsio)

oc delete dc $(oc get dc  --template "{{range .items}}{{ .metadata.name }}
{{end}}" | grep dfsio)

oc delete routes $(oc get routes  --template "{{range .items}}{{ .metadata.name }}
{{end}}" | grep dfsio)

oc delete services $(oc get services  --template "{{range .items}}{{ .metadata.name }}
{{end}}" | grep dfsio)

oc delete pods $(oc get pods  --template "{{range .items}}{{ .metadata.name }}
{{end}}" | grep dfsio)
