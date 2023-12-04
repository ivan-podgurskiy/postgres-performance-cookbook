# Recipe: UUID vs bigserial Primary Keys

## Problem
UUID vs bigserial affects insert performance, index size, B-tree efficiency.

## Environment
- PostgreSQL 16.1
- Scale: 10M+ records

## Key Points
- bigserial: sequential, efficient B-tree
- UUID v4: random, page splits, 2x index size
- UUIDv7 not yet native in Postgres — use pg_uuidv7 extension for now.

## Related Recipes
- [Partitioning](partitioning-by-date.md)
- [Soft delete](soft-delete-patterns.md)
