# Procurement Backend Implementation Design

Status: Proposed
Date: 2026-05-16
Scope: Documentation / architecture / migration draft only

本輪為 Phase 3A backend implementation design only。

本文件不涉及 production code、不執行 DB migration、不碰 secrets / env、不接 LINE、不做 AI pricing automation、不建立真實訂單寫入、不改 Readdy UI、不建立 API route、不實作 Edge Function。

## 1. Domain Goals

大皇居 B2B 採購平台後端的目標是建立可治理、可審核、可逐步接入前端 shell 的採購 domain。

Primary goals:

1. Provide canonical backend boundaries for customers, products, quote requests, quote drafts, order drafts, pricing governance, audit, and AI events.
2. Support `/procurement-admin` Phase 2 shell with safe read models first.
3. Allow draft-only writes later without enabling real order confirmation too early.
4. Preserve human approval gates for pricing, quote issuance, order confirmation, supplier procurement, and inventory allocation.
5. Keep Procurement as a demand/commerce layer, not an inventory mutation layer.
6. Prepare for future `/b2b`, LINE, and AI Agent gateway without coupling them to Phase 3A.

## 2. Non-Goals

This design does not authorize:

1. Actual DB migration.
2. Production API routes.
3. Edge Functions.
4. LINE webhook integration.
5. AI pricing automation.
6. Direct price rule update from UI.
7. Real order confirmation writes.
8. Inventory reserve, allocation, deduction, or shipment dispatch.
9. Readdy UI changes.
10. Secrets / env access.

## 3. Core Backend Modules

| Module | Responsibility | Phase 3A posture |
| --- | --- | --- |
| Customer Context | Customer identity, locations, users, sales ownership, LINE linkage status | Design only |
| Catalog | Procurement products, variants, categories, supply type, archive status | Design only |
| Supplier Sourcing | Supplier sources and supplier quotes | Design only |
| Pricing Governance | Price books, customer price rules, guardrail metadata | Design only; no automation |
| Quote Intake | Quote requests from LINE/sales/platform/manual | Design only |
| Quote Drafting | Draft quote and items before customer quote issuance | Design only |
| Order Drafting | Draft order and items before confirmation | Design only |
| Confirmed Orders | Confirmed order records after approval | Design only; no early writes |
| Read Models | Dashboard/list/detail DTOs for Readdy | Design for Phase 3C |
| Audit | Append-only audit events and approval trace | Design only |
| AI Events | AI commerce event trace, no finalization authority | Design only |

## 4. Canonical Table Groups

| Group | Tables |
| --- | --- |
| Customer | `procurement_customers`, `procurement_customer_locations`, `procurement_customer_users`, `procurement_sales_assignments` |
| Catalog | `procurement_products`, `procurement_product_variants` |
| Supplier | `procurement_supplier_sources`, `procurement_supplier_quotes` |
| Pricing | `procurement_price_books`, `procurement_customer_price_rules` |
| Quote | `procurement_quote_requests`, `procurement_quote_drafts`, `procurement_quote_draft_items` |
| Order | `procurement_order_drafts`, `procurement_order_draft_items`, `procurement_orders`, `procurement_order_items` |
| Preference | `procurement_lists`, `procurement_list_items` |
| Governance | `procurement_audit_events`, `procurement_ai_events` |

## 5. Read Model Strategy

Read models should come before write behavior.

Recommended read model layers:

| Read model | Source tables | Phase |
| --- | --- | --- |
| Dashboard summary | quote requests, quote drafts, order drafts, lists, audit flags | 3C |
| Customer list | customers, locations, sales assignments, LINE linkage summary | 3C |
| Customer detail | customer + locations + users + ownership + preferences + active commerce | 3C |
| Product list | products, variants, supplier status, price visibility | 3C |
| Quote request list | quote requests + requested item summary | 3C |
| Quote draft list | drafts + item count + margin flags + approval state | 3C |
| Order draft list | order drafts + fulfillment status + risk flags | 3C |
| Pricing governance summary | price books, customer price rules, expiration and volatility flags | 3C |

Principles:

1. Read models must be role-scoped.
2. Read models must not expose supplier cost or internal margin to customer users.
3. Read models may be implemented as SQL views, RPCs, or API handlers after CTO review.
4. Phase 3C should remain read-only and staging-first.

## 6. Write Model Strategy

Write models must be introduced gradually.

| Write category | Examples | Earliest phase |
| --- | --- | --- |
| Draft-only writes | create quote request, create/update quote draft, create/update order draft | 3D |
| Approval-gated writes | approve quote, confirm order, mark supplier procurement required | 3E |
| Customer portal writes | customer quote request, customer confirmation, procurement list edits | 3F |
| Forbidden early writes | direct price book update, direct inventory deduct, AI auto confirm order | Not allowed |

