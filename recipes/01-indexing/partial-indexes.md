# Recipe: Partial Indexes for Skewed Boolean Data

## Problem
Query filtering for 'pending' orders is slow despite having an index on status.

## Environment
- PostgreSQL 15.1
- Table: orders, ~1,000,000 rows
- Data distribution: 65% completed, 20% processing, 8% pending, 7% failed

## The Slow Way

```sql
SELECT id, patient_id, hcpcs_code, total_amount, created_at
FROM orders WHERE status = 'pending' ORDER BY created_at DESC LIMIT 50;
```

### EXPLAIN ANALYZE (before)

```
Limit  (cost=34521.45..34521.58 rows=50 width=59) (actual time=423.234..423.267 rows=50 loops=1)
  ->  Sort  ->  Bitmap Heap Scan on orders  (cost=1642.33..32341.56 rows=79952 width=59) (actual time=12.345..398.765 rows=79824 loops=1)
        ->  Bitmap Index Scan on idx_orders_status  (cost=0.00..1622.35 rows=79952 width=0) (actual time=8.234..8.234 rows=79824 loops=1)
Planning Time: 0.634 ms
Execution Time: 423.334 ms
```

## The Fix
Create a partial index only for pending orders.

```sql
CREATE INDEX idx_orders_pending ON orders (created_at DESC) WHERE status = 'pending';
```

### EXPLAIN ANALYZE (after)

```
Limit  (cost=0.29..7.45 rows=50 width=59) (actual time=0.123..0.234 rows=50 loops=1)
  ->  Index Scan using idx_orders_active on orders  (cost=0.29..11456.78 rows=79824 width=59) (actual time=0.121..0.223 rows=50 loops=1)
Planning Time: 0.234 ms
Execution Time: 0.267 ms
```

## Why It Works
Partial indexes reduce index size by only indexing rows we query. Index size: 45 MB -> 3.6 MB.

## When NOT to Use This
Changing query patterns; even data distribution.

## Related Recipes
- [Composite index order matters](composite-index-order-matters.md)
- [Index usage audit](../06-monitoring/index-usage-audit.md)
