# Recipe: UUID vs bigserial Primary Keys

## Problem
UUID vs bigserial affects insert performance, index size, B-tree efficiency.

## Environment
- PostgreSQL 16.1
- Scale: 10M+ records

## Key Points
- bigserial: sequential, efficient B-tree
- UUID v4: random, page splits, 2x index size
- **PG 18 Update:** uuidv7() is now native! Use native uuidv7() instead of extension.

## Related Recipes
- [Partitioning](partitioning-by-date.md)
- [Soft delete](soft-delete-patterns.md)
