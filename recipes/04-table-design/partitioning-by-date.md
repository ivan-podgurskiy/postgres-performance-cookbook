# Recipe: Range Partitioning by Date

## Problem
50M+ row documents table slow for date range queries.

## Environment
- PostgreSQL 16.1

## The Fix
PARTITION BY RANGE (document_date). Monthly partitions. Partition pruning in EXPLAIN. Auto-create function for new months.

## Related Recipes
- [Soft delete patterns](soft-delete-patterns.md)
