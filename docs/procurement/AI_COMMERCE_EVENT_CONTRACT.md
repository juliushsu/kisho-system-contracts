# AI Commerce Event Contract

Status: Proposed
Date: 2026-05-15
Scope: Documentation / governance / architecture only

本輪為 canonical contracts phase only。

本文件不涉及 production code、不涉及 DB migration、不涉及 secrets / env、不涉及 Readdy UI 修改、不產生 API route、不實作 Edge Function。後續需由 CTO review 後才可進入 implementation phase。

## 1. Purpose

This document defines canonical commerce events for the LINE -> AI -> Sales -> Customer -> Order flow.

Events in this document are conceptual contracts. They do not authorize event tables, queues, API routes, Edge Functions, or production automation.

## 2. Event Risk Classes

| Risk class | Meaning | AI behavior |
| --- | --- | --- |
| `low` | Summary, search, classification, draft assistance | AI may execute within scoped access |
| `medium` | Creates customer-facing draft or requires sales/customer response | AI may create draft; human review may be required |
| `high_pricing` | Affects price, margin, discount, cost, or customer-specific pricing | Human approval required |
| `high_commitment` | Confirms order, supplier commitment, inventory allocation, shipment readiness | Human/system approval required |

## 3. Event Catalog

| Event | Purpose | AI auto? | Human approval | Risk |
| --- | --- | --- | --- | --- |
| `inquiry_received` | Capture customer inquiry from LINE, `/b2b`, or sales | Yes, for intake | No for intake; yes for identity ambiguity | low |
| `ai_product_search` | Search or classify requested products | Yes | No, unless ambiguous substitution is customer-facing | low |
| `quote_draft_created` | Create internal quote draft | Yes, draft only | Required before customer-facing quote | medium / high_pricing if price included |
| `sales_review_required` | Notify sales that review is required | Yes | Sales must review | medium |
| `customer_confirmation_pending` | Customer-facing confirmation is pending | System/AI may prepare message | Customer confirmation required | medium |
| `order_confirmed` | Confirmed order created after approvals | No | Customer and sales/system approval required | high_commitment |
| `supplier_procurement_required` | Supplier sourcing is needed | AI may flag | Procurement approval required before supplier commitment | high_commitment |
| `inventory_allocation` | Inventory allocation requested or planned | AI may suggest | System/human policy required before reservation/deduction | high_commitment |
| `shipment_ready` | Order appears ready for shipment | AI may suggest readiness | Fulfillment confirmation required | high_commitment |
| `followup_recommendation` | Suggest follow-up action | Yes | Human decides whether to act | low / medium |

## 4. LINE -> AI -> Sales -> Customer -> Order Flow

Canonical flow:

```text
LINE inquiry
-> inquiry_received
-> ai_product_search
-> quote_draft_created
-> sales_review_required
-> customer_confirmation_pending
-> order_confirmed
-> supplier_procurement_required / inventory_allocation
-> shipment_ready
-> followup_recommendation
```

Human checkpoints:

```text
AI can intake and draft
-> Sales reviews pricing, supply, margin, and wording
-> Customer confirms quote/order intent
-> Sales or system confirms final order
-> Fulfillment/procurement confirms downstream action
```

## 5. Event Contracts

### 5.1 `inquiry_received`

Purpose: Records that a customer or sales user initiated a procurement inquiry.

Potential sources:

- Customer LINE message
- Sales LINE message
- `/b2b` form or cart
- `/procurement-admin` manual entry

Recommended payload concepts:

| Field | Meaning |
| --- | --- |
| `event_id` | Immutable event UUID |
| `source_channel` | line_customer, line_sales, b2b, procurement_admin |
| `source_message_ref` | Safe reference or summary, not raw secret-bearing payload |
| `customer_context_ref` | Resolved or candidate customer context |
| `raw_intent_summary` | AI/user-safe inquiry summary |
| `received_at` | Intake timestamp |
| `idempotency_key` | Prevent duplicate event ingestion |

AI execution: Allowed for intake and summary.

Human approval: Required if customer identity is ambiguous or sensitive action is requested.

### 5.2 `ai_product_search`

Purpose: Captures AI or system product matching against canonical catalog.

Recommended payload concepts:

| Field | Meaning |
| --- | --- |
| `query_text` | Customer-safe query text |
| `candidate_products` | Product/variant candidates |
| `confidence` | AI/system confidence |
| `unresolved_terms` | Terms requiring sales clarification |
| `customer_context_ref` | Scoped context |

AI execution: Allowed.

Human approval: Required before using uncertain matches in customer-facing quotes.

High-risk pricing: No, unless AI attempts to infer price from non-approved sources.

### 5.3 `quote_draft_created`

Purpose: Creates an internal quote draft for review.

Recommended payload concepts:

| Field | Meaning |
| --- | --- |
| `quote_request_id` | Source request |
| `quote_draft_id` | Internal draft |
| `draft_lines` | Candidate products, quantities, units |
| `pricing_basis` | price book, customer rule, manual review required |
| `margin_flags` | Internal risk flags |
| `created_by` | ai, sales, procurement_user |

AI execution: Allowed only as draft.

Human approval: Required before quote is sent to customer.

