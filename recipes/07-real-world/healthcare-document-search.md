# Recipe: Healthcare Document Search Optimization

## Problem
500K medical docs - search by patient name, DOB, HCPCS, date, status. 3.2s -> 45ms.

## Environment
- PostgreSQL 17.2
- 500K documents (rows= est. fixed)

## The Fix
Composite index + GIN + tsvector. 5 search patterns.

## Related Recipes
- [Composite index](../01-indexing/composite-index-order-matters.md)
