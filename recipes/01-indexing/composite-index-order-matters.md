# Recipe: Composite Index Column Order Matters

## Problem
Query filtering by status and date is taking 2.4 seconds on a 500K row table because the composite index has columns in the wrong order.

## Environment
- PostgreSQL 16.1
- Table: documents, ~500,000 rows
- Existing index: `idx_documents_created_status` (created_at, status)
- Query pattern: Filter by status first, then date range

## The Slow Way

```sql
-- Query that runs slowly with wrong index column order
SELECT id, patient_id, doc_type, status, created_at
FROM documents 
WHERE status = 'completed' 
  AND created_at >= '2022-01-01' 
  AND created_at < '2022-02-01'
ORDER BY created_at DESC
LIMIT 100;
```

### EXPLAIN ANALYZE (before)

```
Limit  (cost=85423.45..85423.70 rows=100 width=45) (actual time=2387.234..2387.251 rows=100 loops=1)
  ->  Sort  (cost=85423.45..85508.12 rows=33866 width=45) (actual time=2387.232..2387.245 rows=100 loops=1)
        Sort Key: created_at DESC
        Sort Method: top-N heapsort  Memory: 34kB
        ->  Seq Scan on documents  (cost=0.00..84123.00 rows=33866 width=45) (actual time=0.156..2375.423 rows=24502 loops=1)
              Filter: ((status = 'completed'::doc_status) AND (created_at >= '2022-01-01 00:00:00+00'::timestamp with time zone) AND (created_at < '2022-02-01 00:00:00+00'::timestamp with time zone))
              Rows Removed by Filter: 475498
              Buffers: shared hit=12456 read=3489
Planning Time: 0.543 ms
Execution Time: 2387.289 ms
```

## The Fix
Create a composite index with the most selective column first. Since `status` has only 4 possible values but we're filtering for one specific status that represents 70% of rows, we need to put the date column first for better selectivity.

Actually, let's reconsider: when filtering by a specific status that represents 70% of rows, the date range is more selective. But the real issue is PostgreSQL can't efficiently use a (created_at, status) index for a query that filters status first.

```sql
-- Drop the inefficient index
DROP INDEX idx_documents_created_status;

-- Create index with status first for this query pattern
CREATE INDEX idx_documents_status_created ON documents (status, created_at);
```

### EXPLAIN ANALYZE (after)

```
Limit  (cost=0.42..127.45 rows=100 width=45) (actual time=0.234..1.456 rows=100 loops=1)
  ->  Index Scan using idx_documents_status_created on documents  (cost=0.42..31234.89 rows=24502 width=45) (actual time=0.232..1.442 rows=100 loops=1)
        Index Cond: ((status = 'completed'::doc_status) AND (created_at >= '2022-01-01 00:00:00+00'::timestamp with time zone) AND (created_at < '2022-02-01 00:00:00+00'::timestamp with time zone))
        Filter: (created_at < '2022-02-01 00:00:00+00'::timestamp with time zone)
Planning Time: 1.023 ms
Execution Time: 1.534 ms
```

## Why It Works
PostgreSQL B-tree indexes are sorted by the first column, then by the second column within each first-column value. The query planner can efficiently use the index when:

- **Leading column matching:** The WHERE clause filters on the first index column
- **Sequential access:** After filtering by status='completed', PostgreSQL can scan the date range sequentially within that status partition
- **Index-only operation:** The query can be satisfied entirely from the index without heap lookups for sorting

When the index was (created_at, status), PostgreSQL couldn't efficiently find all 'completed' documents because they were scattered across different date ranges in the index structure.

## When NOT to Use This
- **Multiple query patterns:** If you also frequently query by date alone, consider separate indexes or covering indexes
- **Low-cardinality first column:** If the first column has very low selectivity (like boolean columns with 95% true values), it might not help
- **Write-heavy workload:** More indexes slow down INSERT/UPDATE operations

## Related Recipes
- [Partial indexes for skewed data](partial-indexes.md)
- [Covering indexes with INCLUDE](covering-indexes.md)

## Performance Impact
- **Before:** 2,387 ms (Seq Scan on 500K rows)
- **After:** 1.5 ms (Index Scan, 100 rows examined)
- **Improvement:** 99.9% faster, eliminated 475,498 row examinations
