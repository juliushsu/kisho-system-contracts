# Procurement API / RPC Contract Draft

Status: Draft
Date: 2026-05-16
Scope: Documentation / architecture / migration draft only

本文件是 API/RPC contract draft，不是 API route implementation。

本輪禁止實際 migration、production code、API route implementation、Edge Function implementation、LINE integration、AI pricing automation、Readdy UI work、secrets / env access。

## 1. Contract Principles

1. Read APIs arrive before write APIs.
2. Draft-only writes arrive before approval-gated writes.
3. Every write emits audit.
4. Pricing and inventory remain protected.
5. AI can assist but cannot finalize.
6. Phase availability is proposed and requires CTO review.

## 2. Read APIs / RPCs

| API/RPC | Actor allowed | Required approval | Audit event | DTO input/output | Phase |
| --- | --- | --- | --- | --- | --- |
| `get_procurement_dashboard_summary` | owner/admin, procurement_admin, assigned sales scoped | None | optional read trace | input: org scope/filter; output: dashboard summary DTO | 3C |
| `list_procurement_customers` | owner/admin, procurement_admin, assigned sales scoped | None | optional read trace | input: filters/page; output: customer list DTO | 3C |
| `get_procurement_customer_detail` | owner/admin, procurement_admin, assigned sales, customer user own customer | None | optional read trace | input: customer_id; output: customer detail DTO | 3C |
| `list_procurement_products` | owner/admin, procurement_admin, sales; customer portal later customer-visible only | None | optional read trace | input: category/status/page; output: product list DTO | 3C |
| `list_quote_requests` | owner/admin, procurement_admin, assigned sales, customer own requests later | None | optional read trace | input: status/customer/source; output: quote request list DTO | 3C |
| `list_quote_drafts` | owner/admin, procurement_admin, assigned sales | None | optional read trace | input: approval_state/customer; output: quote draft list DTO | 3C |
| `list_order_drafts` | owner/admin, procurement_admin, assigned sales | None | optional read trace | input: status/customer; output: order draft list DTO | 3C |
| `list_procurement_orders` | owner/admin, procurement_admin, assigned sales, customer own confirmed orders later | None | optional read trace | input: status/customer; output: order list DTO | 3C/3F |
| `get_pricing_governance_summary` | owner/admin, procurement_admin, pricing reviewer | None | optional read trace | input: org/customer/category; output: pricing governance DTO | 3C |

## 3. Write Draft-Only APIs / RPCs

| API/RPC | Actor allowed | Required approval | Audit event | DTO input/output | Phase |
| --- | --- | --- | --- | --- | --- |
| `create_quote_request` | procurement_admin, assigned sales, future customer portal | None for intake | `quote_request_created` | input: customer, source, requested items; output: quote request DTO | 3D |
| `create_quote_draft` | procurement_admin, assigned sales, AI-assisted service after review | Human approval before customer-facing quote | `quote_draft_created` | input: quote_request_id, draft lines; output: quote draft DTO | 3D |
| `update_quote_draft` | procurement_admin, assigned sales | Pricing approval if price/risk threshold affected | `quote_draft_updated` | input: quote_draft_id, line changes; output: quote draft DTO | 3D |
| `submit_quote_draft_for_approval` | procurement_admin, assigned sales | Moves to review; not final approval | `quote_draft_submitted_for_approval` | input: quote_draft_id; output: approval state | 3D |
| `create_order_draft` | procurement_admin, assigned sales, future customer portal | Confirmation required before order | `order_draft_created` | input: customer, source quote/draft lines; output: order draft DTO | 3D |
| `update_order_draft` | procurement_admin, assigned sales | Confirmation required if terms change | `order_draft_updated` | input: order_draft_id, item changes; output: order draft DTO | 3D |

Draft-only rules:

1. Draft writes do not create real orders.
2. Draft writes do not reserve or deduct inventory.
3. Draft writes do not activate price rules.
4. Draft writes must be reversible or archivable.

## 4. Approval-Gated APIs / RPCs

| API/RPC | Actor allowed | Required approval | Audit event | DTO input/output | Phase |
| --- | --- | --- | --- | --- | --- |
| `approve_quote` | owner/admin, pricing reviewer, assigned sales where allowed | Human pricing/sales approval | `quote_approved`, `quote_issued` if issued | input: quote_draft_id, approval reason, valid_until; output: issued `procurement_quote` DTO | 3E |
| `confirm_order` | owner/admin, assigned sales with customer confirmation | Customer + sales/system approval | `order_confirmed` | input: order_draft_id, confirmation refs; output: order DTO | 3E |
| `mark_supplier_procurement_required` | procurement_admin, assigned sales | Procurement review | `supplier_procurement_required_marked` | input: order/quote item refs; output: status | 3E |
| `mark_inventory_allocation_required` | procurement_admin, fulfillment coordinator | Fulfillment/inventory review | `inventory_allocation_required_marked` | input: order item refs; output: status | 3E |

Approval rules:

1. Approval APIs must validate actor role and scope.
2. Approval APIs must append audit before or atomically with state transition.
3. AI agents cannot call approval APIs as final actor.
4. `approve_quote` should create or reference an immutable issued quote version before customer-facing confirmation.
5. `confirm_order` must not deduct inventory.

## 5. Forbidden In Early Phase

| Forbidden API/RPC | Reason |
| --- | --- |
| `direct_price_rule_update_from_ui` | Pricing rules require backend validation and approval |
| `direct_inventory_deduct_from_ui` | Inventory mutation belongs to inventory/fulfillment domain |
| `ai_auto_confirm_order` | AI cannot bypass human approval |
| `ai_auto_update_price_book` | AI cannot update governed pricing |

Hard blocks:

1. No direct frontend writes to price rules.
2. No direct frontend inventory deduction.
3. No AI finalization for quote/order/pricing.
4. No service role write without audit.

## 6. DTO Contract References

Read DTOs should align with:

1. `PROCUREMENT_API_READ_MODEL_CONTRACT.md`
2. `CUSTOMER_CONTEXT_GOVERNANCE.md`
3. `PROCUREMENT_CANONICAL_DATA_CONTRACT.md`

Write DTOs should be drafted before Phase 3D and include:

1. Actor identity.
2. Organization scope.
3. Customer scope.
4. Idempotency key where external intake exists.
5. Audit metadata.
6. Approval reason where required.

## 7. Phase Availability Summary

| Phase | API/RPC posture |
| --- | --- |
| 3A | Contract draft only |
| 3B | Staging migration only |
| 3C | Read APIs/RPCs |
| 3D | Draft write APIs/RPCs |
| 3E | Approval gates |
| 3F | Customer portal backend |

No API/RPC above should be implemented before CTO review of RLS, audit, table naming, rollback, and staging strategy.
