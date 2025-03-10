# Recipe: Keyset Pagination vs OFFSET

## Problem
OFFSET 100000 scans 100K rows. Keyset pagination has constant performance.

## Environment
- PostgreSQL 15.2

## The Fix
Use WHERE (created_at, id) < ($last_created_at, $last_id) ORDER BY created_at, id LIMIT 100. Index on (created_at, id).

## Related Recipes
- [Composite index order](../01-indexing/composite-index-order-matters.md)
