# Procurement Implementation Phase Plan

Status: Proposed
Date: 2026-05-16
Scope: Documentation / governance / architecture only

本文件目前納入 Phase 3A backend implementation design。

本文件不涉及 production code、不涉及 DB migration、不涉及 secrets / env、不涉及 Readdy UI 修改、不產生 API route、不實作 Edge Function、不接 LINE、不做 AI pricing automation。後續需由 CTO review 後才可進入 implementation phase。

Phase 3C update: read model API contracts are defined, but implementation remains blocked until Phase 3B disposable dry-run, rollback, and RLS denial evidence are reviewed.

## 1. Purpose

This plan defines the recommended phase order for implementing the 大皇居 B2B procurement platform after canonical contracts are reviewed.

No phase below is authorized by this document alone. Each implementation phase requires CTO review, a scoped task plan, and explicit approval.

## 2. Phase Summary

| Phase | Name | Goal | Allowed in current round |
| --- | --- | --- | --- |
| Phase 1 | Canonical contracts only | Define data, identity, event, pricing, and boundary contracts | Completed |
| Phase 2 | Platform shell | Add approved route/navigation shell and governance surfaces | Completed as Readdy VER294 shell acceptance |
| Phase 3A | Backend design only | Backend implementation design, RLS/audit plan, migration draft, API/RPC draft | Yes |
| Phase 3B | Staging migration draft implementation | Convert reviewed draft into staging-only migration | No |
| Phase 3C | Read model APIs | Define and later implement safe read RPC/API for procurement admin shell after disposable dry-run | Contract only |
| Phase 3D | Draft write APIs | Implement quote request/draft and order draft write APIs | No |
| Phase 3E | Approval gates | Implement quote/order/supplier/inventory-review approval gates and audit | No |
| Phase 3F | Customer B2B portal backend | Backend for customer portal access and customer-visible flows | No |
| Phase 4 | Customer B2B portal | Add `/b2b` customer-facing procurement portal | No |
| Phase 5 | LINE commerce integration | Connect LINE inquiry to draft/review flow | No |
| Phase 6 | AI pricing + recommendation | Add guarded AI pricing and follow-up assistant | No |

## 3. Phase 1: Canonical Contracts Only

Goal: Establish reviewed source-of-truth contracts before implementation.

Deliverables:

1. `PROCUREMENT_CANONICAL_DATA_CONTRACT.md`
2. `CUSTOMER_CONTEXT_GOVERNANCE.md`
3. `AI_COMMERCE_EVENT_CONTRACT.md`
4. `PRICING_GOVERNANCE_CONTRACT.md`
5. Updated `DOMAIN_MODULE_BOUNDARY.md`
6. This phase plan

Allowed work:

1. Markdown documents.
2. Source-of-truth references.
3. Architecture risks and implementation gates.

Forbidden work:

1. DB migration.
2. Production logic.
3. Readdy implementation.
4. API route generation.
5. Edge Function implementation.
6. Secrets or env handling.

Exit criteria:

1. CTO reviews all Phase 1 contracts.
2. Entity names and event names are accepted or revised.
3. Pricing approval gates are accepted.
4. Procurement vs Sake/Meat boundaries are accepted.

## 4. Phase 2: Platform Shell

Goal: Add approved high-level shell for procurement entry points after contracts are accepted.

Candidate scope:

1. `/platform` launcher updates.
2. `/procurement-admin` route shell.
3. `/b2b` route shell.
4. Optional `/platform/line-bot` governance shell.
5. No live data and no migration.

Required inputs:

1. `BACKOFFICE_ENTRYPOINT_GOVERNANCE.md`
2. `READDY_VER293_GOVERNANCE_READOUT.md`
3. Phase 1 accepted contracts.

Risks:

1. Shell may imply product readiness if labels are not clear.
2. Customer-facing `/b2b` must not expose internal pricing or mock secrets.
3. Tableware must remain procurement category, not separate admin.

## 5. Phase 3A: Backend Design Only

Goal: Create backend implementation design without running migrations or implementing APIs.

Deliverables:

1. `docs/procurement/PROCUREMENT_BACKEND_IMPLEMENTATION_DESIGN.md`
2. `docs/procurement/PROCUREMENT_RLS_AND_AUDIT_PLAN.md`
3. `docs/procurement/PROCUREMENT_PHASE3A_DB_MIGRATION_DRAFT.md`
4. `docs/procurement/PROCUREMENT_API_RPC_CONTRACT_DRAFT.md`
5. `docs/governance/PROCUREMENT_PHASE3_IMPLEMENTATION_GATE_CHECKLIST.md`

Allowed work:

1. Markdown architecture documents.
2. Migration draft in docs only.
3. RLS/audit design.
4. API/RPC contract draft.
5. CTO gate checklist.

Forbidden work:

1. Real migration files.
2. Production code.
3. API route or RPC implementation.
4. Edge Function implementation.
5. LINE integration.
6. AI pricing automation.
7. Readdy UI changes.
8. Secrets/env access.

## 6. Phase 3B: Staging Migration Draft Implementation

Goal: Convert CTO-reviewed Phase 3A draft into staging-only migration work.

Required gates:

1. CTO accepts table naming.
2. RLS helper functions are reviewed.
3. Audit event minimum schema is accepted.
4. Rollback strategy is documented.
5. Seed/mock strategy is staging-safe.
6. No production deployment.

## 7. Phase 3C: Read Model APIs

Goal: Define, then later implement, safe read RPC/API for `/procurement-admin`.

Candidate scope:

1. `get_procurement_dashboard_summary`
2. `list_procurement_customers`
3. `get_procurement_customer_detail`
4. `list_procurement_products`
5. `list_procurement_quote_requests`
6. `list_procurement_quote_drafts`
7. `list_procurement_order_drafts_mock_or_future`
8. `get_procurement_pricing_governance_summary_safe`

Required gates:

1. Disposable dry-run is applied, verified, rolled back, and reviewed.
2. RLS denial tests pass.
3. Pricing and supplier cost visibility rules pass.
4. CTO approves read model implementation scope.
5. Readdy can read through read models without direct table access or write permission.
6. Shared staging remains blocked until a separate gate is opened.

Phase 3C contract deliverable:

1. `docs/procurement/PROCUREMENT_PHASE3C_READ_MODEL_API_CONTRACT.md`

Phase 3C hard exclusions:

1. Customer users do not enter `/procurement-admin` read model.
2. No supplier cost, internal margin, or guardrail thresholds to general sales.
3. No general audit event read API.
4. No real order draft/order read implementation until order tables are approved.
5. No API route implementation in contract-only rounds.

## 8. Phase 3D: Draft Write APIs

Goal: Implement draft-only write APIs.

Candidate scope:

1. `create_quote_request`
2. `create_quote_draft`
3. `update_quote_draft`
4. `submit_quote_draft_for_approval`
5. `create_order_draft`
6. `update_order_draft`

Required gates:

1. Audit append path exists.
2. Draft writes cannot confirm orders.
3. Draft writes cannot update pricing rules directly.
4. Draft writes cannot reserve or deduct inventory.

## 9. Phase 3E: Approval Gates

Goal: Implement explicit human approval gates.

Candidate scope:

1. `approve_quote`
2. `confirm_order`
3. `mark_supplier_procurement_required`
4. `mark_inventory_allocation_required`

Required gates:

1. Approval actors and role matrix are accepted.
2. Order confirmation audit is mandatory.
3. AI actor is blocked from final approval.
4. Inventory mutation remains outside Procurement.

## 10. Phase 3F: Customer B2B Portal Backend

Goal: Build customer portal backend access after internal procurement read/write foundations are safe.

Candidate scope:

1. Customer account-scoped read models.
2. Customer quote request creation.
3. Customer procurement lists.
4. Customer confirmation trace.
5. Customer-visible order summaries.

Required gates:

1. Customer portal RLS tests pass.
2. Customer-visible pricing is reviewed.
3. Internal margin and supplier cost are hidden.
4. LINE identity remains separate until Phase 5.

## 11. Phase 4: Customer B2B Portal

Goal: Build customer-facing `/b2b` procurement portal.

Candidate scope:

1. Customer login/identity shell.
2. Customer-visible catalog.
3. Customer-specific price display from approved source.
4. Procurement lists.
5. Quote review.
6. Order draft confirmation.

Required gates:

1. Customer account hierarchy accepted.
2. Customer-visible pricing fields reviewed.
3. Internal margin/supplier cost hidden by design.
4. Quote expiration behavior defined.
5. Customer confirmation audit defined.

## 12. Phase 5: LINE Commerce Integration

Goal: Connect LINE inquiry to AI-assisted draft and sales review flow.

Candidate scope:

1. LINE identity linkage.
2. Inquiry ingestion.
3. AI product search.
4. Quote draft creation.
5. Sales review notification.
6. Customer confirmation messaging.

Required gates:

1. LINE identity linkage review.
2. Event idempotency design.
3. Human approval state machine.
4. No automatic order confirmation.
5. No secrets or token exposure in docs/logs/UI.

## 13. Phase 6: AI Pricing + Recommendation

Goal: Add AI assistance for pricing review, margin risk, reorder suggestions, and follow-up.

Candidate scope:

1. AI-safe pricing views.
2. Margin risk summaries.
3. Supplier quote freshness alerts.
4. Reorder recommendation from procurement lists.
5. Follow-up recommendation events.

Required gates:

1. AI pricing assistant guardrails implemented and reviewed.
2. Minimum pricing thresholds approved.
3. Customer-specific pricing approval workflow exists.
4. AI memory boundaries reviewed.
5. Audit exists for AI suggestions and human approvals.

## 14. Recommended Implementation Order

Recommended order after Phase 2:

```text
Backend design only
-> Staging migration draft implementation
-> Read model APIs
-> Draft write APIs
-> Approval gates
-> Customer B2B portal backend
-> Customer B2B portal
-> LINE commerce integration
-> AI pricing + recommendation
```

Reasoning:

1. Backend design prevents premature migration and unsafe writes.
2. Staging migration lets RLS and audit be tested before production discussion.
3. Read models let Readdy move beyond mocks without write risk.
4. Draft writes come before approval-gated commitments.
5. Customer portal should only show approved customer-visible data.
6. LINE integration should not exist before draft/review concepts are implemented.
7. AI pricing should come after pricing rules and approvals exist.

## 15. Current Round Constraints

This round explicitly forbids:

1. DB migration.
2. Production logic.
3. Readdy implementation.
4. API route generation.
5. Edge Function implementation.
6. Secrets / env access.
7. LINE integration.
8. AI pricing automation.
9. Real order writes.

Any request to cross those boundaries must become a separate implementation phase after CTO review.
