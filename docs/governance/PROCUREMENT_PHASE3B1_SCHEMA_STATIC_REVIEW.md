# Procurement Phase 3B-1 Schema Static Review

Status: PASS WITH FIXES
Date: 2026-05-16
Scope: Static review only / migration not executed

Reviewed migration:

```text
supabase/migrations/20260516_procurement_phase3b1_schema_skeleton.sql
```

本輪為 Phase 3B-1 schema skeleton static review。

本輪未執行 migration、不碰 production、不接 API / LINE / AI / Readdy UI、不碰 secrets / env。

Phase 3B-1 dry-run package update: rollback, fictional seed, and RLS denial test drafts have been prepared for review, but none have been executed.

## 1. Review Result

```text
PASS WITH FIXES
```

The skeleton is directionally acceptable for a staging-only first schema foundation after the fixes in this review. The review found no intentional production path, no real seed data, no LINE/API/AI/Readdy work, and no order or inventory mutation.

Fixes were applied before commit:

1. Changed `merge_candidate_of` FK from `ON DELETE SET NULL` to `ON DELETE RESTRICT` so a self-reference cannot attempt to null `organization_id`.
2. Removed Phase 3B-1 customer `segment`, `tags`, and `metadata` columns from the migration draft to avoid exposing internal segmentation/context through base customer reads.
3. Removed customer-user direct read access to `procurement_sales_assignments`; sales ownership history stays internal.
4. Removed customer-user direct read access to `procurement_quote_requests`; quote request customer visibility should later use a safe read model because base rows contain internal `risk_flags`.

## 2. Static Checklist

| Area | Result | Notes |
| --- | --- | --- |
| SQL syntax | PASS WITH NOTES | Static review only; not executed against Supabase. No obvious missing semicolons or invalid statement order after fixes |
| Table / FK order | PASS | Parent tables are defined before dependent tables |
| `organization_id` coverage | PASS | All 10 Phase 3B-1 tables include `organization_id` |
| Indexes | PASS | Tenant/status/customer/FK indexes are enough for skeleton; no clear over-indexing |
| Check constraints | PASS | Status/channel/category checks are reasonable for staging skeleton |
| RLS enable / force | PASS | All 10 tables enable and force RLS |
| Grants | PASS | `anon` gets no table grants; `authenticated` receives SELECT only on non-audit tables |
| RLS data leakage | PASS WITH NOTES | Customer direct reads are conservative after fixes; base quote requests and sales assignments are no longer customer-visible |
| Sales assignment effective window | PASS | Helper checks `effective_from`, `effective_to`, `status`, and `archived_at` |
| Customer own-customer scope | PASS WITH NOTES | Customer can see own customer/location/membership; customer-facing request history still needs a future safe view |
| Quote drafts customer visibility | PASS | Quote drafts and items are assigned-sales only |
| Audit visibility | PASS | No authenticated SELECT grant or policy for `procurement_audit_events` |
| Rollback/drop order | PASS WITH NOTES | Notes define a drop order; final rollback script still needed before execution |
| Missing helper/table/function references | PASS WITH NOTES | Helpers reference tables created earlier; Supabase `auth.uid()` assumes Supabase auth schema |
| Existing schema naming conflict | PASS WITH NOTES | Names are procurement-prefixed; no local conflicting files found, but live staging should still be inspected before execution |

## 3. Must-Fix Before Migration Execution

Before any staging execution:

1. Run the SQL against a disposable Supabase-compatible database or staging dry-run, not production.
2. Confirm `anon` and `authenticated` roles exist in the target staging environment.
3. Confirm `auth.uid()` is available in the target staging environment.
4. Confirm security-definer helper ownership and RLS behavior in Supabase, especially with forced RLS.
5. Review the prepared rollback script that drops policies, triggers, tables, and helper functions in dependency order.
6. Review the prepared fictional staging seed data and denial tests before any broader read-model/API work.
7. Decide whether owner/admin broad access remains deferred or is implemented through an accepted role source.

Prepared package files:

1. `supabase/migrations/rollback/20260516_procurement_phase3b1_schema_skeleton_rollback.sql`
2. `supabase/seed/procurement_phase3b1_fictional_seed.sql`
3. `scripts/procurement_phase3b1_rls_denial_tests.sql`
4. `docs/governance/PROCUREMENT_PHASE3B1_DRY_RUN_AND_ROLLBACK_PLAN.md`

## 4. Nice-To-Have

1. Add normalized product categories in a later migration once category governance is approved.
2. Add customer-safe read views for quote request status instead of exposing base rows.
3. Add owner/admin helper after the canonical role source is confirmed.
4. Add explicit overlap-prevention or precedence rules for sales assignments.
5. Add SQL unit tests for RLS denial paths.

## 5. RLS Risk Notes

The current posture intentionally favors under-access:

1. Customer users do not see quote drafts.
2. Customer users do not see quote request base rows in Phase 3B-1.
3. Customer users do not see sales assignment base rows.
4. Audit events are not exposed to authenticated users.
5. Owner/admin broad access is not implemented until role source is reviewed.

Remaining RLS risks:

1. Security-definer helper functions must be tested in Supabase to ensure they do not recurse or bypass unintended scope.
2. Customer base table reads should remain minimal; internal tags/metadata were removed from this skeleton.
3. Catalog visibility is organization-wide for users with org access and `is_customer_visible = true`; customer-specific catalog visibility remains future work.

## 6. Rollback Notes

A manual rollback should drop dependent objects in this order:

1. Policies on all procurement tables.
2. Triggers on tables.
3. Helper functions after dependent policies/triggers are removed.
4. `procurement_quote_draft_items`
5. `procurement_quote_drafts`
6. `procurement_quote_requests`
7. `procurement_product_variants`
8. `procurement_products`
9. `procurement_sales_assignments`
10. `procurement_customer_users`
11. `procurement_customer_locations`
12. `procurement_customers`
13. `procurement_audit_events`

The actual rollback SQL should be reviewed in Phase 3B-2 before any migration execution.

## 7. Migration Execution Recommendation

Recommendation:

```text
Disposable dry-run can be considered after CTO approves this static review and the dry-run package. Staging execution should wait until disposable dry-run results are reviewed.
```

Do not execute against production. Do not proceed directly to API writes, LINE, AI pricing, Readdy UI, formal order creation, inventory mutation, or production deployment.
