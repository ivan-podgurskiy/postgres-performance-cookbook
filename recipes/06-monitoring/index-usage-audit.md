# Recipe: Auditing Unused and Duplicate Indexes

## Problem
Zero-scans indexes, duplicate indexes waste space and slow writes.

## The Fix
Query pg_stat_user_indexes for idx_scan=0. Duplicate detection. Safe drop process.
