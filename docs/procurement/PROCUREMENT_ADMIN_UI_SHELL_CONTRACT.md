# Procurement Admin UI Shell Contract

Status: Proposed
Date: 2026-05-15
Scope: Phase 2 UI/API shell contract for Readdy

本輪仍以治理與實作前契約為主。

本文件不授權 production code、不授權 DB migration、不授權 secrets / env access、不授權 LINE integration、不授權 AI pricing automation、不授權正式訂單寫入、不授權真實扣庫存。

Phase 2 允許 Readdy 施工的範圍僅限 `/procurement-admin` shell、mock/read-only UI、safe read model rendering、清楚標示高風險功能尚待後端契約完成。

## 1. Purpose

This document defines the first `/procurement-admin` internal backoffice shell for the 大皇居 B2B procurement platform.

It translates the canonical contracts into a Readdy-buildable UI contract without requiring production DB, migrations, live LINE, AI pricing automation, or real order execution.

Related source-of-truth documents:

| Topic | Source |
| --- | --- |
| Canonical data | `docs/procurement/PROCUREMENT_CANONICAL_DATA_CONTRACT.md` |
| Customer context | `docs/platform/CUSTOMER_CONTEXT_GOVERNANCE.md` |
| AI commerce events | `docs/procurement/AI_COMMERCE_EVENT_CONTRACT.md` |
| Pricing governance | `docs/procurement/PRICING_GOVERNANCE_CONTRACT.md` |
| Domain boundaries | `docs/platform/DOMAIN_MODULE_BOUNDARY.md` |
| Phase plan | `docs/governance/PROCUREMENT_IMPLEMENTATION_PHASE_PLAN.md` |

## 2. Phase 2 Shell Principles

| Principle | Requirement |
| --- | --- |
| Shell first | Build navigation, page structure, table/list/detail layouts, empty states, and mock-safe states only |
| Mock allowed | Data may come from local mock fixtures or existing safe read models |
| No production DB | Do not connect to production Supabase, live API, Edge Function, or migration-backed tables |
| No live action | Buttons for high-risk actions must be disabled, mock-only, or marked "需後端契約完成" |
| No false readiness | UI must not imply real quote sending, real order creation, real inventory deduction, or real LINE connection |
| No secrets | Debug and trace surfaces must never display tokens, keys, `.env`, database URLs, or service role values |

## 3. Route And Navigation

Phase 2 target route:

```text
/procurement-admin
```

Recommended subroutes:

| Route | Page |
| --- | --- |
| `/procurement-admin` | Overview Dashboard |
| `/procurement-admin/customers` | Customers list |
| `/procurement-admin/customers/:customerId` | Customer detail |
| `/procurement-admin/products` | Products catalog |
| `/procurement-admin/quote-requests` | Quote Requests |
| `/procurement-admin/quote-drafts` | Quote Drafts |
| `/procurement-admin/orders` | Orders |
| `/procurement-admin/pricing` | Pricing Governance |
| `/procurement-admin/audit` | Audit / Debug |

Sidebar sections:

| Section | Items |
| --- | --- |
| Overview | Dashboard |
| Customer Context | Customers, Locations, Sales Ownership, LINE Linkage |
| Catalog | Products, Categories, Supplier-Sourced Items |
| Commerce Flow | Quote Requests, Quote Drafts, Orders |
| Governance | Pricing Governance, Audit / Debug |

## 4. Global UI States

Every Phase 2 page should support:

| State | Requirement |
| --- | --- |
| Mock data | Display visible mock/sandbox marker |
| Empty | Show neutral empty state without asking user to connect DB |
| Review required | High-risk actions use explicit review labels |
| Disabled actions | Disabled controls explain "需後端契約完成" |
| Loading | Skeleton state allowed |
| Error | Safe non-secret error copy |

Suggested persistent banner:

```text
Phase 2 Shell - mock/read-only mode. No real quote, order, inventory, LINE, or pricing automation is executed.
```

## 5. Overview Dashboard

Purpose: Internal procurement command view for daily intake and review queues.

Widgets:

| Widget | Meaning | Phase 2 behavior |
| --- | --- | --- |
| 今日詢價 | Count of `quote_requests` received today | Mock/read-only count |
| 待業務確認訂單草稿 | Count of `order_drafts` waiting sales review | Mock/read-only count |
| 待報價調貨品 | Count of supplier-sourced quote lines needing procurement review | Mock/read-only count |
| 低毛利警示 | Count of quote drafts flagged by margin guardrails | Mock/read-only alert list; no auto price update |
| 客戶常用採購清單 | Count or preview of active `procurement_lists` | Mock/read-only preview |

Dashboard cards should link to the relevant list page.

Forbidden in Phase 2:

1. Do not create real quote requests from dashboard.
2. Do not approve orders from dashboard.
3. Do not update prices from dashboard.
4. Do not trigger supplier procurement.
5. Do not allocate inventory.

