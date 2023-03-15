# Recipe: CTE Materialization Control (PG 12+)

## Problem
CTE is materialized unnecessarily, preventing index usage.

## Environment
- PostgreSQL 15.2

## The Fix
Use NOT MATERIALIZED hint: `WITH recent_patients AS NOT MATERIALIZED (SELECT ...)`

## Related Recipes
- [EXISTS vs IN](exists-vs-in-vs-join.md)
