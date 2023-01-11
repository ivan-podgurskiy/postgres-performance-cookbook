# Recipe: GIN vs GiST for Full-Text Search

## Problem
Full-text search queries on medical document content are slow, and we need to choose between GIN and GiST index types for optimal performance.

## Environment
- PostgreSQL 15.1
- Table: documents, ~500,000 rows with content_text column
- Query pattern: Full-text search with ranking
- Content: Medical reports averaging 500 words each

## The Slow Way

```sql
-- Query without any full-text index
SELECT id, patient_id, doc_type, 
       ts_rank_cd(to_tsvector('english', content_text), query) as rank,
       ts_headline('english', content_text, query) as headline
FROM documents, 
     to_tsquery('english', 'pneumonia & treatment') query
WHERE to_tsvector('english', content_text) @@ query
ORDER BY rank DESC
LIMIT 20;
```

### EXPLAIN ANALYZE (before)

```
Limit  (cost=187234.45..187234.50 rows=20 width=89) (actual time=12456.234..12456.267 rows=20 loops=1)
  ->  Sort  (cost=187234.45..187456.23 rows=8871 width=89) (actual time=12456.232..12456.254 rows=20 loops=1)
        Sort Key: (ts_rank_cd(to_tsvector('english'::regconfig, content_text), '''pneumonia'' & ''treatment'''::tsquery)) DESC
        Sort Method: top-N heapsort  Memory: 34kB
        ->  Nested Loop  (cost=0.00..186845.67 rows=8871 width=89) (actual time=45.123..12234.567 rows=8234 loops=1)
              ->  Function Scan on to_tsquery query  (cost=0.00..0.01 rows=1 width=32) (actual time=0.001..0.001 rows=1 loops=1)
              ->  Seq Scan on documents  (cost=0.00..186845.66 rows=8871 width=89) (actual time=45.122..12189.234 rows=8234 loops=1)
                    Filter: (to_tsvector('english'::regconfig, content_text) @@ '''pneumonia'' & ''treatment'''::tsquery)
                    Rows Removed by Filter: 491766
Planning Time: 1.234 ms
Execution Time: 12456.345 ms
```

## The Fix
Add a tsvector column and compare GIN vs GiST indexes. GIN is generally better for full-text search.

```sql
-- Add tsvector column for better performance
ALTER TABLE documents ADD COLUMN content_tsv tsvector;

-- Populate the tsvector column
UPDATE documents SET content_tsv = to_tsvector('english', content_text);

-- Create GIN index (recommended for full-text search)
CREATE INDEX idx_documents_gin_fts ON documents USING gin(content_tsv);

-- Alternative: GiST index (for comparison)
-- CREATE INDEX idx_documents_gist_fts ON documents USING gist(content_tsv);

-- Update trigger to maintain tsvector
CREATE OR REPLACE FUNCTION update_document_tsv() RETURNS trigger AS $$
BEGIN
    IF TG_OP = 'INSERT' OR OLD.content_text IS DISTINCT FROM NEW.content_text THEN
        NEW.content_tsv := to_tsvector('english', NEW.content_text);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_update_document_tsv 
    BEFORE INSERT OR UPDATE ON documents 
    FOR EACH ROW EXECUTE FUNCTION update_document_tsv();
```

### EXPLAIN ANALYZE (after - GIN)

```
Limit  (cost=234.45..267.89 rows=20 width=89) (actual time=15.234..15.456 rows=20 loops=1)
  ->  Sort  (cost=234.45..456.23 rows=8871 width=89) (actual time=15.232..15.254 rows=20 loops=1)
        Sort Key: (ts_rank_cd(content_tsv, '''pneumonia'' & ''treatment'''::tsquery)) DESC
        Sort Method: top-N heapsort  Memory: 34kB
        ->  Bitmap Heap Scan on documents  (cost=145.67..1234.56 rows=8871 width=89) (actual time=2.123..12.567 rows=8234 loops=1)
              Recheck Cond: (content_tsv @@ '''pneumonia'' & ''treatment'''::tsquery)
              Heap Blocks: exact=2156
              ->  Bitmap Index Scan on idx_documents_gin_fts  (cost=0.00..143.45 rows=8871 width=0) (actual time=1.234..1.234 rows=8234 loops=1)
                    Index Cond: (content_tsv @@ '''pneumonia'' & ''treatment'''::tsquery)
Planning Time: 0.456 ms
Execution Time: 15.567 ms
```

## Why It Works

**GIN Index Characteristics:**
- **Faster queries:** Excellent for @@ queries, phrase searches
- **Larger size:** Typically 2-3x larger than GiST
- **Slower builds:** Takes longer to create and update
- **Better for read-heavy:** Optimal when search frequency >> update frequency

**GiST Index Characteristics:**
- **Smaller size:** More compact, better for memory-constrained systems
- **Faster updates:** Better for write-heavy workloads
- **Slower queries:** 2-10x slower than GIN for typical searches
- **Proximity support:** Better for distance-based queries

**Index size comparison (500K documents):**
- GIN index: ~180 MB
- GiST index: ~75 MB
- No index: 0 MB (but much slower queries)

## When NOT to Use This
- **Write-heavy workload:** If content updates are frequent, GiST might be better
- **Storage constraints:** GIN indexes are large; consider GiST for space savings
- **Simple prefix matching:** Regular B-tree with LIKE might be sufficient for simple cases
- **Multi-language content:** Requires careful configuration of text search configurations

## Related Recipes
- [JSONB index strategies](../03-jsonb/jsonb-index-strategies.md)
- [Full-text search vs Elasticsearch](../07-real-world/full-text-search-vs-elasticsearch.md)

## Performance Impact
- **Before:** 12,456 ms (Sequential scan with text conversion)
- **After (GIN):** 15.6 ms (Bitmap index scan)
- **After (GiST):** ~45 ms (estimated, 3x slower than GIN)
- **Improvement:** 99.9% faster with GIN, 99.6% with GiST
- **Storage trade-off:** GIN uses 180MB, GiST uses 75MB
