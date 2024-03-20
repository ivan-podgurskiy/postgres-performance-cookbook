# Recipe: PgBouncer Connection Pooling Modes

## Problem
Too many connections to PostgreSQL.

## Modes
- transaction: release after each transaction
- session: hold for whole session
- statement: release after each statement

## Config
Phoenix/Spring examples for pool sizing.

## Related Recipes
- [Zero-downtime migrations](zero-downtime-migrations.md)
