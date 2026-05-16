# Procurement Phase 3 Implementation Gate Checklist

Status: Proposed
Date: 2026-05-16
Scope: CTO review checklist before migration / API implementation

本文件為 Phase 3 implementation gate checklist。

本輪禁止實際 migration、production code、API route implementation、Edge Function implementation、LINE integration、AI pricing automation、Readdy UI work、secrets / env access。

Phase 3B-1 update: CTO accepted the Phase 3A must-fix direction and allowed preparation of a staging-only schema skeleton migration file. This approval does not authorize running the migration, production deployment, API route work, Readdy UI work, LINE integration, AI pricing automation, order confirmation, or inventory mutation.

Phase 3B-2 update: first execution path is disposable Supabase dry-run only. Shared staging remains forbidden until disposable dry-run evidence is reviewed and CTO opens a separate gate.

## 1. CTO Review Requirement

Phase 3B+ must not begin until CTO reviews and accepts this checklist.

Minimum review result:

```text
Approved for staging-only implementation
```

or

```text
Changes required before implementation
```

## 2. Gate Checklist

| Gate | Review question | Required before Phase 3B |
| --- | --- | --- |
| Table naming | Are table names stable, scoped, and not conflicting with existing Sake/Meat tables? | Yes |
| Relationship correctness | Are customer, location, user, sales, quote, draft, order, list relationships coherent? | Yes |
| RLS safety | Do policies deny cross-customer and cross-tenant access by default? | Yes |
| Audit coverage | Are all draft writes, approvals, order confirmation, pricing actions, and service-role writes audited? | Yes |
| Price governance | Are price books, customer price rules, margin, and supplier cost protected from direct UI writes? | Yes |
| Customer identity risk | Is duplicate/merge strategy understood before customer migration? | Yes |
| LINE identity risk | Is LINE identity inactive until separate approved integration? | Yes |
| AI approval boundaries | Can AI draft/suggest without approval authority? | Yes |
| Inventory mutation restrictions | Is procurement prevented from reserve/deduct/dispatch? | Yes |
| Rollback strategy | Can staging migration be rolled back or disabled safely? | Yes |
| Seed/mock strategy | Are staging seed fixtures safe and aligned with Readdy mock DTOs? | Yes |
| Staging-only first strategy | Will Phase 3B run in staging only before any production discussion? | Yes |

Phase 3A CTO review additions:

| Gate | Required decision |
| --- | --- |
| Issued quote table | Confirm `procurement_quotes` is required between quote drafts and order drafts |
| Quote item snapshots | Decide whether Phase 3B needs `procurement_quote_items` or immutable JSON line snapshots |
| Product categories | Confirm normalized `procurement_product_categories` |
| Price book items | Confirm normalized `procurement_price_book_items` |
| Price rule versioning | Confirm `version_no` and `supersedes_rule_id` semantics |
| Customer merge/dedup | Phase 3B-1 reserves `merge_candidate_of`, `identity_status`, `archived_at`, and `archived_reason`; future automated merge semantics still require CTO approval |
| Sales assignment overlap | Confirm whether overlaps are forbidden or resolved by precedence |

## 3. Specific Hard Requirements

1. Customer users cannot see other customers.
2. Sales reps can see only assigned customers unless owner/admin.
3. AI agent cannot bypass human approval gate.
4. Pricing rules cannot be directly written by frontend.
5. Order confirmation must audit customer and sales/system confirmation refs.
6. Inventory mutation stays outside Procurement.
7. Service role is never exposed to frontend.
8. No secrets or env values enter GitHub docs, mock data, or UI.

## 4. Phase 3B Entry Criteria

Phase 3B may start only if:

1. Table draft is accepted or revised.
2. RLS helper function candidates are accepted.
3. Audit event minimum schema is accepted.
4. Staging project is identified by alias only, not credentials.
5. Rollback/disable strategy is documented.
6. Seed data is mock/safe.
7. No production deployment is included.

## 4.1 Phase 3B-1 Staging Schema Skeleton Gate

Phase 3B-1 allowed scope:

