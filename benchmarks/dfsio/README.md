# TestDFSIO benchmark

TestDFSIO is the canonical example of a benchmark that attempts to measure the HDFS's capacity for reading and writing bulk data. The test can measure the time taken to create a given number of large files, and then use those same files as inputs to a test to measure the read performance an HDFS instance can sustain.

The original version is included in the Hadoop's MapReduce job client library. However, since we were running the tests on a Spark Standalone cluster, we needed using a modified version of this benchmark based entirely on Spark and fully compatible with the Alluxio filesystem.

See [Spark Benchmarks](https://github.com/BBVA/spark-benchmarks).

## Scripts description

 - parse.sh: extracts all the information generated from the driver logs in openshift and generate a csv output which we will use to analize the results.
 - norm.sh: normalizes output to csv format.
 - plot.sh: plots data usgin gnuplot.
 - dfsio.sh: a set of functions to executing DFSIO benchmark using Alluxio.
 - dfsio_hdfs.sh: a set of functions to executing DFSIO benchmark using only HDFS.
 - dfsio_clean.sh: deletes all Kubernetes' jobs related to the benchmark.
 - benchmark.sh: runs a benchmark set with different combinations by changing the number of concurrent tasks and the configuration of the read and write types in Alluxio.
 - benchmark-hdfs.sh: similar to the previous one but using only HDFS.
 - benchmark-files.sh: runs a benchmark set with different combinations by changing the file size to write and read.
 - benchmark-files-hdfs: similar to the previous one but using only HDFS.

Examples:

 ```bash plot.sh text read-small-files.csv read "Files MB/s Time(s)" 7,15,18 "Throughtput"```

 ```                                                                              
   110 +-+------+-------+--------+--------+-------+--------+-------+------+-+   
       +  *     +       +        +        +       +        +       +   #    +   
   100 +-+ *                                                   MB/s *******-+   
       |    *                                               Time(s) ####### |   
    90 +-+   *                                                      #     +-+   
       |      *                                                    #        |   
    80 +-+     *                                                 ##       +-+   
       |        *                                               #           |   
    70 +-+       *                                             #          +-+   
    60 +-+        *                                           #           +-+   
       |           *              *******                    #              |   
    50 +-+          *          ***       ****               #             +-+   
       |             *      ***              **         ####                |   
    40 +-+            *##***####               ************               +-+   
       |            ## **       ###      #########         ************     |   
    30 +-+       ###               ######                              *  +-+   
       |      ###                                                           |   
    20 +-+  ##                                                            +-+   
       +  ##    +       +        +        +       +        +       +        +   
    10 +-+------+-------+--------+--------+-------+--------+-------+------+-+   
       5        10      15       20       25      30       35      40       45  
 ```
 
