# TestDFSIO benchmark

TestDFSIO is the canonical example of a benchmark that attempts to measure the HDFS's capacity for reading and writing bulk data. The test can measure the time taken to create a given number of large files, and then use those same files as inputs to a test to measure the read performance an HDFS instance can sustain.

The original version is included in the Hadoop's MapReduce job client library. However, since we were running the tests on a Spark Standalone cluster, we needed using a modified version of this benchmark based entirely on Spark and fully compatible with the Alluxio filesystem.

(TODO link to repo)

## Benchmark scripts usage

(TODO explain submitter usage)

### Clean benchmarks

```bash
./run_clean.sh
```

### Run write tests

```bash
./run_write.sh [MUST_CACHE | CACHE_THROUGH | THROUGH] <num_files> <file_size>
```

Example:

```bash
./run_write.sh MUST_CACHE 10 1gb
```

### Run read tests

```bash
./run_read.sh [NO_CACHE | CACHE] <num_files> <file_size>
```

Example:

```bash
./run_read.sh NO_CACHE 10 1gb
```

## Results

### Write benchmarks

#### Write type: *MUST_CACHE*

##### Number of files: 10. File size: 1GB. Max. cores: 7

Command:

```bash
./run_write.sh MUST_CACHE 10 1gb
```

Result:

##### Number of files: 30. File size: 1GB. Max. cores: 7

Command:

```bash
./run_write.sh MUST_CACHE 30 1gb
```

Result:

##### Number of files: 50. File size: 1GB. Max. cores: 7

Command:

```bash
./run_write.sh MUST_CACHE 50 1gb
```
Result:

##### Number of files: 70. File size: 1GB. Max. cores: 7

Command:

```bash
./run_write.sh MUST_CACHE 70 1gb
```
Result:

##### Number of files: 90. File size: 1GB. Max. cores: 7

Command:

```bash
./run_write.sh MUST_CACHE 90 1gb
```
Result:

##### Number of files: 110. File size: 1GB. Max. cores: 7

Command:

```bash
./run_write.sh MUST_CACHE 110 1gb
```
Result:

##### Number of files: 130. File size: 1GB. Max. cores: 7

Command:

```bash
./run_write.sh MUST_CACHE 130 1gb
```
Result:

##### Number of files: 150. File size: 1GB. Max. cores: 7

Command:

```bash
./run_write.sh MUST_CACHE 150 1gb
```
Result:
