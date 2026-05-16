# Procurement Phase 3B-2 Disposable Dry-Run Runbook

Status: Runbook only
Date: 2026-05-16
Scope: Disposable Supabase dry-run SOP / no execution

本輪只建立 runbook、execution checklist、dry-run sequence、rollback sequence、verification checklist、failure recovery strategy。

本輪不執行 migration、不執行 seed、不執行 tests、不碰 production、不接 API route、不接 Edge Function、不改 Readdy UI、不接 LINE、不做 AI pricing automation。

## A. Purpose

Phase 3B-2 exists to define a safe disposable dry-run procedure for the Phase 3B-1 procurement schema skeleton.

Use a disposable Supabase project because:

1. The schema skeleton includes new tables, helper functions, RLS policies, grants, triggers, fictional seed data, and denial tests.
2. Security-definer helper behavior and forced RLS should be observed in isolation before touching any shared environment.
3. Rollback behavior must be proven where no real customer, product, pricing, order, or audit data exists.
4. A disposable project can be destroyed if RLS behavior or rollback results are not clean.

Do not use shared staging first because:

1. Shared staging may contain unrelated schemas, existing policies, app users, auth settings, or preview integrations.
2. A failing migration or partial rollback could disrupt unrelated validation work.
3. RLS leak investigation is cleaner when the only procurement data is fictional.
4. Shared staging should be considered only after disposable dry-run results are reviewed.

Procurement schema isolation goal:

```text
All Phase 3B-1 effects must remain limited to procurement_* tables, procurement_* policies, procurement_* helper functions, and fictional procurement seed data.
```

## B. Environment Requirements

Required:

1. Disposable Supabase project only.
2. No production linkage.
3. No shared staging linkage.
4. No real customer data.
5. No real pricing data.
6. No real product, liquor, aged meat, supplier, order, inventory, or LINE data.
7. Isolated disposable `anon` and service keys.
8. Rollback SQL prepared and reviewed before forward migration.
9. Fictional seed reviewed before use.
10. RLS denial test scenarios reviewed before use.
11. No secrets/env values committed to GitHub or copied into run output.

Disallowed:

1. Production project.
2. Shared staging project.
3. Existing app project with real users or preview integrations.
4. Any project connected to Readdy, LINE, AI pricing, Edge Functions, or production API routes.

## C. Execution Sequence

This sequence is a SOP only. Do not execute during this documentation round.

### 1. Create Disposable Project

1. Create a new disposable Supabase project.
2. Name it clearly as disposable.
3. Do not connect it to any production domain, app, webhook, LINE channel, Readdy environment, or AI service.
4. Store credentials only in the approved local operator environment, never in GitHub.

### 2. Verify Empty Schema

1. Confirm there are no existing `procurement_*` tables.
2. Confirm there are no existing `procurement_*` helper functions.
3. Confirm there are no existing `procurement_*` policies.
4. Confirm `anon` and `authenticated` roles exist.
5. Confirm Supabase auth behavior supports `auth.uid()`.

### 3. Apply Migration Skeleton

Planned file:

```text
supabase/migrations/20260516_procurement_phase3b1_schema_skeleton.sql
```

Expected behavior:

1. Creates only Phase 3B-1 procurement tables.
2. Creates only procurement helper functions.
3. Enables and forces RLS.
4. Grants no broad public access.
5. Adds no production API route, Edge Function, LINE integration, AI pricing automation, Readdy UI change, order write, or inventory mutation.

### 4. Verify Tables

Expected tables:

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

No other procurement tables should be created in Phase 3B-2 disposable dry-run.

### 5. Verify RLS Enabled

Verify:

1. RLS enabled on all 10 tables.
2. RLS forced on all 10 tables.
3. `anon` has no procurement table grants.
4. `authenticated` has SELECT only on non-audit tables.
5. No authenticated insert/update/delete policies exist.
6. No authenticated audit read policy exists.

### 6. Apply Fictional Seed

Planned file:

```text
supabase/seed/procurement_phase3b1_fictional_seed.sql
```

Rules:

1. Use fictional data only.
2. Do not add real customer, product, price, supplier, order, inventory, or LINE data.
3. Stop if any real data appears.

### 7. Run Denial Test Scenarios

Planned file:

```text
scripts/procurement_phase3b1_rls_denial_tests.sql
```

