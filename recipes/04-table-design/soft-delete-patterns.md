# Recipe: Soft Delete Patterns and Their Hidden Costs

## Problem
deleted_at IS NULL everywhere - query performance, index bloat.

## Environment
- PostgreSQL 16.1
- 30% soft-deleted in 5M rows

## The Fix
Partial index WHERE deleted_at IS NULL. Or archive table. Or view-based approach.

## Related Recipes
- [Partial indexes](../01-indexing/partial-indexes.md)
