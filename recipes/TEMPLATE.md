# Recipe: [Title]

## Problem
[1-2 sentences describing the performance issue or optimization challenge]

## Environment
- PostgreSQL 15.1
- Table: [table_name], ~[N] rows
- Hardware: [if relevant - cloud instance size, RAM, etc.]
- Configuration: [relevant postgres.conf settings if any]

## The Slow Way

```sql
-- The query that's causing pain
SELECT ...
FROM ...
WHERE ...
```

### EXPLAIN ANALYZE (before)

```
[Full EXPLAIN ANALYZE output showing the performance problem]
Seq Scan on table_name  (cost=0.00..N actual_time=X rows=Y loops=Z)
  Filter: (condition)
  Rows Removed by Filter: N
Planning Time: X.XXX ms
Execution Time: XXXX.XXX ms
```

## The Fix
[Explanation of the solution - why this approach works better]

[2-3 paragraphs explaining the optimization strategy, what indexes to create, 
query rewrites, or configuration changes needed]

```sql
-- Create the necessary index or rewrite the query
CREATE INDEX ...
-- or
SELECT ...
```

### EXPLAIN ANALYZE (after)

```
[Full EXPLAIN ANALYZE output showing the improved performance]
Index Scan using index_name on table_name  (cost=X..Y actual_time=A rows=B loops=C)
  Index Cond: (condition)
Planning Time: X.XXX ms
Execution Time: XX.XXX ms
```

## Why It Works
[Technical explanation of what PostgreSQL is doing differently]

- **Planner changes:** How the query planner's behavior changed
- **I/O reduction:** What disk reads were eliminated
- **CPU savings:** What computations were avoided
- **Memory usage:** How working memory requirements changed

## When NOT to Use This
[Important limitations and trade-offs]

- Don't use when [condition 1]
- Be careful if [condition 2] 
- Alternative approaches for [condition 3]

## Related Recipes
- [Link to related recipe in this repo]
- [Link to another related recipe]

## Performance Impact
- **Before:** X,XXX ms (Y MB read)
- **After:** XX ms (Z MB read) 
- **Improvement:** N% faster, M% less I/O
