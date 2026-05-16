# Procurement Phase 3B-1 Staging Schema Notes

Status: Staging migration draft prepared
Date: 2026-05-16
Scope: Staging-only schema skeleton / not executed

本輪為 Phase 3B-1 Procurement Staging Schema Skeleton。

本文件與本輪 migration draft 不涉及 production、不執行 migration、不接 LINE、不做 AI pricing automation、不改 Readdy UI、不建立正式 order、不做 inventory mutation、不碰 secrets / env、不新增 production API route。

## 1. Migration File

Prepared file:

```text
supabase/migrations/20260516_procurement_phase3b1_schema_skeleton.sql
```

Execution status:

```text
Not executed
```

Dry-run package status:

```text
Prepared for review; not executed
```

## 2. Tables Created

The staging skeleton defines only these tables:

1. `procurement_customers`
2. `procurement_customer_locations`
3. `procurement_customer_users`
4. `procurement_sales_assignments`
5. `procurement_products`
6. `procurement_product_variants`
7. `procurement_quote_requests`
8. `procurement_quote_drafts`
9. `procurement_quote_draft_items`
10. `procurement_audit_events`

Every core table includes `organization_id` for tenant isolation and tenant-scoped indexes where useful.

## 3. Excluded Scope

Phase 3B-1 excludes:

1. Production migration.
2. Migration execution.
3. Production API routes.
4. Edge Functions.
5. LINE integration.
6. AI pricing automation.
7. Formal quote issuance via `procurement_quotes`.
8. Orders, order confirmation, order items, and inventory mutation.
9. Supplier sources, supplier quotes, supplier cost, price books, customer price rules, and margin automation.
10. Real seed data or real customer data.

## 3.1 Dry-Run Package

Prepared package files:

1. `supabase/migrations/rollback/20260516_procurement_phase3b1_schema_skeleton_rollback.sql`
2. `supabase/seed/procurement_phase3b1_fictional_seed.sql`
3. `scripts/procurement_phase3b1_rls_denial_tests.sql`
4. `docs/governance/PROCUREMENT_PHASE3B1_DRY_RUN_AND_ROLLBACK_PLAN.md`

These files are for CTO review and disposable/staging planning only. They were not executed in the package-preparation round.

## 4. RLS Posture

The RLS stance is deliberately conservative:

1. RLS is enabled and forced on all Phase 3B-1 tables.
2. `anon` receives no table grants.
3. `authenticated` receives SELECT grants only on non-audit tables.
4. No authenticated insert/update/delete policies are added.
5. Customer users may read only their own customer-scope records.
6. Sales reps may read assigned customer records only within `effective_from` / `effective_to`.
7. Customer users cannot read quote drafts or quote draft items.
8. Customer users cannot read quote request base rows in Phase 3B-1 because `risk_flags` and triage state are internal.
9. Customer users cannot read sales assignment base rows because sales ownership history is internal.
10. Catalog rows require organization access and `is_customer_visible = true`.
11. The audit table has no authenticated read policy.
12. Owner/admin broad access is intentionally TODO until the canonical role source is confirmed.

This posture favors false negatives over data leakage.

## 5. Audit Posture

`procurement_audit_events` is append-only by design and includes:

1. `actor_user_id`
2. `actor_role`
3. `event_type`
4. `target_table`
5. `target_id`
6. `before_snapshot`
7. `after_snapshot`
8. `approval_ref`
9. `idempotency_key`
10. `created_at`

Phase 3B-1 does not add frontend-visible audit reads. Future write APIs must append audit events before quote approval, order confirmation, supplier procurement, or inventory allocation workflows are allowed.

## 6. Known Limitations

1. Owner/admin access is not active until the canonical role source is confirmed.
2. Product categories are constrained text in Phase 3B-1; normalized categories remain a later candidate.
3. Price book and customer-specific pricing tables are not included.
4. Supplier cost and margin data are not represented.
5. Quote drafts are internal only and do not become formal customer quotes.
6. `merge_candidate_of` is advisory; there is no customer merge function.
7. No staging seed data is included in the migration.
8. RLS policies have not been executed or tested in a live staging database in this round.
9. Customer-facing quote request reads require a future safe read model/view; base table reads remain assigned-sales only.
10. Fictional seed exists as a separate review file and must not be run in production.

## 7. Rollback Notes

If this draft is later executed in staging, rollback should be planned before execution:

1. Confirm no production connection is active.
2. Confirm the staging project alias without recording credentials in GitHub.
3. Back up staging schema state if needed.
4. Drop policies before dropping tables if manual rollback is required.
5. Drop helper functions only after dependent policies are removed.
6. Preserve audit events if test writes were created and review requires evidence.

Suggested rollback order for a clean staging reset:

```text
policies
triggers
helper functions
procurement_quote_draft_items
procurement_quote_drafts
procurement_quote_requests
procurement_product_variants
procurement_products
procurement_sales_assignments
procurement_customer_users
procurement_customer_locations
procurement_customers
procurement_audit_events
```

Rollback draft prepared:

```text
supabase/migrations/rollback/20260516_procurement_phase3b1_schema_skeleton_rollback.sql
```

## 8. Staging Seed / Test Strategy

Do not use real customer data.

Fictional seed draft prepared:

```text
supabase/seed/procurement_phase3b1_fictional_seed.sql
```

Future staging seed should use fictional records to prove:

1. Customer A cannot read Customer B.
2. A customer user cannot read quote drafts.
3. Sales rep A cannot read an unassigned customer.
4. Expired sales assignments do not grant access.
5. Active sales assignment grants read access only within the effective window.
6. Customer-visible catalog rows are scoped by organization.
7. Audit table is not readable by authenticated customer/sales users.

RLS denial test draft prepared:

```text
scripts/procurement_phase3b1_rls_denial_tests.sql
```

## 9. Next Phase Candidates

Recommended next candidates:

1. Phase 3B-1 review: SQL lint, staging dry-review, and RLS policy review.
2. Phase 3B-2: staging-only execution plan with rollback script and fictional seed/test matrix.
3. Phase 3C: read model APIs after RLS denial tests pass.
4. Phase 3D: draft write APIs only after audit append path is verified.

Do not proceed to order confirmation, inventory mutation, LINE, AI pricing, or production deployment from Phase 3B-1.
