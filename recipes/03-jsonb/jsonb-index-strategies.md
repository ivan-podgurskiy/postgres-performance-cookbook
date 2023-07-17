# Recipe: JSONB Index Strategies Compared (GIN ops)

## Problem
JSONB queries slow as table grows. Different GIN ops: default vs jsonb_path_ops vs expression indexes.

## Environment
- PostgreSQL 15.3
- Table: medical_orders, ~500K rows

## The Fix
- Default GIN: supports all operators, larger
- jsonb_path_ops: @> only, 20-30% smaller
- Expression index on (metadata->'priority'): smallest for single-key

## Related Recipes
- [JSONB vs normalized tables](jsonb-vs-normalized-tables.md)
- [JSONB containment queries](jsonb-containment-queries.md)
