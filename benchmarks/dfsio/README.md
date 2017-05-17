# TestDFSIO benchmark

(TODO explain benchmark)

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

##### Number of files: 10. File size: 1gb. Max. cores: 7

```bash
./run_write.sh MUST_CACHE 10 1gb
```

##### Number of files: 30. File size: 1gb. Max. cores: 7

```bash
./run_write.sh MUST_CACHE 30 1gb
```

##### Number of files: 50. File size: 1gb. Max. cores: 7

```bash
./run_write.sh MUST_CACHE 50 1gb
```

##### Number of files: 70. File size: 1gb. Max. cores: 7

```bash
./run_write.sh MUST_CACHE 70 1gb
```
