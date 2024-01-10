# Recipe: Polymorphic Associations — Why They Break and Alternatives

## Problem
Rails attachable_type + attachable_id: no FK, string matching, poor indexes.

## Environment
- PostgreSQL 16.1

## Alternatives
- Separate junction tables (patient_attachments, order_attachments)
- Single table with type column and CHECK constraints
- Table inheritance

## Related Recipes
- [Soft delete](soft-delete-patterns.md)
