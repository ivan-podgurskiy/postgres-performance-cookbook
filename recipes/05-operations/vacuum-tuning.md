# Recipe: Autovacuum Tuning for Large Tables

## Problem
Default autovacuum doesn't work for large tables - bloat, TX wraparound.

## Environment
- PostgreSQL 16.2
- Table: medical_documents, ~15M rows

## The Fix
ALTER TABLE ... SET (autovacuum_vacuum_scale_factor = 0.01, ...). For 15M rows: 1000 + 0.01*15M = 151K dead tuples trigger.

## Related Recipes
- [Bloat detection](bloat-detection-and-fix.md)