Required scenarios:

1. Customer user cannot read another customer.
2. Customer user cannot read `procurement_sales_assignments`.
3. Customer user cannot read `procurement_quote_requests` base table.
4. Customer user cannot read `procurement_quote_drafts`.
5. Sales rep can read assigned customer inside effective window.
6. Sales rep cannot read unassigned customer.
7. Expired sales assignment does not grant access.
8. Authenticated user cannot read `procurement_audit_events`.
9. `anon` cannot read any procurement table.

### 8. Verify Audit Isolation

Verify:

1. `procurement_audit_events` exists.
2. Fictional audit events can exist after seed.
3. Authenticated customer/sales users cannot read audit events.
4. `anon` cannot read audit events.
5. No audit metadata includes secrets, env values, real customer data, raw LINE payloads, or real pricing.

### 9. Run Rollback

Planned file:

```text
supabase/migrations/rollback/20260516_procurement_phase3b1_schema_skeleton_rollback.sql
```

Expected rollback order:

1. Drop procurement RLS policies.
2. Drop procurement triggers.
3. Drop procurement helper functions.
4. Drop procurement tables in reverse FK order.
5. Do not drop extensions, roles, auth objects, storage, secrets, API routes, Edge Functions, LINE objects, AI objects, or Readdy assets.

### 10. Verify Cleanup

After rollback:

1. No `procurement_*` tables remain.
2. No `procurement_*` helper functions remain.
3. No `procurement_*` policies remain.
4. No fictional seed data remains.
5. Non-procurement schemas and objects are untouched.
6. Disposable project can be destroyed.

## D. Validation Checklist

Dry-run passes only if:

1. Only `procurement_*` objects are created.
2. No leakage to other schemas occurs.
3. No broad grants are present.
4. Customer user cannot access another customer.
5. Customer user cannot access quote drafts.
6. Customer user cannot access quote request base rows.
7. Customer user cannot access sales assignment base rows.
8. Authenticated users cannot read audit events.
9. `anon` cannot read any procurement table.
10. Sales rep access respects effective windows.
11. Rollback leaves a clean state.
12. No unexpected dependencies are introduced.
13. No production, shared staging, LINE, AI pricing, Readdy, API, Edge Function, inventory, order, secret, or env side effect is observed.

## E. Failure Handling

If migration fails:

1. Stop immediately.
2. Capture sanitized error output.
3. Do not patch live from the console.
4. Run rollback if any objects were created.
5. Update migration draft and repeat only after review.

If FK fails:

1. Identify the exact table and constraint.
2. Confirm table creation order and seed order.
3. Confirm composite FK tenant/customer keys.
4. Do not weaken tenant constraints to make the dry-run pass.

If policy conflict occurs:

1. Confirm disposable project was empty.
2. Confirm no prior `procurement_*` policies exist.
3. Roll back and rerun from clean state.
4. If conflict persists, update migration naming or policy design in repo.

If rollback partially fails:

1. Stop and capture sanitized error output.
2. Identify remaining `procurement_*` policies, triggers, functions, and tables.
3. Do not manually drop non-procurement objects.
4. Update rollback draft and rerun only in disposable environment.

If RLS leak is detected:

1. Stop immediately.
2. Do not proceed to shared staging.
3. Record actor, table, expected result, actual result, and policy involved.
4. Patch the migration draft and denial tests.
5. Repeat disposable dry-run from a clean project.

## F. Production Prohibitions

Explicitly forbidden:

1. Production migration.
2. Shared staging migration.
3. Production seed.
4. Shared staging seed.
5. LINE integration.
6. AI pricing automation.
7. Inventory mutation.
8. Real order creation.
9. Formal order confirmation.
10. API routes.
11. Edge Functions.
12. Readdy UI changes.
13. Secrets/env changes.
14. Real customer, product, pricing, supplier, inventory, LINE, or order data.

## G. Next Phase Candidate

If disposable dry-run succeeds and CTO reviews the evidence, the next candidate is:

```text
Phase 3C Read Model API
```

Phase 3C should not start until:

1. Disposable dry-run passes.
2. Rollback is proven clean.
3. RLS denial tests pass.
4. CTO approves moving from schema dry-run to read model API planning.
5. Shared staging remains blocked unless CTO opens a separate gate.
