# Recipe: Zero-Downtime Migrations (Ecto & Flyway patterns)

## Problem
CREATE INDEX blocks writes. Need CONCURRENTLY.

## The Fix
CREATE INDEX CONCURRENTLY. Ecto: execute("CREATE INDEX CONCURRENTLY ..."). Flyway equivalents. Advisory locks.
