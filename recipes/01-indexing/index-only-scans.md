# Recipe: Achieving Index-Only Scans (Visibility Map)

## Problem
Index scan still performs heap fetches for visibility checks.

## Environment
- PostgreSQL 15.1
- Table: patients, ~500,000 rows

## The Fix
VACUUM (ANALYZE) to update visibility map. Then index-only scan with Heap Fetches: 0.

## Related Recipes
- [Covering indexes](covering-indexes.md)
- [Autovacuum tuning](../05-operations/vacuum-tuning.md)
