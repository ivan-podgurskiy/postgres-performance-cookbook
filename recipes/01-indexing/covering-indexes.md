# Recipe: Covering Indexes with INCLUDE

## Problem
Query selecting patient details by last name requires both index lookup and heap access, causing unnecessary disk I/O when we only need a few columns.

## Environment
- PostgreSQL 15.1
- Table: patients, ~500,000 rows  
- Query pattern: Search by last name, return name and date of birth
- Existing index: `idx_patients_last_name` (last_name)

## The Slow Way

```sql
-- Query that needs both index and heap access
SELECT id, first_name, last_name, date_of_birth, insurance_id
FROM patients 
WHERE last_name = 'Johnson'
ORDER BY first_name;
```

### EXPLAIN ANALYZE (before)

```
Sort  (cost=156.23..156.89 rows=263 width=67) (actual time=8.234..8.456 rows=263 loops=1)
  Sort Key: first_name
  Sort Method: quicksort  Memory: 45kB
  ->  Index Scan using idx_patients_last_name on patients  (cost=0.42..145.67 rows=263 width=67) (actual time=0.023..7.234 rows=263 loops=1)
        Index Cond: ((last_name)::text = 'Johnson'::text)
        Buffers: shared hit=4 read=67
Planning Time: 0.456 ms
Execution Time: 8.567 ms
```

## The Fix
Create a covering index that includes all the columns needed by the query. This allows PostgreSQL to satisfy the entire query from the index without accessing the heap.

```sql
-- Drop the old index
DROP INDEX idx_patients_last_name;

-- Create covering index with INCLUDE clause
CREATE INDEX idx_patients_last_name_covering 
ON patients (last_name) 
INCLUDE (first_name, date_of_birth, insurance_id);
```

### EXPLAIN ANALYZE (after)

```
Index Only Scan using idx_patients_last_name_covering on patients  (cost=0.42..23.45 rows=263 width=67) (actual time=0.034..0.234 rows=263 loops=1)
  Index Cond: (last_name = 'Johnson'::text)
  Heap Fetches: 0
  Buffers: shared hit=4
Planning Time: 0.234 ms
Execution Time: 0.345 ms
```

## Why It Works
Covering indexes eliminate heap access through several mechanisms:

- **Index-only scans:** All required columns are available in the index
- **No heap fetches:** PostgreSQL doesn't need to check row visibility in the heap because the index contains all data
- **Reduced I/O:** Only index pages are read, not data pages
- **Better caching:** Smaller working set fits better in buffer cache

The INCLUDE clause specifically:
- Adds columns to leaf pages only (not internal B-tree nodes)  
- Doesn't affect sort order or uniqueness constraints
- Allows including columns that can't be in regular B-tree indexes (like TEXT fields)

## When NOT to Use This
- **Wide rows:** Including too many or very wide columns inflates index size
- **Write-heavy workload:** Every UPDATE of included columns must update the index
- **Multiple query patterns:** Different queries need different column sets
- **Storage constraints:** Covering indexes use significantly more disk space

Trade-offs to consider:
- Index size: 15 MB → 45 MB (3x larger)
- Write performance: ~10% slower INSERTs due to larger index maintenance
- Query performance: 96% faster for this specific pattern

## Related Recipes
- [Partial indexes for skewed data](partial-indexes.md)
- [Index-only scans optimization](index-only-scans.md)

## Performance Impact  
- **Before:** 8.6 ms (Index Scan + 67 heap block reads)
- **After:** 0.34 ms (Index Only Scan, 0 heap fetches)
- **Improvement:** 96% faster, 100% reduction in heap access
- **Trade-off:** 3x larger index, 10% slower writes
