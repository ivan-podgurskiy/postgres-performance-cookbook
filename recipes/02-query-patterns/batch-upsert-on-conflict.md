# Recipe: Batch Upsert with ON CONFLICT

## Problem
50K insurance records nightly - need efficient upsert.

## Environment
- PostgreSQL 15.2

## The Fix
INSERT INTO ... VALUES ... ON CONFLICT (key) DO UPDATE SET ... Batch with unnest(). Watch WAL write amplification. Batch sizes 1000-5000 often optimal.

## Related Recipes
- [Zero-downtime migrations](../05-operations/zero-downtime-migrations.md)
