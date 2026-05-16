# Procurement Phase 3A DB Migration Draft

Status: Draft
Date: 2026-05-16
Scope: Documentation / architecture / migration draft only

本文件是 migration draft，不是真正 migration 檔。

本輪禁止實際 migration、production code、API route implementation、Edge Function implementation、LINE integration、AI pricing automation、Readdy UI work、secrets / env access。

Phase 3B-1 update: CTO accepted the Phase 3A gate direction and allowed a staging-only schema skeleton file. The Phase 3B-1 file is a prepared migration draft only; it must not be executed without explicit approval.

## 1. Draft Principles

1. All tables are proposed and require CTO review.
2. Names are draft names, not final schema authorization.
3. Most tables require `organization_id`.
4. Master data uses soft archive.
5. Transactional records use status transitions and audit events.
6. Pricing and order confirmation require approval gates.
7. AI events are trace records, not authority to finalize actions.
8. Phase 3B full implementation should include an issued quote table between quote drafts and order drafts.
9. Phase 3B full implementation should decide whether product categories and price book items are normalized tables; this draft recommends normalizing both.
10. Phase 3B-1 intentionally limits the first staging skeleton to customer, catalog, quote request, quote draft, quote draft item, and audit foundation tables.

## 2. Table Drafts

### 2.1 `procurement_customers`

Purpose: Canonical procurement customer account.

Key columns: `id`, `organization_id`, `customer_code`, `display_name`, `segment`, `identity_status`, `merge_candidate_of`, `status`, `tags`, `archived_at`, `archived_reason`, `created_at`, `updated_at`.

Relationships: parent to locations, users, sales assignments, quote requests, drafts, orders, lists.

Indexes: `(organization_id)`, `(organization_id, status)`, unique `(organization_id, customer_code)`, search index on display name.

RLS expectation: owner/admin all; sales assigned; customer users own customer only.

Audit expectation: create, update, archive, merge, identity repair.

Future migration risk: duplicate identity and cross-domain customer mapping with Sake/Meat.

Phase 3B-1 decision: do not automate merge/dedup and do not create a merge function. The staging skeleton only reserves `merge_candidate_of`, `archived_at`, and `archived_reason` so suspected duplicates can be reviewed without silently granting access to another customer.

### 2.2 `procurement_customer_locations`

Purpose: Customer branch, billing, delivery, warehouse, or headquarters location.

Key columns: `id`, `organization_id`, `customer_id`, `label`, `type`, `address_json`, `receiving_notes`, `status`, `archived_at`.

Relationships: belongs to customer; referenced by quote/order drafts and customer users.

Indexes: `(organization_id, customer_id)`, `(customer_id, status)`.

RLS expectation: follows customer visibility plus location membership for customer users.

Audit expectation: create, update, archive.

Future migration risk: address normalization and historical order address snapshots.

### 2.3 `procurement_customer_users`

Purpose: Link authenticated user/contact to procurement customer account.

Key columns: `id`, `organization_id`, `customer_id`, `user_id`, `display_name`, `role`, `scoped_location_ids`, `status`, `archived_at`.

Relationships: belongs to customer; may scope to locations; used for portal access and confirmations.

Indexes: `(organization_id, customer_id)`, `(user_id)`, unique `(customer_id, user_id)`.

RLS expectation: customer users see own membership; owner/admin manage.

Audit expectation: invite, role change, deactivate, confirmation actor.

Future migration risk: user identity collision across customers and LINE linkage.

### 2.4 `procurement_sales_assignments`

Purpose: Assign sales rep ownership by customer/location/product line/time window.

Key columns: `id`, `organization_id`, `customer_id`, `customer_location_id`, `sales_rep_user_id`, `scope`, `effective_from`, `effective_to`, `status`.

Relationships: belongs to customer and optional location; gates sales access.

Indexes: `(organization_id, sales_rep_user_id)`, `(customer_id, status)`, `(effective_from, effective_to)`.

RLS expectation: owner/admin all; sales rep own assignments; customer users no access unless summarized.

Audit expectation: assignment create/update/archive/reassignment.

Future migration risk: overlapping assignments and historical ownership preservation.

### 2.5 `procurement_products`

Purpose: Procurement product family/concept.

Key columns: `id`, `organization_id`, `category_id`, `product_code`, `name`, `status`, `source_domain`, `archived_at`.

Relationships: parent to variants; may map to Sake/Meat domain products.

Indexes: `(organization_id, category)`, `(organization_id, status)`, unique `(organization_id, product_code)`.

RLS expectation: internal read; customer read only if product is customer-visible.

Audit expectation: create/update/archive, domain mapping changes.

Future migration risk: catalog duplication with existing Sake/Meat catalogs.

### 2.5A `procurement_product_categories`

