# Procurement Implementation Phase Plan

Status: Proposed
Date: 2026-05-15
Scope: Documentation / governance / architecture only

本輪為 canonical contracts phase only。

本文件不涉及 production code、不涉及 DB migration、不涉及 secrets / env、不涉及 Readdy UI 修改、不產生 API route、不實作 Edge Function。後續需由 CTO review 後才可進入 implementation phase。

## 1. Purpose

This plan defines the recommended phase order for implementing the 大皇居 B2B procurement platform after canonical contracts are reviewed.

No phase below is authorized by this document alone. Each implementation phase requires CTO review, a scoped task plan, and explicit approval.

## 2. Phase Summary

| Phase | Name | Goal | Allowed in current round |
| --- | --- | --- | --- |
| Phase 1 | Canonical contracts only | Define data, identity, event, pricing, and boundary contracts | Yes |
| Phase 2 | Platform shell | Add approved route/navigation shell and governance surfaces | No |
| Phase 3 | Procurement admin skeleton | Add internal procurement admin screens and mock-safe flows | No |
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

## 5. Phase 3: Procurement Admin Skeleton

Goal: Build internal procurement admin skeleton for operators and sales.

Candidate scope:

1. Customer context read model UI.
2. Product/category catalog skeleton.
3. Quote request queue.
4. Quote draft review surface.
5. Pricing review flags.
6. Procurement list management.

Required gates:

1. Mock or contract-backed data only unless migration is separately approved.
2. No real supplier procurement execution.
3. No automatic pricing approval.
4. No customer-facing quote send until approval flow exists.

## 6. Phase 4: Customer B2B Portal

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

## 7. Phase 5: LINE Commerce Integration

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

## 8. Phase 6: AI Pricing + Recommendation

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

## 9. Recommended Implementation Order

Recommended order after Phase 1:

```text
Platform shell
-> Procurement admin skeleton
-> Customer B2B portal
-> LINE commerce integration
-> AI pricing + recommendation
```

Reasoning:

1. Platform shell establishes safe navigation and product boundaries.
2. Procurement admin defines internal review workflow before customer exposure.
3. Customer portal should only show approved customer-visible data.
4. LINE integration should not exist before draft/review concepts are implemented.
5. AI pricing should come after pricing rules and approvals exist.

## 10. Current Round Constraints

This round explicitly forbids:

1. DB migration.
2. Production logic.
3. Readdy implementation.
4. API route generation.
5. Edge Function implementation.
6. Secrets / env access.

Any request to cross those boundaries must become a separate implementation phase after CTO review.
