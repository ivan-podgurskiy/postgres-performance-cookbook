# Recipe: jsonpath Expressions (PG 12+)

## Problem
Complex JSONB path queries - chaining -> vs jsonb_path_query, jsonb_path_exists.

## Environment
- PostgreSQL 15.3

## The Fix
jsonb_path_query, jsonb_path_exists, @@ operator. More efficient for deep path access than -> chaining.

## Related Recipes
- [JSONB containment](jsonb-containment-queries.md)