High-risk pricing: Yes if it includes discount, margin, customer-specific price, or supplier quote interpretation.

### 5.4 `sales_review_required`

Purpose: Signals that a sales owner must review a draft, ambiguity, price issue, or customer action.

Recommended payload concepts:

| Field | Meaning |
| --- | --- |
| `sales_rep_id` | Assigned owner |
| `review_reason` | pricing, identity, substitution, supplier, margin, customer_confirmation |
| `due_at` | Suggested response deadline |
| `risk_class` | low, medium, high_pricing, high_commitment |

AI execution: Allowed to create notification/recommendation.

Human approval: Sales review is the approval action.

### 5.5 `customer_confirmation_pending`

Purpose: Indicates that the customer must confirm quote/order terms.

Recommended payload concepts:

| Field | Meaning |
| --- | --- |
| `quote_id` | Issued quote |
| `order_draft_id` | Optional draft order |
| `confirmation_channel` | LINE, b2b, sales_assisted |
| `terms_summary` | Customer-visible summary |
| `expires_at` | Quote or confirmation expiration |

AI execution: AI may draft confirmation message.

Human approval: Customer confirmation required; sales may also need to approve final language.

High-risk pricing: Yes if terms include temporary price, exception, or margin-sensitive discount.

### 5.6 `order_confirmed`

Purpose: Records that an order has been formally confirmed after required approvals.

Recommended payload concepts:

| Field | Meaning |
| --- | --- |
| `order_id` | Confirmed order |
| `source_quote_id` | Source quote if any |
| `customer_confirmation_ref` | Confirmation trace |
| `sales_confirmation_ref` | Sales/system approval trace |
| `confirmed_at` | Confirmation timestamp |

AI execution: Not allowed.

Human approval: Required.

High-risk pricing: Often yes; confirmed price must be from approved quote or policy.

### 5.7 `supplier_procurement_required`

Purpose: Signals that an order or quote requires supplier sourcing or replenishment.

Recommended payload concepts:

| Field | Meaning |
| --- | --- |
| `order_or_quote_ref` | Related order/quote |
| `product_variant_id` | Variant requiring sourcing |
| `supplier_source_candidates` | Candidate suppliers |
| `required_by` | Date needed |
| `risk_notes` | MOQ, lead time, volatility |

AI execution: AI may flag and summarize.

Human approval: Required before supplier commitment or purchase order.

High-risk pricing: Yes if supplier cost changes customer price or margin.

### 5.8 `inventory_allocation`

Purpose: Requests or suggests inventory allocation for confirmed or pending order items.

Recommended payload concepts:

| Field | Meaning |
| --- | --- |
| `order_id` | Confirmed order |
| `order_item_id` | Item needing allocation |
| `allocation_mode` | suggest, reserve, allocate |
| `inventory_ref` | Inventory position/batch reference if known |
| `policy_result` | allowed, review_required, blocked |

AI execution: AI may suggest only.

Human/system approval: Required for reservation, allocation, deduction, or irreversible fulfillment.

High-risk pricing: No by itself, but high commitment.

### 5.9 `shipment_ready`

Purpose: Signals that an order appears ready for fulfillment or shipping.

Recommended payload concepts:

| Field | Meaning |
| --- | --- |
| `order_id` | Confirmed order |
| `readiness_summary` | Fulfillment readiness |
| `blocking_items` | Missing allocations, customer info, payment, cold-chain constraints |
| `recommended_action` | Prepare shipment, wait, review |

AI execution: AI may suggest.

Human/system approval: Fulfillment owner confirms actual readiness.

High-risk pricing: No, but high commitment.

### 5.10 `followup_recommendation`

Purpose: Suggests a follow-up for sales, procurement, or customer success.

Recommended payload concepts:

| Field | Meaning |
| --- | --- |
| `customer_context_ref` | Scoped customer context |
| `reason` | stale_quote, recurring_order_window, missing_confirmation, supplier_delay |
| `recommended_owner` | Sales/procurement user |
| `suggested_message` | Draft message |
| `confidence` | AI/system confidence |

AI execution: Allowed for suggestion and draft.

Human approval: Human decides whether to send or act.

High-risk pricing: Only if recommendation includes discount or price change.

## 6. High-Risk Pricing Actions

The following always require human approval:

1. Creating or changing customer-specific pricing.
2. Applying discounts below minimum allowed pricing.
3. Using supplier quote data to change customer-facing quote.
4. Extending expired quote prices.
5. Substituting items with materially different margin.
6. Campaign pricing exceptions.
7. Imported liquor or aged meat volatility adjustments.

## 7. Event Idempotency And Audit

Required principles:

1. Every event has immutable `event_id`.
2. External message ingestion uses `idempotency_key`.
3. AI-created drafts link back to source event.
4. Human approvals link to event and user identity.
5. Customer confirmations preserve channel and timestamp.
6. Events should be append-only in future implementation.

## 8. Implementation Gate

Before implementation:

1. Confirm event storage approach.
2. Confirm customer context reference model.
3. Confirm LINE webhook idempotency strategy.
4. Confirm human approval state machine.
5. Confirm pricing risk classifier and approval thresholds.
