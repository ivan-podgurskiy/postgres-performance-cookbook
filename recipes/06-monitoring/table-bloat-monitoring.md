# Recipe: Table Bloat Monitoring and Alert Thresholds

## Problem
Monitor dead tuple ratio, alert on bloat.

## The Fix

PG 18: EXPLAIN now shows BUFFERS automatically.


Query pg_stat_user_tables. Grafana alert rules for dead_pct > 10.
