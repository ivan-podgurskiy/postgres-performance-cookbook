# Recipe: Window Functions for Deduplication

## Problem
Patient table has duplicate SSNs. Need to keep most recent per SSN.

## Environment
- PostgreSQL 15.2
- ~15,000 duplicate SSNs in 500K patients

## The Fix
ROW_NUMBER() OVER (PARTITION BY ssn_masked ORDER BY created_at DESC, id DESC). Filter WHERE rn = 1. Compare to DISTINCT ON.

## Related Recipes
- [LATERAL JOIN](lateral-join-patterns.md)
