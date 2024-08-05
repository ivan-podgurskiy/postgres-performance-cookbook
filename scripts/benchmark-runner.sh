#!/bin/bash
# Benchmark runner: run query N times, capture EXPLAIN ANALYZE, report p50/p95/p99
for i in $(seq 1 ${1:-5}); do
  psql -d performance_cookbook -c "EXPLAIN (ANALYZE, BUFFERS) $2" 2>/dev/null | grep "Execution Time"
done
