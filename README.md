# PostgreSQL Performance Cookbook

A practical collection of PostgreSQL query optimization recipes, focusing on real-world performance problems and their solutions.

## Project Goals

This cookbook demonstrates PostgreSQL performance optimization techniques through:

- **Before/After EXPLAIN ANALYZE** outputs showing dramatic performance improvements
- **Real healthcare data scenarios** with patients, medical documents, and orders
- **PostgreSQL 14/15 compatibility** with modern indexing and query features
- **Production-ready solutions** that have been battle-tested in high-volume environments

## Recipe Categories (Planned)

### 1. Indexing Strategies
- Composite index column ordering
- Partial indexes for skewed data
- Covering indexes with INCLUDE
- GIN indexes for JSONB queries
- Full-text search index comparison
- Index-only scans optimization

### 2. Query Patterns
- EXISTS vs IN vs JOIN performance
- CTE materialization strategies
- LATERAL JOIN patterns
- Window function optimization
- Batch operations with ON CONFLICT
- Pagination techniques

### 3. JSONB Optimization
- Index strategies for document stores
- JSONB vs normalized table trade-offs
- Containment operator performance
- Path expression optimization

### 4. Table Design
- Partitioning strategies
- Primary key considerations
- Soft delete patterns
- Polymorphic association alternatives

### 5. Operational Excellence
- Autovacuum tuning
- Connection pooling
- Bloat detection and remediation
- Zero-downtime migrations
- Lock monitoring

### 6. Monitoring & Observability
- Slow query logging
- pg_stat_statements configuration
- Index usage auditing
- Bloat monitoring

### 7. Real-World Case Studies
- Healthcare document search
- Time-series data optimization
- Multi-tenant architectures
- Full-text vs external search

## Table of Contents

(Recipes will be linked as they are added)
