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

cat $1 | sed 's/gb//g' | awk 'BEGIN{
	FS=","
	printf("name,type,readcache,writecache,size,num_files, total_mb,mb/s,avg mb/s, std.dev.,time,zero\n")
}
/dfsio,read,cache,through/ {
	printf("dfsio,read,cache,through,%s,",$6)
	for(i=9;i<=14;i++) {
		printf("%s,",$i)
	}
	printf("0\n")
}
/dfsio,read,cache,cache,through/ {
	printf("dfsio,read,cache,cache through,%s,",$7)
	for(i=10;i<=15;i++) {
		printf("%s,",$i)
	}
	printf("0\n")
}
/dfsio,read,no,cache,through/ {
	printf("dfsio,read,no cache,through,%s,",$7)
	for(i=10;i<=15;i++) {
		printf("%s,",$i)
	}
	printf("0\n")
}
/dfsio,read,no,cache,cache,through/ {
	printf("dfsio,read,no cache,cache through,%s,",$8)
	for(i=11;i<=16;i++) {
		printf("%s,",$i)
	}
	printf("0\n")
}

/dfsio,write,cache,through/ {
	printf("dfsio,write,cache,through,%s,",$6)
	for(i=9;i<=14;i++) {
		printf("%s,",$i)
	}
	printf("0\n")
}
/dfsio,write,cache,cache,through/ {
	printf("dfsio,write,cache,cache through,%s,",$7)
	for(i=10;i<=15;i++) {
		printf("%s,",$i)
	}
	printf("0\n")
}
/dfsio,write,no,cache,through/ {
	printf("dfsio,write,no cache,through,%s,",$7)
	for(i=10;i<=15;i++) {
		printf("%s,",$i)
	}
	printf("0\n")
}
/dfsio,write,no,cache,cache,through/ {
	printf("dfsio,write,no cache,cache through,%s,",$8)
	for(i=11;i<=16;i++) {
		printf("%s,",$i)
	}
	printf("0\n")
}
/dfsio,hdfs,read/ {
	printf("dfsio,read,%s,%s,",$4,$5)
	for(i=9;i<=15;i++) {
		printf("%s,",$i)
	}
	printf("0\n")
}
/dfsio,hdfs,write/ {
	printf("dfsio,write,%s,%s,",$4,$5)
	for(i=9;i<=15;i++) {
		printf("%s,",$i)
	}
	printf("0\n")
}
'
