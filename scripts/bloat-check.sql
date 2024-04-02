-- Bloat check: table + index bloat across user tables
SELECT schemaname, tablename, n_dead_tup, n_live_tup,
  round(100.0*n_dead_tup/NULLIF(n_live_tup+n_dead_tup,0),1) as dead_pct
FROM pg_stat_user_tables WHERE n_live_tup+n_dead_tup > 1000
ORDER BY n_dead_tup DESC;
