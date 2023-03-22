# Recipe: LATERAL JOIN for Top-N-Per-Group

## Problem
Get 3 most recent orders per patient - window functions are memory intensive.

## Environment
- PostgreSQL 15.2

## The Fix
Use CROSS JOIN LATERAL with LIMIT 3 in subquery. Index on (patient_id, created_at DESC).

## Related Recipes
- [Window functions for deduplication](window-functions-for-dedup.md)
- [Composite index order](composite-index-order-matters.md)