1. Create a staging migration draft file under `supabase/migrations/`.
2. Define only the first schema skeleton tables needed for future Phase 2 UI reads and quote draft lifecycle.
3. Enable RLS with conservative policies.
4. Include audit schema foundation.
5. Document rollback and staging seed strategy without real seed data.

Phase 3B-1 required exclusions:

1. Do not execute migration.
2. Do not deploy to production.
3. Do not add production API routes or Edge Functions.
4. Do not connect LINE.
5. Do not add AI pricing automation.
6. Do not create formal orders, order confirmation APIs, inventory reservation, or inventory deduction.
7. Do not create supplier cost, price book, customer price rule, or margin automation tables in this first skeleton.
8. Do not use real customer seed data.

Phase 3B-1 conservative RLS decision:

1. Customer users may read only their own customer-scope records.
2. Sales reps may read assigned customers only during effective assignment windows.
3. Customer users may not read quote drafts.
4. Authenticated users receive no insert/update/delete table grants.
5. Audit table has no authenticated read policy in Phase 3B-1.
6. Owner/admin broad access remains TODO until the canonical role source is confirmed.

## 4.2 Phase 3B-2 Disposable Dry-Run Gate

Phase 3B-2 allowed scope:

1. Create disposable Supabase dry-run SOP.
2. Define execution, rollback, verification, and failure recovery checklists.
3. Require disposable project for first execution.
4. Require fictional seed and RLS denial tests only after explicit execution approval.
5. Preserve production, shared staging, API, LINE, AI pricing, Readdy UI, order, inventory, secrets/env prohibitions.

Phase 3B-2 required exclusions:

1. Do not execute migration.
2. Do not execute seed.
3. Do not execute tests.
4. Do not use production.
5. Do not use shared staging.
6. Do not connect API routes, Edge Functions, LINE, AI pricing, or Readdy UI.
7. Do not create formal orders, inventory mutation, real customer data, or real pricing data.

Phase 3B-2 pass criteria before any next gate:

1. Disposable dry-run sequence is reviewed.
2. Rollback sequence is reviewed.
3. Validation checklist includes RLS denial and audit isolation.
4. Failure recovery path blocks shared staging on any leak or partial rollback failure.
5. CTO approves whether to run disposable dry-run in a future execution round.

## 5. Phase 3C Entry Criteria

Phase 3C read model APIs may start only if:

1. Disposable dry-run is applied, verified, rolled back, and reviewed.
2. RLS denial tests pass.
3. Read DTOs match `PROCUREMENT_API_READ_MODEL_CONTRACT.md`.
4. Pricing and supplier cost fields are hidden from unauthorized actors.
5. CTO approves moving from dry-run to read model API planning.
6. Shared staging remains blocked until a separate gate is opened.

## 6. Phase 3D Entry Criteria

Phase 3D draft write APIs may start only if:

1. Audit append path exists.
2. Draft write DTOs are reviewed.
3. Draft writes cannot confirm orders.
4. Draft writes cannot activate pricing rules.
5. Draft writes cannot reserve or deduct inventory.

## 7. Phase 3E Entry Criteria

Phase 3E approval gates may start only if:

1. Approval actors and role matrix are accepted.
2. Pricing approval thresholds are accepted.
3. Customer confirmation trace model is accepted.
4. Order confirmation audit event is mandatory.
5. AI actor is technically prevented from final approval.

## 8. Phase 3F Entry Criteria

Phase 3F customer B2B portal backend may start only if:

1. Customer account hierarchy is accepted.
2. Customer portal RLS tests pass.
3. Customer-visible pricing model is accepted.
4. Customer confirmation and quote expiration are accepted.
5. LINE linkage remains separate unless Phase 5 is approved.

## 9. Architecture Risk Review Focus

CTO should focus on:

1. Customer identity duplication across Platform/Sake/Meat/Procurement.
2. Sales assignment semantics and historical ownership.
3. Supplier cost confidentiality.
4. Price book and customer price rule versioning.
5. Quote-to-order conversion semantics.
6. Audit event completeness.
7. RLS helper functions and security-definer risk.
8. Future LINE idempotency and identity linkage.
9. AI memory retention and customer privacy.
10. Inventory boundary enforcement.
