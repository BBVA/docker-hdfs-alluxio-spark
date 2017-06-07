#!/bin/bash

cat $1 | awk 'BEGIN{
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
'
