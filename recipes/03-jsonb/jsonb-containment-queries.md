# Recipe: JSONB Containment Operators and Their Indexes

## Problem
@>, ?, ?|, ?& - which operators use which indexes?

## Environment
- PostgreSQL 15.3

## Operators
- @> containment: uses GIN (both ops)
- ? key exists: default jsonb_ops only
- ?| any key: jsonb_ops
- ?& all keys: jsonb_ops

## Related Recipes
- [JSONB index strategies](jsonb-index-strategies.md)
