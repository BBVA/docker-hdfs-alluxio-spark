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

## Scenarios

Each scenario tests 7, 14, 21, 28, 35 and 42 files. We've selected those beacuse our cluster has 7 nodes. Also each scenario write files to alluxio using CACHE_TROUGH and read the files using CACHE.

After runing all scenarios, we use the tool ```parse.sh``` to extrat all the information generated from the driver logs in openshift and generate a csv output which we will use to analize the results.


## Scenario 1: read small files

Source: read-small-files.sh
File size: 1GB
Executions: 7, 14, 21, 28, 35 and 42 files

Results:

small | files | dfsio | read | cache | through | 7 | 1g | 0pu8m | Mon May 22 09:49:33 UTC 2017 | 7 | 7168 | 104.36504469875659 | 117.27533 | 113.62099484140244 | 17.132 | read
small | files | dfsio | write | cache | through | 7 | 1g | uz5w0 | Mon May 22 09:48:23 UTC 2017 | 7 | 7168 | 44.83278397328046 | 44.92461 | 41.41482075211346 | 24.935 | write
small | files | dfsio | read | cache | through | 14 | 1g | omtap | Mon May 22 09:53:04 UTC 2017 | 14 | 14336 | 34.71917813195516 | 35.799236 | 34.59481211671231 | 41.311 | read
small | files | dfsio | write | cache | through | 14 | 1g | dsxh5 | Mon May 22 09:51:18 UTC 2017 | 14 | 14336 | 23.48950951557802 | 23.652603 | 22.45978529653403 | 48.767 | write
small | files | dfsio | read | cache | through | 21 | 1g | 6lr1w | Mon May 22 10:19:51 UTC 2017 | 21 | 21504 | 59.31303457996254 | 93.74904 | 92.96005736672606 | 33.183 | read
small | files | dfsio | write | cache | through | 21 | 1g | v3ebt | Mon May 22 10:18:46 UTC 2017 | 21 | 21504 | 16.396917647884123 | 16.511776 | 15.70902602121329 | 71.115 | write
small | files | dfsio | read | cache | through | 28 | 1g | du4l6 | Mon May 22 10:04:25 UTC 2017 | 28 | 28672 | 42.93198891362842 | 45.686428 | 44.75806273385277 | 33.832 | read
small | files | dfsio | write | cache | through | 28 | 1g | 0emm9 | Mon May 22 10:03:04 UTC 2017 | 28 | 28672 | 12.83545795259404 | 12.923287 | 12.246503681336653 | 91.609 | write
small | files | dfsio | read | cache | through | 35 | 1g | 41zqu | Mon May 22 10:08:57 UTC 2017 | 35 | 35840 | 37.58688821676224 | 41.37425 | 40.68058847067373 | 45.885 | read
small | files | dfsio | write | cache | through | 35 | 1g | 6990b | Mon May 22 10:07:13 UTC 2017 | 35 | 35840 | 9.930098644336505 | 9.985756 | 9.362371051139704 | 114.136 | write
small | files | dfsio | read | cache | through | 42 | 1g | ekt3o | Mon May 22 10:14:28 UTC 2017 | 42 | 43008 | 28.937978607373235 | 36.206993 | 35.67073886714606 | 103.287 | read
small | files | dfsio | write | cache | through | 42 | 1g | 9jnez | Mon May 22 10:12:07 UTC 2017 | 42 | 43008 | 8.074380120293394 | 8.125965 | 7.534641372864125 | 138.523 | write







```bash plot.sh text read-small-files.csv write "Files MB/s Time(s)" 7,15,18 "Throughtput"```

```
  140 +-+------+-------+--------+--------+-------+--------+-------+--##--+-+   
      +        +       +        +        +       +        +       ###      +   
      |                                                       M### ******* |   
  120 +-+                                                  T###(s) #######-+   
      |                                                 ####               |   
  100 +-+                                           ####                 +-+   
      |                                         ####                       |   
      |                                    #####                           |   
   80 +-+                            ######                              +-+   
      |                         #####                                      |   
      |                     ####                                           |   
   60 +-+               ####                                             +-+   
      |              ###                                                   |   
      |  *******  ###                                                      |   
   40 +-+     ##****                                                     +-+   
      |    ###      **                                                     |   
   20 +-+##           ************                                       +-+   
      |                           ************************                 |   
      +        +       +        +        +       +        *************    +   
    0 +-+------+-------+--------+--------+-------+--------+-------+------+-+   
      5        10      15       20       25      30       35      40       45
```


## Scenario 2: read medium files

Source: read-small-files.sh
File size: 1GB
Executions: 7, 14, 21, 28, 35 and 42 files

Results:
### Clean benchmarks


## Scenario 3: read large files

Source: read-small-files.sh
File size: 1GB
Executions: 7, 14, 21, 28, 35 and 42 files

Results:
