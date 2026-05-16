# Procurement Phase 3A CTO Gate Review

Status: PASS WITH REQUIRED CHANGES
Date: 2026-05-16
Scope: Documentation / review only

本輪為 Phase 3A CTO gate review。

本文件不涉及 production code、不執行 DB migration、不碰 secrets / env、不接 LINE、不做 AI pricing automation、不建立真實訂單寫入、不改 Readdy UI、不建立 API route、不實作 Edge Function。

## A. Review Summary

Reviewed documents:

1. `docs/procurement/PROCUREMENT_BACKEND_IMPLEMENTATION_DESIGN.md`
2. `docs/procurement/PROCUREMENT_RLS_AND_AUDIT_PLAN.md`
3. `docs/procurement/PROCUREMENT_PHASE3A_DB_MIGRATION_DRAFT.md`
4. `docs/procurement/PROCUREMENT_API_RPC_CONTRACT_DRAFT.md`
5. `docs/governance/PROCUREMENT_PHASE3_IMPLEMENTATION_GATE_CHECKLIST.md`
6. `docs/governance/PROCUREMENT_IMPLEMENTATION_PHASE_PLAN.md`

Overall assessment:

```text
PASS WITH REQUIRED CHANGES
```

The Phase 3A design is directionally sound and correctly excludes production code, real migration, LINE, AI pricing automation, Readdy UI work, and inventory mutation. It is not a clean PASS because the first draft needed stronger treatment of issued quote versions, customer merge/dedup, price book item versioning, and sales assignment effective-window leakage.

This review directly backfilled required corrections into Phase 3A docs.

## B. Gate Result

| Gate | Result | Review note |
| --- | --- | --- |
| Table naming consistency | PASS WITH REQUIRED CHANGES | Naming is consistent; added recommended `procurement_product_categories`, `procurement_price_book_items`, and `procurement_quotes` to close canonical gaps |
| `organization_id` / tenant isolation | PASS | Most tenant-owned tables require `organization_id`; Phase 3B must enforce it by schema and RLS |
| Customer identity merge / dedup risk | PASS WITH REQUIRED CHANGES | Added `dedupe_key`, `identity_status`, `merged_into_customer_id`, and merge audit requirements |
| Sales assignment RLS leakage | PASS WITH REQUIRED CHANGES | Added effective-window and overlap-risk requirements |
| Customer portal user cross-customer leakage | PASS | RLS plan clearly denies cross-customer access; must be tested in staging |
| Supplier cost / margin leakage | PASS | Supplier cost and internal margin remain internal-only |
| Price rule versioning | PASS WITH REQUIRED CHANGES | Added explicit rule versioning and price book item normalization |
| Quote-to-order flow clarity | PASS WITH REQUIRED CHANGES | Added `procurement_quotes` between quote draft and order draft |
| Approval gate against AI/UI finalization | PASS | AI/UI direct finalization is forbidden; approval APIs must enforce actor scope |
| Inventory mutation exclusion | PASS | Procurement remains demand/commerce layer; inventory mutation excluded |
| Audit event coverage | PASS WITH REQUIRED CHANGES | Added before/after snapshots, approval refs, and idempotency keys |
| Rollback / staging-only / seed strategy | PASS WITH REQUIRED CHANGES | Gate exists, but Phase 3B must produce concrete rollback and seed scripts/plans before migration execution |

## C. Must-Fix Before Phase 3B

These items must be accepted in docs before converting the draft into staging migration implementation:

1. Confirm `procurement_quotes` as a required table for issued customer-facing quote versions.
2. Decide whether issued quote line snapshots require a separate `procurement_quote_items` table in Phase 3B.
3. Confirm `procurement_product_categories` normalization instead of enum-only categories.
4. Confirm `procurement_price_book_items` normalization and money/currency precision.
5. Confirm `procurement_customer_price_rules.version_no` and `supersedes_rule_id` semantics.
6. Confirm customer merge/dedup fields and policy: `dedupe_key`, `identity_status`, `merged_into_customer_id`.
7. Confirm sales assignment overlap rules and effective-window enforcement.
8. Confirm audit minimum fields include before/after snapshot, approval reference, and idempotency key.
9. Write a concrete Phase 3B rollback plan before applying any staging migration.
10. Define staging seed data that proves cross-customer, sales assignment, pricing, and AI denial tests.

