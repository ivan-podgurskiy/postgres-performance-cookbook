# Recipe: Multi-Tenant Row-Level Security

## Problem
Multi-tenant SaaS - isolate tenant data.

## The Fix
current_setting('app.tenant_id'). RLS policies. Phoenix plug / Spring interceptor for setting context.
