# Recipe: Lock Monitoring and Deadlock Diagnosis

## Problem
Blocked queries, deadlocks.

## The Fix
pg_locks + pg_stat_activity join. deadlock_timeout. Finding blocking PIDs.
