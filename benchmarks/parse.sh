#!/bin/bash


parse() {
	awk '/INFO TestDFSIO\$: $/ ,/\n/ {print $0}'  |  awk -v pod="$1" 'BEGIN{
		i=0
	}{ 
	 split($0, kva, ": ")
	 kv[i]=kva[2]
	 i++
	 }END {
	 	printf("%s,",pod);
	 	for  (k in kv) {
	 		printf("%s,", kv[k]);
	 	}
	 	printf("\n");
	 }'
}


pods=$(oc get pods -l type=driver --template="{{ range .items }}{{.metadata.name }} {{end }}")

for pod in $pods; do
	oc logs $pod | parse $pod
done

