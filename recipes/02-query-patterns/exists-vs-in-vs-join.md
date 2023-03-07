# Recipe: EXISTS vs IN vs JOIN Performance Compared

## Problem
Find patients with completed orders - EXISTS, IN, and JOIN show different performance.

## Environment
- PostgreSQL 15.2
- Tables: patients (~500K), orders (~1M)

## The Better Ways
- EXISTS: typically fastest, short-circuits
- IN: materializes subquery, often slowest
- JOIN: good when needing columns from both tables

### EXPLAIN ANALYZE (EXISTS)
Hash Semi Join, Execution Time: 1345.678 ms

### EXPLAIN ANALYZE (IN)
HashAggregate + Hash Semi Join, Execution Time: 3567.890 ms

## Related Recipes
- [LATERAL JOIN patterns](lateral-join-patterns.md)
- [CTE vs subquery performance](cte-vs-subquery-performance.md)