## D. Nice-To-Have After Phase 3B

These are not blockers for staging migration draft implementation:

1. Add a dedicated `procurement_quote_items` table if Phase 3B starts with quote line JSON snapshots.
2. Add customer merge candidate scoring/read model after basic identity fields exist.
3. Add pricing governance reporting views for expiring rules and volatile categories.
4. Add audit export views after audit schema stabilizes.
5. Add AI-safe customer context views only after read model RLS tests pass.
6. Add supplier quote freshness dashboards after supplier quote visibility rules are proven.

## E. Architecture Risks

Top risks:

1. Customer identity merge could accidentally grant customer users access to a merged target customer.
2. Sales assignment overlap or expired assignment logic could leak customer data to former/temporary reps.
3. Supplier cost and internal margin could leak through quote draft read models if views reuse internal fields.
4. Price rules without versioning would make historical quotes impossible to audit.
5. A missing issued quote table would blur internal draft approval with customer-facing quote acceptance.
6. Approval APIs could become unsafe if UI or AI can call them without server-side actor enforcement.
7. Inventory mutation may creep into Procurement if `mark_inventory_allocation_required` is misread as allocation execution.
8. Audit metadata could accidentally store secrets, raw LINE payloads, or supplier confidential data.
9. Rollback could be weak if Phase 3B applies many tables and policies without staged verification.

## F. Recommended Corrections To Phase 3A Docs

Corrections already applied in this review:

| Document | Correction |
| --- | --- |
| `PROCUREMENT_BACKEND_IMPLEMENTATION_DESIGN.md` | Added product categories, price book items, issued quote table, issued quote lifecycle |
| `PROCUREMENT_RLS_AND_AUDIT_PLAN.md` | Added customer merge/dedup rules, sales assignment effective-window rules, richer audit fields, extra denial tests |
| `PROCUREMENT_PHASE3A_DB_MIGRATION_DRAFT.md` | Added `procurement_product_categories`, `procurement_price_book_items`, `procurement_quotes`, customer dedupe fields, price rule versioning |
| `PROCUREMENT_API_RPC_CONTRACT_DRAFT.md` | Clarified `approve_quote` should create/reference immutable issued quote version |

Still recommended before Phase 3B:

1. Decide if `procurement_quote_items` is required now or can be deferred with immutable JSON.
2. Write exact rollback plan.
3. Write exact seed data matrix for RLS tests.
4. Decide schema namespace and naming convention for helper functions.

## G. Whether Phase 3B Staging Migration Draft Can Start

Recommendation:

```text
Phase 3B may start after the must-fix corrections above are accepted by CTO.
```

Interpretation:

1. Phase 3B may not apply migration to production.
2. Phase 3B may only produce staging migration implementation after CTO accepts this gate review.
3. Phase 3B should start with table/RLS/audit scaffolding, not API writes.
4. Phase 3B must include rollback and seed/RLS test strategy in the same PR or implementation package.

## H. Proposed Phase 3B Scope If Allowed

Allowed Phase 3B scope:

1. Staging-only migration files for accepted tables.
2. RLS helper functions for owner/admin, procurement admin, assigned sales, customer user, AI-safe reads.
3. Append-only audit table and minimal audit helper.
4. Seed/mock data for at least two organizations, three customers, multiple customer users, two sales reps, and overlapping/expired assignment cases.
5. RLS denial tests:
   - Customer A cannot read Customer B.
   - Sales rep cannot read unassigned customer.
   - Expired sales assignment does not grant access.
   - Customer cannot read quote drafts/internal pricing.
   - AI-safe role cannot confirm order or read non-scoped customer context.
6. No read API implementation beyond migration verification unless explicitly scoped as Phase 3C.

Explicitly excluded from Phase 3B:

1. Production migration.
2. Readdy UI changes.
3. LINE integration.
4. AI pricing automation.
5. Approval APIs.
6. Draft write APIs.
7. Inventory mutation.
8. Service-role Edge Functions.
