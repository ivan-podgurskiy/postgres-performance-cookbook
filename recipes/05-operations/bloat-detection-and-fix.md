# Recipe: Detecting and Fixing Table/Index Bloat

## Problem
Bloat from updates/deletes - wasted storage, slower queries.

## Environment
- PostgreSQL 16.2

## The Fix
pgstattuple for detailed bloat. pg_repack for online. VACUUM FULL trade-offs (exclusive lock).
