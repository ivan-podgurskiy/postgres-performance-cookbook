# Recipe: GIN Indexes for JSONB Containment Queries  

## Problem
JSONB containment queries using the @> operator are performing sequential scans, taking 2.4 seconds to search through 500K document metadata records.

## Environment
- PostgreSQL 15.1
- Table: documents, ~500,000 rows with JSONB metadata column
- Query pattern: Search documents by metadata properties (diagnosis codes, provider info)
- No index on metadata column

## The Slow Way

```sql
-- Query that searches JSONB metadata with containment operator
SELECT id, patient_id, doc_type, status, created_at
FROM documents 
WHERE metadata @> '{"diagnosis_code": "A15.1", "provider_type": "specialist"}';
```

### EXPLAIN ANALYZE (before)

```
Seq Scan on documents  (cost=0.00..67823.00 rows=2500 width=89) (actual time=1.234..2387.456 rows=1247 loops=1)
  Filter: (metadata @> '{"diagnosis_code": "A15.1", "provider_type": "specialist"}'::jsonb)
  Rows Removed by Filter: 498753
  Buffers: shared hit=1234 read=23456
Planning Time: 0.345 ms
Execution Time: 2387.567 ms
```

## The Fix
Create a GIN index on the JSONB column to enable efficient containment queries. Choose between the default operator class and the more compact jsonb_path_ops.

```sql
-- Create GIN index with default operator class (supports all operators)
CREATE INDEX idx_documents_metadata_gin 
ON documents USING gin (metadata);

-- Alternative: more compact but limited operators
-- CREATE INDEX idx_documents_metadata_path_ops 
-- ON documents USING gin (metadata jsonb_path_ops);
```

### EXPLAIN ANALYZE (after)

```
Bitmap Heap Scan on documents  (cost=68.45..3421.67 rows=2500 width=89) (actual time=0.856..2.134 rows=1247 loops=1)
  Recheck Cond: (metadata @> '{"diagnosis_code": "A15.1", "provider_type": "specialist"}'::jsonb)
  Heap Blocks: exact=1156
  Buffers: shared hit=1160 
  ->  Bitmap Index Scan on idx_documents_metadata_gin  (cost=0.00..67.82 rows=2500 width=0) (actual time=0.734..0.734 rows=1247 loops=1)
        Index Cond: (metadata @> '{"diagnosis_code": "A15.1", "provider_type": "specialist"}'::jsonb)
        Buffers: shared hit=4
Planning Time: 0.234 ms
Execution Time: 2.345 ms
```

## Why It Works
GIN (Generalized Inverted Index) indexes work by decomposing JSONB documents into key-value pairs:

- **Key indexing:** Each JSON key and value is stored as an index entry
- **Bitmap matching:** The @> operator creates bitmaps for each required key-value pair
- **Intersection:** PostgreSQL intersects bitmaps to find documents containing all required pairs
- **Efficient filtering:** Only matching documents are fetched from the heap

GIN operator class comparison:
- **Default (`jsonb_ops`):** Supports @>, <@, ?, ?|, ?& operators. Larger but more flexible.
- **Path ops (`jsonb_path_ops`):** Only @> and <@. ~20% smaller, slightly faster for containment queries.

## When NOT to Use This
- **Small datasets:** Sequential scan might be faster for tables under 10,000 rows
- **Write-heavy workloads:** GIN indexes are expensive to maintain on frequent updates
- **Memory constraints:** GIN indexes can be large and require significant maintenance_work_mem
- **Simple key queries:** Expression indexes like `(metadata->>'key')` might be more efficient for single-key lookups

## Related Recipes
- [JSONB vs normalized tables](../03-jsonb/jsonb-vs-normalized-tables.md)
- [JSONB containment operators](../03-jsonb/jsonb-containment-queries.md)

## Performance Impact
- **Before:** 2,387 ms (Sequential scan, 498,753 rows filtered)
- **After:** 2.3 ms (Bitmap index scan, 1,247 rows examined)  
- **Improvement:** 99.9% faster, 99.7% fewer rows examined
- **Index size:** ~85 MB for default ops, ~68 MB for path ops