## 6. Customers

Purpose: Read and review customer procurement context.

### 6.1 Customer List

Recommended columns:

| Column | Meaning |
| --- | --- |
| Customer | Customer display name and customer code |
| Segment | Restaurant, group, distributor, hotel, bar, other |
| Locations | Location count |
| Assigned sales rep | Current sales owner |
| LINE linkage | unlinked, candidate_match, linked_user, linked_group, suspended |
| Preferences | Procurement preferences summary |
| Open requests | Active quote request count |
| Status | active, review_required, archived |

Allowed Phase 2 actions:

1. View customer detail.
2. Filter by segment, sales rep, LINE linkage, status.
3. Search mock/read-only list.

Disabled / blocked:

1. Create customer.
2. Merge customer.
3. Link LINE identity.
4. Reassign sales owner.

### 6.2 Customer Detail

Sections:

| Section | Content |
| --- | --- |
| Customer identity | Name, code, segment, status |
| Customer locations | Branches, billing/delivery labels, receiving preferences |
| Customer users | Buyers, approvers, viewers, location buyers |
| Assigned sales rep | Primary, secondary, escalation owner |
| LINE linkage status | Link state and safe summary |
| Procurement preferences | Preferred categories, quantities, units, delivery preferences, substitution tolerance |
| Active commerce | Open quote requests, quote drafts, order drafts, recent confirmed order summaries |
| AI memory boundary | Scoped memory summary, internal-only warning |

Phase 2 UI must not expose:

1. Supplier cost.
2. Internal margin.
3. Other customers' price history.
4. Raw LINE tokens or webhook payloads.
5. Secrets or `.env`.

## 7. Products

Purpose: Read procurement catalog shell across categories.

Categories:

| Category | Meaning |
| --- | --- |
| `sake` | Alcohol, liquor, sake-related products |
| `tableware` |餐瓷 / 器皿 as procurement category |
| `meat` | Aged meat and meat products |
| `seafood` | Seafood products |
| `other` | Other B2B sourced items |

Recommended columns:

| Column | Meaning |
| --- | --- |
| Product | Product name |
| Variant | SKU/spec/pack/unit |
| Category | sake, tableware, meat, seafood, other |
| Supply type | fixed_stock_item or supplier_sourced_item |
| Status | active, inactive, archived |
| Price visibility | list price exists, customer rule exists, review required |
| Supplier review | none, required, stale quote |

Supply type definitions:

| Type | Meaning |
| --- | --- |
| `fixed_stock_item` | Expected to be available from existing stock or known catalog |
| `supplier_sourced_item` | Requires supplier quote, lead time, or procurement review |

Phase 2 allowed:

1. Read/search/filter mock catalog.
2. Display active/inactive/archive state.
3. Show supplier-sourced review badges.

Phase 2 blocked:

1. Create/edit/archive real product.
2. Sync Sake or Meat production catalogs.
3. Fetch supplier live availability.
4. Trigger inventory allocation.

## 8. Quote Requests

Purpose: Intake queue for customer inquiries.

Recommended fields:

| Field | Meaning |
| --- | --- |
| Request ID | Human-readable request code |
| Customer | Customer context |
| Requested items | Product text, candidate variants, quantity, unit |
| Source channel | LINE, sales, platform, manual |
| Assigned sales rep | Current owner |
| Status | new, triage, needs_clarification, draft_created, closed, archived |
| Risk flags | identity_ambiguous, product_ambiguous, supplier_required |
| Received at | Intake timestamp |

Status workflow:

```text
new
-> triage
-> needs_clarification
-> draft_created
-> closed
```

Phase 2 allowed:

1. Render mock request list.
2. View request detail.
3. Show status workflow visually.
4. Show "Create draft" as disabled or mock-only.

Phase 2 blocked:

1. Real LINE ingestion.
2. Real AI product search execution.
3. Real quote draft creation against production backend.

## 9. Quote Drafts

Purpose: Internal draft surface for sales/procurement review.

AI-assisted is allowed as a concept in UI copy, but Phase 2 must not run AI automation unless a separate approved safe mock exists.

Recommended fields:

| Field | Meaning |
| --- | --- |
| Draft ID | Human-readable draft code |
| Customer | Customer context |
| Source request | Related quote request |
| Draft lines | Product variants, quantity, unit |
| Price fields | List price, customer price, draft unit price |
| Margin fields | Margin estimate, low-margin flag, review status |
| Supplier status | supplier quote needed, supplier quote stale, ready |
| Created by | ai_assisted_mock, sales, procurement_user |
| Approval state | draft, sales_review_required, pricing_review_required, approved_for_quote, rejected |

Approval state workflow:

```text
draft
-> sales_review_required
-> pricing_review_required
-> approved_for_quote
```

Phase 2 allowed:

1. Display price/margin fields as mock or read-only.
2. Show warnings and badges.
3. Show approval state.
4. Explain that human approval is required.

