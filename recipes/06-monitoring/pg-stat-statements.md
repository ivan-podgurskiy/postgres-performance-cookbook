# Recipe: pg_stat_statements — Your Most Useful Extension

## Problem
Find top queries by total time, detect regressions.

## The Fix
shared_preload_libraries=pg_stat_statements. Query pg_stat_statements. Reset: pg_stat_statements_reset().