Rules:

1. Every write has actor, organization scope, customer scope where applicable, and audit event.
2. Draft writes do not create customer-facing commitments.
3. Approval writes require explicit human approval and audit.
4. Inventory and shipment mutations remain outside Procurement.

## 7. Quote Request Lifecycle

```text
new
-> triage
-> needs_clarification
-> draft_created
-> closed
-> archived
```

Backend expectations:

1. Requests may originate from sales, platform, manual entry, future `/b2b`, or future LINE.
2. `source_channel = line` is allowed as future/mock value but does not imply live LINE integration.
3. Ambiguous identity or product matching creates review flags.
4. Quote request creation is draft/intake only and does not expose customer-facing prices.

## 8. Quote Draft Lifecycle

```text
draft
-> sales_review_required
-> pricing_review_required
-> approved_for_quote
-> rejected
-> archived
```

Backend expectations:

1. AI may assist in draft creation only after approved AI-safe data access exists.
2. Draft prices are internal until quote approval.
3. Price and margin fields require internal-only visibility.
4. `approved_for_quote` means ready to issue a quote, not automatically sent.
5. Quote issuance should be a separately approved phase.

## 9. Order Draft Lifecycle

```text
draft
-> sales_review_required
-> customer_confirmation_pending
-> approval_ready
-> confirmed
-> cancelled
-> archived
```

Backend expectations:

1. Order drafts may derive from quote drafts, customer portal carts, sales entry, or future LINE.
2. Order drafts must not reserve or deduct inventory.
3. Customer confirmation and sales confirmation are separate audit events.
4. `confirmed` is not allowed until Phase 3E approval gate is reviewed.

## 10. Human Approval Gates

Human approval required for:

1. Customer-facing quote issuance.
2. Pricing below guardrail or low margin review.
3. Customer-specific price rule activation.
4. Quote extension after expiration.
5. Order confirmation.
6. Supplier procurement commitment.
7. Inventory allocation request escalation.
8. Any AI-suggested action that changes price, order status, supplier commitment, or fulfillment state.

## 11. AI-Assisted But Not AI-Finalized Boundaries

AI may:

1. Suggest product matches.
2. Draft quote request summaries.
3. Draft quote draft items.
4. Flag low margin, supplier required, expired quote, or identity ambiguity.
5. Create follow-up recommendations.

AI must not:

1. Approve quotes.
2. Confirm orders.
3. Update price books or customer price rules.
4. Commit supplier procurement.
5. Reserve or deduct inventory.
6. Bypass RLS or human approval gates.

## 12. Integration Boundaries

| Surface | Boundary |
| --- | --- |
| `/platform` | Owns launcher, tenant/org governance, user role overview, project governance |
| `/sake-admin` | May supply/reference sake catalog/inventory context; must not own procurement pricing or B2B customer account hierarchy |
| `/meat-admin` | Owns meat batch, traceability, safety, availability input; procurement owns B2B quote/order demand |
| `/procurement-admin` | Internal procurement, sales review, quote/order drafts, pricing read model |
| `/b2b` | Future customer-facing portal; only customer-visible data and confirmations |
| LINE / AI Agent gateway | Future intake and draft assistance; no direct finalization |

## 13. Suggested Service / RPC / API Layer

Preferred layering:

```text
UI / client
-> safe read RPC/API
-> draft write RPC/API
-> approval-gated RPC/API
-> audit event append
-> canonical tables
```

Candidate layers:

| Layer | Purpose |
| --- | --- |
| Read RPCs | Dashboard/list/detail data for Readdy and admin |
| Draft write RPCs | Validate and create draft-only records |
| Approval RPCs | Enforce approval gates and append audit events |
| Internal service role jobs | Future controlled background tasks only |
| Views | Stable read models with RLS-safe projections |

## 14. Future Edge Function Candidates

Edge Functions are not allowed in Phase 3A.

Future candidates after review:

1. LINE webhook intake into `procurement_ai_events` and `procurement_quote_requests`.
2. AI product search orchestration with safe read models.
3. Supplier quote refresh from approved supplier APIs.
4. Customer quote notification sender.
5. Audit export or governance report.

Each candidate must have secrets handling, idempotency, audit, rollback, and staging-first review.

## 15. Phase Sequencing

| Phase | Scope |
| --- | --- |
| 3A | Backend design and migration draft only |
| 3B | Staging migration draft implementation |
| 3C | Read model APIs/RPCs |
| 3D | Draft write APIs/RPCs |
| 3E | Approval gates and audit enforcement |
| 3F | Customer B2B portal backend |

Phase 3B should not begin until CTO reviews table naming, relationships, RLS, audit coverage, pricing governance, identity risk, rollback, and staging-only strategy.
