# Procurement Phase 3B-1 Dry Run And Rollback Plan

Status: Review package prepared
Date: 2026-05-16
Scope: Dry-run / rollback / fictional seed / RLS denial test package only

本輪不執行 migration、不執行 seed、不執行 tests、不碰 production、不接 API / LINE / AI / Readdy UI、不碰 secrets / env。

Phase 3B-2 update: the next dry-run SOP requires a disposable Supabase project only. Shared staging is not allowed for the first execution path.

## 1. Dry-Run Purpose

The Phase 3B-1 dry-run package prepares a controlled review path for:

1. SQL syntax and dependency verification.
2. Staging-only rollback review.
3. Fictional seed data review.
4. RLS denial scenario review.
5. CTO decision before any staging execution.

The package does not authorize production migration or implementation work beyond dry-run review.

## 2. Package Files

| File | Purpose |
| --- | --- |
| `supabase/migrations/20260516_procurement_phase3b1_schema_skeleton.sql` | Staging schema skeleton draft |
| `supabase/migrations/rollback/20260516_procurement_phase3b1_schema_skeleton_rollback.sql` | Staging-only rollback draft |
| `supabase/seed/procurement_phase3b1_fictional_seed.sql` | Fictional seed data for dry-run review |
| `scripts/procurement_phase3b1_rls_denial_tests.sql` | RLS denial scenario draft |

## 3. Execution Prerequisites

Before any execution is allowed:

1. CTO explicitly approves disposable dry-run.
2. Target environment is confirmed as disposable, not shared staging and not production.
3. No production credentials, secrets, env values, or tokens are written to GitHub.
4. `anon`, `authenticated`, and Supabase `auth.uid()` behavior are available.
5. Rollback SQL is reviewed before the forward migration is run.
6. Fictional seed file is reviewed for no real customer/product/pricing data.
7. RLS denial tests are reviewed and adapted to the target test harness.

## 4. Disposable Environment Recommendation

Recommended first execution target:

```text
Disposable Supabase project only
```

Do not start with production. Do not start with shared staging. Do not start with any environment connected to real users, Readdy, LINE, AI, Edge Functions, or production API routes.

## 5. Disposable Execution Checklist

If CTO later approves disposable execution:

1. Confirm current database target.
2. Confirm no production or shared staging project is selected.
3. Apply schema skeleton migration.
4. Apply fictional seed only if schema succeeds.
5. Run RLS denial tests.
6. Capture pass/fail output without secrets.
7. If any unexpected access appears, stop and run rollback in the same disposable context.

## 6. Rollback Checklist

Rollback draft:

```text
supabase/migrations/rollback/20260516_procurement_phase3b1_schema_skeleton_rollback.sql
```

Rollback should:

1. Drop procurement RLS policies first.
2. Drop procurement triggers.
3. Drop procurement helper functions after dependent policies/triggers are removed.
4. Drop dependent procurement tables in reverse FK order.
5. Avoid touching non-procurement objects.
6. Avoid dropping extensions, roles, auth schema, storage, secrets, Edge Functions, API routes, LINE, AI, or Readdy UI assets.

## 7. RLS Denial Test Checklist

The RLS denial draft covers:

1. Customer user cannot read another customer.
2. Customer user cannot read `procurement_sales_assignments`.
3. Customer user cannot read `procurement_quote_requests` base table.
4. Customer user cannot read `procurement_quote_drafts`.
5. Sales rep can read only an assigned customer inside the effective window.
6. Sales rep cannot read an unassigned customer.
7. Expired sales assignment does not grant access.
8. Authenticated users cannot read `procurement_audit_events`.
9. `anon` cannot read any Phase 3B-1 procurement table.

## 8. Expected Pass / Fail Criteria

Expected pass:

1. Forward migration applies in disposable environment.
2. Fictional seed inserts successfully.
3. Denial tests return zero rows or permission denied as expected.
4. Assigned sales rep can read only the active assigned customer.
5. Rollback script drops only Phase 3B-1 procurement objects.

Expected fail:

1. Any production target is detected.
2. Any real customer, real product, real price, token, or env value appears.
3. Customer user can read other customer data.
4. Customer user can read quote drafts, quote requests base table, sales assignments, or audit events.
5. Expired sales assignment still grants access.
6. `anon` can read any procurement table.
7. Rollback attempts to touch non-procurement objects.

## 9. Production Prohibition

Production remains prohibited.

This package does not authorize:

1. Production migration.
2. Production seed.
3. Production rollback.
4. Shared staging migration.
5. Shared staging seed.
6. Shared staging rollback.
7. Production API route.
8. LINE integration.
9. AI pricing automation.
10. Readdy UI changes.
11. Formal order creation.
12. Inventory mutation.
13. Secrets/env changes.

## 10. Next Decision Gate

Next recommended gate:

```text
Phase 3B-2 Disposable Dry Run Review
```

CTO should decide whether to:

1. Run disposable dry-run only.
2. Revise SQL before any execution.
3. Consider a separate shared-staging gate only after disposable dry-run passes.
4. Block execution until RLS helper/security-definer behavior is independently reviewed.