Purpose: Normalized category taxonomy for sake, tableware, meat, seafood, other, and future categories.

Key columns: `id`, `organization_id`, `category_code`, `display_name`, `parent_category_id`, `status`, `sort_order`, `archived_at`.

Relationships: parent to products; optional self-parent for category tree.

Indexes: unique `(organization_id, category_code)`, `(organization_id, status)`, `(parent_category_id)`.

RLS expectation: internal read; customer-visible categories only through approved catalog read model.

Audit expectation: create/update/archive/reorder.

Future migration risk: if Phase 3B uses enum-only categories, future category hierarchy and pricing rules will need a migration; normalized category table is recommended.

Phase 3B-1 status: deferred. The skeleton keeps `procurement_products.category` as a constrained text field because normalized category governance is not needed for the first read/quote-draft foundation.

### 2.6 `procurement_product_variants`

Purpose: SKU/spec/pack/unit sellable variant.

Key columns: `id`, `organization_id`, `product_id`, `variant_code`, `name`, `unit`, `pack_size`, `supply_type`, `status`, `archived_at`.

Relationships: belongs to product; referenced by supplier quotes, price rules, quote/order/list items.

Indexes: `(organization_id, product_id)`, `(supply_type)`, `(status)`, unique `(organization_id, variant_code)`.

RLS expectation: internal read; customer read only if visible.

Audit expectation: create/update/archive.

Future migration risk: variant identity changes and historical quote preservation.

### 2.7 `procurement_supplier_sources`

Purpose: Supplier/importer/producer/source channel.

Key columns: `id`, `organization_id`, `supplier_code`, `display_name`, `source_type`, `status`, `lead_time_days`, `archived_at`.

Relationships: parent to supplier quotes.

Indexes: `(organization_id, status)`, unique `(organization_id, supplier_code)`.

RLS expectation: internal only; customer users no access.

Audit expectation: create/update/archive.

Future migration risk: supplier confidentiality and product-line ownership.

### 2.8 `procurement_supplier_quotes`

Purpose: Supplier cost/availability/MOQ/lead-time quote.

Key columns: `id`, `organization_id`, `supplier_source_id`, `variant_id`, `cost_amount`, `currency`, `moq`, `lead_time_days`, `valid_until`, `status`.

Relationships: belongs to supplier and variant; referenced by quote drafts.

Indexes: `(organization_id, variant_id)`, `(supplier_source_id)`, `(valid_until)`, `(status)`.

RLS expectation: internal procurement/owner/admin only.

Audit expectation: create/update/expire/archive, use in quote draft.

Future migration risk: cost sensitivity and currency/landed cost semantics.

### 2.9 `procurement_price_books`

Purpose: Governed pricing layer.

Key columns: `id`, `organization_id`, `name`, `currency`, `status`, `effective_from`, `effective_to`, `version_no`, `archived_at`.

Relationships: referenced by customer price rules and quote draft pricing basis.

Indexes: `(organization_id, status)`, `(effective_from, effective_to)`.

RLS expectation: internal read; write through approved backend only.

Audit expectation: create/update/archive/version.

Future migration risk: missing price book item table or JSON shape; needs review.

Phase 3A review correction: price book item rows should be normalized instead of stored only as JSON.

### 2.9A `procurement_price_book_items`

Purpose: Versioned price entries inside a price book.

Key columns: `id`, `organization_id`, `price_book_id`, `variant_id`, `category_id`, `price_amount`, `currency`, `minimum_allowed_price`, `margin_floor_ref`, `effective_from`, `effective_to`, `version_no`, `status`.

Relationships: belongs to price book; references product variant or category.

Indexes: `(price_book_id)`, `(variant_id)`, `(category_id)`, `(effective_from, effective_to)`, unique `(price_book_id, variant_id, version_no)` where applicable.

RLS expectation: internal read; write through approved backend only.

Audit expectation: create/update/supersede/archive; price changes require before/after audit.

Future migration risk: money precision, category-level fallback precedence, version supersession rules.

Phase 3B-1 status: excluded. Pricing tables and supplier cost fields are intentionally not created in the first staging skeleton.

### 2.10 `procurement_customer_price_rules`

Purpose: Customer/category/product/variant-specific pricing rule.

Key columns: `id`, `organization_id`, `customer_id`, `price_book_id`, `scope_type`, `scope_id`, `rule_type`, `value`, `version_no`, `supersedes_rule_id`, `approval_status`, `approved_by_user_id`, `approved_at`, `effective_from`, `effective_to`.

Relationships: belongs to customer and optional price book; referenced by quote drafts.

Indexes: `(organization_id, customer_id)`, `(scope_type, scope_id)`, `(approval_status)`, `(effective_from, effective_to)`.

RLS expectation: internal only; customer sees resulting price only.

Audit expectation: create/update/approve/archive; frontend direct writes forbidden.

Future migration risk: pricing semantics, minimum margin thresholds, approval state.

Phase 3A review correction: customer price rules need explicit versioning and supersession before Phase 3B.

Phase 3B-1 status: excluded. No customer price rule table, price book table, supplier quote table, or pricing automation is included.

### 2.11 `procurement_quote_requests`

Purpose: Intake request from customer/sales/platform/manual/future LINE.

Key columns: `id`, `organization_id`, `customer_id`, `customer_location_id`, `source_channel`, `status`, `requested_summary`, `risk_flags`, `assigned_sales_rep_id`, `received_at`.

Relationships: belongs to customer; parent to quote drafts.

Indexes: `(organization_id, status)`, `(customer_id)`, `(assigned_sales_rep_id)`, `(source_channel)`, `(received_at)`.

RLS expectation: internal + assigned sales; customer own request visibility.

Audit expectation: create/status change/archive.

Future migration risk: source message references and future LINE idempotency.

### 2.12 `procurement_quote_drafts`

Purpose: Internal editable quote draft.

Key columns: `id`, `organization_id`, `quote_request_id`, `customer_id`, `status`, `approval_state`, `created_by_type`, `assigned_sales_rep_id`, `expires_at`, `risk_flags`.

Relationships: belongs to quote request/customer; parent to draft items; may produce order draft.

Indexes: `(organization_id, approval_state)`, `(customer_id)`, `(quote_request_id)`, `(assigned_sales_rep_id)`.

RLS expectation: internal + assigned sales only; customer not visible by default.

Audit expectation: create/update/submit/approve/reject.

Future migration risk: price snapshots and quote issuance model.

### 2.13 `procurement_quote_draft_items`

Purpose: Line items inside quote draft.

Key columns: `id`, `organization_id`, `quote_draft_id`, `variant_id`, `item_text`, `quantity`, `unit`, `draft_unit_price`, `pricing_basis`, `margin_flag`, `supplier_quote_id`.

Relationships: belongs to quote draft; references variant and optional supplier quote.

Indexes: `(quote_draft_id)`, `(variant_id)`, `(supplier_quote_id)`.

RLS expectation: inherits quote draft internal visibility.

Audit expectation: create/update/delete item while draft only.

Future migration risk: money precision, currency, tax, margin snapshot.

### 2.13A `procurement_quotes`

Purpose: Immutable customer-facing quote version issued from an approved quote draft.

Key columns: `id`, `organization_id`, `quote_draft_id`, `customer_id`, `customer_location_id`, `quote_number`, `version_no`, `status`, `issued_at`, `issued_by_user_id`, `valid_until`, `customer_visible_terms`, `customer_visible_total`, `currency`, `supersedes_quote_id`, `customer_confirmation_status`, `customer_confirmed_at`.

Relationships: belongs to customer and source quote draft; may be superseded by another quote; may produce order draft.

Indexes: `(organization_id, customer_id)`, unique `(organization_id, quote_number, version_no)`, `(quote_draft_id)`, `(status)`, `(valid_until)`.

RLS expectation: internal + assigned sales; customer can see only issued own quotes and never internal margin/cost.

Audit expectation: issue, supersede, expire, customer confirm, cancel.

Future migration risk: quote item snapshot may require a separate `procurement_quote_items` table before Phase 3B if line-level issued quote history cannot be safely stored in immutable JSON.

### 2.14 `procurement_order_drafts`

Purpose: Pre-confirmation order candidate.

Key columns: `id`, `organization_id`, `customer_id`, `source_channel`, `source_quote_id`, `source_quote_draft_id`, `status`, `fulfillment_status`, `assigned_sales_rep_id`, `risk_flags`.

Relationships: belongs to customer; may derive from issued quote or draft-only source; parent to order draft items; may become order.

Indexes: `(organization_id, status)`, `(customer_id)`, `(assigned_sales_rep_id)`.

RLS expectation: internal + assigned sales; future customer access only when enabled.

Audit expectation: create/update/customer confirmation/sales review.

Future migration risk: conversion semantics to confirmed orders.

Phase 3A review correction: `source_quote_id` should be preferred over `source_quote_draft_id` when customer-facing pricing is involved.

### 2.15 `procurement_order_draft_items`

Purpose: Items inside order draft.

Key columns: `id`, `organization_id`, `order_draft_id`, `variant_id`, `quantity`, `unit`, `draft_unit_price`, `source_quote_draft_item_id`.

Relationships: belongs to order draft; references variant and optional quote item.

Indexes: `(order_draft_id)`, `(variant_id)`.

RLS expectation: inherits order draft visibility.

Audit expectation: create/update/delete before confirmation.

Future migration risk: preserving price/terms from quote to order.

### 2.16 `procurement_orders`

Purpose: Confirmed order after required approvals.

Key columns: `id`, `organization_id`, `customer_id`, `source_order_draft_id`, `order_number`, `status`, `confirmed_at`, `confirmed_by_user_id`, `fulfillment_status`.

Relationships: parent to order items; derives from order draft.

Indexes: `(organization_id, status)`, `(customer_id)`, unique `(organization_id, order_number)`.

RLS expectation: internal + assigned sales; customer own confirmed orders.

Audit expectation: confirmation required; cancellation/void required.

Future migration risk: must not bypass approval or inventory boundaries.

### 2.17 `procurement_order_items`

Purpose: Confirmed order line items.

Key columns: `id`, `organization_id`, `order_id`, `variant_id`, `quantity`, `unit`, `unit_price`, `line_total`, `fulfillment_status`.

Relationships: belongs to order; references variant.

Indexes: `(order_id)`, `(variant_id)`, `(fulfillment_status)`.

RLS expectation: inherits order visibility; hides internal cost/margin.

Audit expectation: immutable after confirmation except correction/void flow.

Future migration risk: tax, currency, corrections, fulfillment linkage.

### 2.18 `procurement_lists`

Purpose: Customer reusable purchasing list.

Key columns: `id`, `organization_id`, `customer_id`, `customer_location_id`, `name`, `status`, `archived_at`.

Relationships: parent to list items; can seed quote/order drafts.

Indexes: `(organization_id, customer_id)`, `(customer_location_id)`, `(status)`.

RLS expectation: internal + assigned sales + customer own lists.

Audit expectation: create/update/archive.

Future migration risk: customer edit permissions and recommendation memory.

### 2.19 `procurement_list_items`

Purpose: Item inside reusable purchasing list.

Key columns: `id`, `organization_id`, `procurement_list_id`, `variant_id`, `preferred_quantity`, `unit`, `notes`, `status`.

Relationships: belongs to procurement list; references variant.

Indexes: `(procurement_list_id)`, `(variant_id)`, `(status)`.

RLS expectation: inherits list visibility.

Audit expectation: create/update/archive item.

Future migration risk: unavailable variants and substitution policy.

### 2.20 `procurement_audit_events`

Purpose: Append-only audit trail.

Key columns: `id`, `organization_id`, `actor_user_id`, `actor_type`, `event_type`, `subject_type`, `subject_id`, `customer_id`, `risk_class`, `metadata`, `created_at`.

Relationships: references subjects by type/id; customer scoped when applicable.

Indexes: `(organization_id, created_at)`, `(subject_type, subject_id)`, `(customer_id)`, `(event_type)`.

RLS expectation: owner/admin full; scoped internal; customer-safe audit limited if ever exposed.

Audit expectation: append-only; no update/delete except admin repair policy.

Future migration risk: metadata secrets and retention policy.

### 2.21 `procurement_ai_events`

Purpose: AI-related intake, suggestion, draft, and recommendation trace.

Key columns: `id`, `organization_id`, `customer_id`, `source_channel`, `event_type`, `risk_class`, `status`, `source_ref`, `payload_summary`, `created_by_agent`, `created_at`.

Relationships: may reference quote request/draft/order draft; linked to audit events.

Indexes: `(organization_id, customer_id)`, `(event_type)`, `(risk_class)`, `(created_at)`.

RLS expectation: AI-safe/internal only; no customer cross-leakage.

Audit expectation: AI event creation and human approval linkage.

Future migration risk: raw message privacy, LINE identity linkage, AI memory retention.

## 3. Phase 3B Migration Draft Notes

Before turning this into a real migration:

1. Confirm table names and schema namespace.
2. Confirm `procurement_product_categories` normalization.
3. Confirm `procurement_price_book_items` normalization.
4. Confirm `procurement_quotes` and whether line snapshots require `procurement_quote_items`.
5. Confirm money/currency precision.
6. Confirm customer dedupe/merge constraints.
7. Confirm sales assignment overlap rules.
8. Confirm RLS helper functions.
9. Confirm seed/mock strategy.
10. Confirm rollback plan.

## 4. Phase 3B-1 Staging Skeleton Mapping

Prepared migration draft:

```text
supabase/migrations/20260516_procurement_phase3b1_schema_skeleton.sql
```

Phase 3B-1 creates only:

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

Phase 3B-1 explicitly excludes:

1. Production migration execution.
2. `procurement_quotes`, `procurement_quote_items`, order drafts, orders, inventory mutation.
3. Supplier cost, price books, customer price rules, margin automation.
4. LINE integration, AI pricing automation, Edge Functions, production API routes.
5. Real customer seed data.