Phase 2 blocked:

1. Auto-finalize price.
2. Send customer-facing quote.
3. Activate customer price rule.
4. Apply discount below guardrail.
5. Use real supplier cost without approved backend.

## 10. Orders

Purpose: Internal order state shell for order drafts and confirmed orders.

Recommended tabs:

| Tab | Meaning |
| --- | --- |
| Order Drafts | Pre-confirmation order candidates |
| Confirmed Orders | Orders confirmed by required approvals |

Recommended fields:

| Field | Meaning |
| --- | --- |
| Order / Draft ID | Human-readable code |
| Customer | Customer context |
| Source channel | LINE, sales, platform, manual, quote |
| Sales attribution | Assigned sales rep |
| Status | draft, sales_review_required, customer_confirmation_pending, confirmed, cancelled |
| Fulfillment status | not_started, supplier_procurement_required, inventory_review_required, shipment_ready_mock, fulfilled_mock |
| Total | Customer-facing total if safe |
| Risk flags | low_margin, supplier_required, inventory_required, expired_quote |

Phase 2 allowed:

1. Display mock order drafts.
2. Display mock confirmed order summaries if clearly labeled.
3. Show fulfillment status badges.

Phase 2 blocked:

1. Create real order.
2. Confirm real order.
3. Deduct inventory.
4. Reserve inventory.
5. Trigger shipment.
6. Trigger supplier procurement.

Required UI copy:

```text
Phase 2 shell only. This view does not create real orders, reserve inventory, or trigger fulfillment.
```

## 11. Pricing Governance

Purpose: Read-only MVP for pricing visibility and governance education.

Sections:

| Section | Content |
| --- | --- |
| Price books | List of mock/read-only price book summaries |
| Customer price rules | Customer-specific rule summaries |
| Margin guardrails | Internal guardrail status summaries without exposing thresholds to unauthorized roles |
| Expiring quote prices | Quote expiration review queue |
| Volatility flags | Imported liquor, aged meat, supplier fluctuation |

Phase 2 allowed:

1. Read-only price book list.
2. Read-only customer price rule list.
3. Mock margin/volatility flags.
4. Display AI pricing assistant guardrails as policy notes.

Phase 2 blocked:

1. Create/update/delete price books.
2. Create/update/delete customer price rules.
3. Automatic price update.
4. AI pricing automation.
5. Revealing supplier cost or internal margin to customer-facing surfaces.

## 12. Audit / Debug

Purpose: Owner-only diagnostic shell for safe traceability during Readdy development.

Access:

| Role | Access |
| --- | --- |
| owner / platform_owner | Allowed |
| procurement_admin | Optional, if approved |
| sales_rep | No by default |
| customer user | Never |

Debug drawer may show:

| Field | Allowed? |
| --- | --- |
| API base alias | Yes, alias only |
| Org ID / tenant ID | Yes, if non-secret |
| Customer ID | Yes, current context only |
| Request trace ID | Yes |
| Mock fixture name | Yes |
| Source channel | Yes |
| Feature flags | Yes, non-secret only |

Debug drawer must not show:

1. Tokens.
2. API keys.
3. Supabase service role key.
4. Supabase anon key copied from `.env`.
5. Database URL.
6. LINE channel secret or access token.
7. Raw webhook payload containing sensitive data.
8. Supplier confidential cost unless role and backend contract explicitly allow it.

## 13. Visual Language For Risk

Recommended labels:

| Label | Use |
| --- | --- |
| `Mock` | Data is local or fake |
| `Read-only` | Data is display-only |
| `Review required` | Human review required before action |
| `需後端契約完成` | Feature cannot execute in Phase 2 |
| `No live action` | Button or flow does not affect production |

Avoid labels that imply live behavior:

1. Do not label a mock action as "送出正式報價".
2. Do not label a mock order as "已完成下單" unless it is clearly sample data.
3. Do not use "扣庫存成功".
4. Do not use "LINE 已串接完成".
5. Do not use "AI 已自動定價".

## 14. Phase 2 Acceptance Checklist

Readdy Phase 2 shell can be accepted if:

1. `/procurement-admin` route exists.
2. Pages listed in this document exist as shell/mock/read-only surfaces.
3. All high-risk actions are disabled, mock-only, or marked "需後端契約完成".
4. Pricing Governance is read-only.
5. Orders page does not create real orders.
6. Debug drawer is owner-only and secret-free.
7. UI clearly states that real quote/order/inventory/LINE/pricing automation is not active.

## 15. Implementation Gate

Before moving beyond Phase 2:

1. CTO reviews this shell contract.
2. Backend read model contract is accepted.
3. Customer identity and context rules are accepted.
4. Pricing approval and quote expiration rules are accepted.
5. A separate implementation plan explicitly authorizes any production data, migration, LINE integration, AI automation, or order write behavior.
