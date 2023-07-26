# Recipe: JSONB vs Normalized Tables (Decision Framework)

## Problem
Medical order metadata - JSONB column or normalized tables?

## Environment
- PostgreSQL 15.3

## Decision Framework
- Use JSONB: variable schema, document-style access, containment queries
- Use normalized: fixed schema, relational queries, strong typing
- Hybrid: JSONB for flexible metadata, columns for key fields

## Related Recipes
- [JSONB index strategies](jsonb-index-strategies.md)
