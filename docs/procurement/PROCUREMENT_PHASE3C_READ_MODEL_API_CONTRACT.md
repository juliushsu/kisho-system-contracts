# Procurement Phase 3C Read Model API Contract

Status: Proposed
Date: 2026-05-16
Scope: Documentation / read model API contract only

本輪只定義 Phase 3C read model API contracts。

本文件不實作 API route、不執行 migration、不碰 production、不接 LINE、不做 AI pricing automation、不改 Readdy UI、不碰 secrets / env。

## 1. Purpose

Phase 3C moves `/procurement-admin` from mock-only data toward safe read-only backend data after Phase 3B disposable dry-run evidence is reviewed.

The goal is to support Readdy VER294 Procurement Phase 2 shell pages without granting direct table access from Readdy UI.

Hard rule:

```text
Readdy UI must call read model endpoints/RPCs only. It must not query base procurement tables directly.
```

## 2. Global Read Model Rules

1. All endpoints are read-only.
2. Every request requires `organization_id`.
3. Customer users are not in Phase 3C admin read model.
4. `/procurement-admin` actors are owner/admin, procurement admin, and assigned sales where scoped.
5. Supplier cost, internal margin, landed cost, margin floors, pricing guardrail thresholds, and supplier confidential details must not be exposed to general sales.
6. `procurement_audit_events` is not available through general read APIs.
7. Quote drafts are visible only to owner/admin, procurement admin, and assigned sales scope; never to customer users.
8. Order draft read model remains future/mock in Phase 3C because Phase 3B-1 did not create order draft tables.
9. Pricing governance summary must be safe and must not return supplier cost or internal guardrail thresholds.
10. All endpoints must be backed by RLS-safe views/RPCs or server-side read models that enforce tenant and actor scope.

## 3. Shared Request / Response Envelope

Recommended input envelope:

```ts
export interface ProcurementReadModelRequestBase {
  organizationId: string;
  actorUserId: string;
  actorRole: 'owner' | 'admin' | 'procurement_admin' | 'sales';
  traceId?: string;
}
```

Recommended response envelope:

```ts
export interface ProcurementReadModelResponseBase {
  mode: 'safe_read_only';
  organizationId: string;
  generatedAt: string;
  traceId: string;
  warnings: ProcurementReadModelWarning[];
}

export interface ProcurementReadModelWarning {
  level: 'info' | 'warning' | 'blocked';
  code: string;
  message: string;
}
```

Standard failure states:

| Code | Meaning |
| --- | --- |
| `UNAUTHENTICATED` | Actor is not authenticated |
| `FORBIDDEN_ORG_SCOPE` | Actor cannot access `organization_id` |
| `FORBIDDEN_CUSTOMER_SCOPE` | Actor cannot access requested customer |
| `FORBIDDEN_ROLE` | Actor role is not allowed for this endpoint |
| `READ_MODEL_NOT_READY` | Endpoint is not available in this phase |
| `VALIDATION_ERROR` | Invalid filter, pagination, or sort |
| `SAFE_FIELD_BLOCKED` | Requested field is intentionally excluded |
| `INTERNAL_ERROR` | Unexpected backend error without leaking internals |

## 4. Sensitive Field Blocklist

The following fields/classes are blocked from Phase 3C admin read models unless a later CTO-approved contract explicitly allows them:

1. Supplier cost.
2. Landed cost.
3. Internal margin amount or percentage.
4. Margin floors and minimum allowed price thresholds.
5. Internal pricing guardrail thresholds.
6. Supplier confidential terms.
7. Raw `procurement_audit_events`.
8. Raw LINE IDs or payloads.
9. Secrets, tokens, env values, DB URLs, service role keys.
10. Customer private notes not approved for `/procurement-admin` read model.
11. AI prompts, memory, embeddings, or hidden reasoning.

General sales may receive safe labels such as `pricingReviewRequired`, `supplierReviewRequired`, or `marginDisplayMode: 'hidden'`, but not the underlying confidential numbers.

## 5. Endpoint Contracts

### 5.1 `get_procurement_dashboard_summary`

Purpose: Provide safe counters and queue previews for `/procurement-admin` overview.

Actor allowed: owner/admin, procurement admin, assigned sales scoped to their assigned customers.

Required `organization_id`: Yes.

RLS expectation: owner/admin/procurement admin can see organization-scoped safe summary; assigned sales receives only assigned-customer queue counts.

Source tables:

1. `procurement_customers`
2. `procurement_customer_locations`
3. `procurement_sales_assignments`
4. `procurement_quote_requests`
5. `procurement_quote_drafts`
6. `procurement_quote_draft_items`
7. `procurement_products`
8. `procurement_product_variants`

Excluded sensitive fields: supplier cost, internal margin, pricing guardrail values, raw audit events, raw customer private metadata.

DTO shape:

```ts
export interface GetProcurementDashboardSummaryInput extends ProcurementReadModelRequestBase {
  dateFrom?: string;
  dateTo?: string;
}

export interface GetProcurementDashboardSummaryOutput extends ProcurementReadModelResponseBase {
  counters: {
    inquiriesToday: number;
    quoteDraftsAwaitingReview: number;
    supplierSourcedItemsAwaitingReview: number;
    pricingReviewRequired: number;
    activeCustomers: number;
  };
  queues: {
    recentQuoteRequests: ProcurementQueueItemDTO[];
    quoteDraftsAwaitingReview: ProcurementQueueItemDTO[];
    supplierReviewItems: ProcurementQueueItemDTO[];
    pricingReviewItems: ProcurementQueueItemDTO[];
  };
}
```

Pagination/filter/sort: queue previews default to 10 items; sort by `updatedAt desc`; optional date range.

Audit/logging expectation: safe read trace only; do not write `procurement_audit_events` for normal reads.

Phase availability: Phase 3C after disposable dry-run passes and CTO approves read model implementation.

Failure states: `FORBIDDEN_ORG_SCOPE`, `READ_MODEL_NOT_READY`, `VALIDATION_ERROR`.

### 5.2 `list_procurement_customers`

Purpose: Provide `/procurement-admin/customers` list without direct table access.

Actor allowed: owner/admin, procurement admin, assigned sales scoped to assigned customers.

Required `organization_id`: Yes.

RLS expectation: assigned sales sees only active assigned customers within effective assignment windows.

Source tables:

1. `procurement_customers`
2. `procurement_customer_locations`
3. `procurement_customer_users`
4. `procurement_sales_assignments`
5. `procurement_quote_requests`
6. `procurement_quote_drafts`

Excluded sensitive fields: raw customer metadata, internal segmentation not approved for admin list, raw user auth data, audit events, supplier/margin/pricing internals.

DTO shape:

```ts
export interface ListProcurementCustomersInput extends ProcurementReadModelRequestBase {
  page?: number;
  pageSize?: number;
  status?: 'active' | 'inactive' | 'archived' | 'review_required';
  search?: string;
  assignedSalesRepId?: string;
  sort?: 'displayName_asc' | 'lastActivity_desc' | 'createdAt_desc';
}

export interface ListProcurementCustomersOutput extends ProcurementReadModelResponseBase {
  customers: ProcurementCustomerSummaryDTO[];
  pageInfo: ProcurementPageInfo;
}
```

Pagination/filter/sort: default `pageSize = 25`, max `100`; search applies to safe customer code/display name only.

Audit/logging expectation: read trace; no audit event.

Phase availability: Phase 3C.

Failure states: `FORBIDDEN_ROLE`, `FORBIDDEN_ORG_SCOPE`, `VALIDATION_ERROR`.

### 5.3 `get_procurement_customer_detail`

Purpose: Provide a safe internal customer detail view for `/procurement-admin/customers/:customerId`.

Actor allowed: owner/admin, procurement admin, assigned sales scoped to the requested customer.

Required `organization_id`: Yes.

RLS expectation: assigned sales must have an active effective-window assignment for the customer.

Source tables:

1. `procurement_customers`
2. `procurement_customer_locations`
3. `procurement_customer_users`
4. `procurement_sales_assignments`
5. `procurement_quote_requests`
6. `procurement_quote_drafts`

Excluded sensitive fields: auth secrets, raw LINE identity, audit events, internal merge notes, hidden customer tags, supplier cost, margin, guardrails.

DTO shape:

```ts
export interface GetProcurementCustomerDetailInput extends ProcurementReadModelRequestBase {
  customerId: string;
}

export interface GetProcurementCustomerDetailOutput extends ProcurementReadModelResponseBase {
  customer: ProcurementCustomerDetailDTO;
}
```

Pagination/filter/sort: nested `quoteRequests` and `quoteDrafts` should default to most recent 10 each; no unbounded nested lists.

Audit/logging expectation: read trace; no audit event unless future owner/admin debug mode requires separate governance.

Phase availability: Phase 3C.

Failure states: `FORBIDDEN_CUSTOMER_SCOPE`, `READ_MODEL_NOT_READY`, `VALIDATION_ERROR`.

### 5.4 `list_procurement_products`

Purpose: Provide safe product catalog rows for `/procurement-admin/products`.

Actor allowed: owner/admin, procurement admin, assigned sales.

Required `organization_id`: Yes.

RLS expectation: only `is_customer_visible` product/variant rows may be exposed to sales by default; owner/admin/procurement admin can see active/internal catalog labels but not supplier cost.

Source tables:

1. `procurement_products`
2. `procurement_product_variants`

Excluded sensitive fields: supplier cost, internal supplier terms, hidden product mappings, inventory counts, landed cost, pricing guardrails.

DTO shape:

```ts
export interface ListProcurementProductsInput extends ProcurementReadModelRequestBase {
  page?: number;
  pageSize?: number;
  category?: 'sake' | 'tableware' | 'meat' | 'seafood' | 'other';
  status?: 'active' | 'inactive' | 'archived';
  supplyType?: 'fixed_stock_item' | 'supplier_sourced_item';
  search?: string;
  sort?: 'name_asc' | 'updatedAt_desc' | 'category_asc';
}

export interface ListProcurementProductsOutput extends ProcurementReadModelResponseBase {
  products: ProcurementProductSummaryDTO[];
  pageInfo: ProcurementPageInfo;
}
```

Pagination/filter/sort: default `pageSize = 50`, max `100`; search applies to safe product and variant names/codes.

Audit/logging expectation: read trace only.

Phase availability: Phase 3C.

Failure states: `FORBIDDEN_ORG_SCOPE`, `VALIDATION_ERROR`.

### 5.5 `list_procurement_quote_requests`

Purpose: Provide internal quote request queue for `/procurement-admin/quote-requests`.

Actor allowed: owner/admin, procurement admin, assigned sales scoped to assigned customers.

Required `organization_id`: Yes.

RLS expectation: no customer user access; assigned sales sees only assigned-customer quote requests.

Source tables:

1. `procurement_quote_requests`
2. `procurement_customers`
3. `procurement_customer_locations`
4. `procurement_sales_assignments`

Excluded sensitive fields: raw source payload, raw LINE IDs, internal risk notes beyond safe risk flags, audit events, supplier cost, margin.

DTO shape:

```ts
export interface ListProcurementQuoteRequestsInput extends ProcurementReadModelRequestBase {
  page?: number;
  pageSize?: number;
  status?: 'received' | 'triage' | 'drafting' | 'quoted' | 'cancelled' | 'archived';
  customerId?: string;
  sourceChannel?: 'manual' | 'sales' | 'platform' | 'line';
  assignedSalesRepId?: string;
  sort?: 'receivedAt_desc' | 'updatedAt_desc';
}

export interface ListProcurementQuoteRequestsOutput extends ProcurementReadModelResponseBase {
  quoteRequests: ProcurementQuoteRequestSummaryDTO[];
  pageInfo: ProcurementPageInfo;
}
```

Pagination/filter/sort: default `pageSize = 25`, max `100`; `sourceChannel = line` is allowed as stored/mock label only and does not imply live LINE integration.

Audit/logging expectation: read trace only; no audit event.

Phase availability: Phase 3C.

Failure states: `FORBIDDEN_ROLE`, `FORBIDDEN_CUSTOMER_SCOPE`, `VALIDATION_ERROR`.

### 5.6 `list_procurement_quote_drafts`

Purpose: Provide internal quote draft queue for `/procurement-admin/quote-drafts`.

Actor allowed: owner/admin, procurement admin, assigned sales scoped to assigned customers.

Required `organization_id`: Yes.

RLS expectation: quote drafts are internal only; never visible to customer users.

Source tables:

1. `procurement_quote_drafts`
2. `procurement_quote_draft_items`
3. `procurement_quote_requests`
4. `procurement_customers`
5. `procurement_products`
6. `procurement_product_variants`
7. `procurement_sales_assignments`

Excluded sensitive fields: supplier cost, internal margin amount/percent, raw pricing guardrails, approval notes not safe for sales, audit events.

DTO shape:

```ts
export interface ListProcurementQuoteDraftsInput extends ProcurementReadModelRequestBase {
  page?: number;
  pageSize?: number;
  approvalStatus?: 'not_submitted' | 'pending' | 'approved' | 'rejected';
  status?: 'draft' | 'submitted_for_approval' | 'approved_for_quote' | 'rejected' | 'cancelled' | 'archived';
  customerId?: string;
  assignedSalesRepId?: string;
  sort?: 'updatedAt_desc' | 'expiresAt_asc';
}

export interface ListProcurementQuoteDraftsOutput extends ProcurementReadModelResponseBase {
  quoteDrafts: ProcurementQuoteDraftSummaryDTO[];
  pageInfo: ProcurementPageInfo;
}
```

Pagination/filter/sort: default `pageSize = 25`, max `100`; nested lines should be capped or separately paginated if line volume grows.

Audit/logging expectation: read trace only; no audit event.

Phase availability: Phase 3C.

Failure states: `FORBIDDEN_ROLE`, `FORBIDDEN_CUSTOMER_SCOPE`, `SAFE_FIELD_BLOCKED`, `VALIDATION_ERROR`.

### 5.7 `list_procurement_order_drafts_mock_or_future`

Purpose: Preserve `/procurement-admin/orders` shell compatibility without implying real order backend readiness.

Actor allowed: owner/admin, procurement admin, assigned sales scoped if/when real order draft backend exists.

Required `organization_id`: Yes.

RLS expectation: no customer user access in Phase 3C admin read model. Real order draft RLS is future Phase 3D/3E work.

Source tables:

1. Phase 3C: none, or approved mock/read-model fixture.
2. Future: `procurement_order_drafts`, `procurement_order_draft_items`, `procurement_orders`, `procurement_order_items` after approved migration phase.

Excluded sensitive fields: real order confirmation status, fulfillment commitments, inventory reservations, inventory allocations, supplier cost, internal margin, audit events.

DTO shape:

```ts
export interface ListProcurementOrderDraftsMockOrFutureInput extends ProcurementReadModelRequestBase {
  page?: number;
  pageSize?: number;
  status?: string;
  customerId?: string;
}

export interface ListProcurementOrderDraftsMockOrFutureOutput extends ProcurementReadModelResponseBase {
  availability: 'mock_only' | 'future_backend_required';
  orderDrafts: ProcurementOrderDraftSummaryDTO[];
  pageInfo: ProcurementPageInfo;
}
```

Pagination/filter/sort: mock/future only; default empty list is acceptable.

Audit/logging expectation: read trace only.

Phase availability: Phase 3C mock/future marker only. Real order read belongs to a later gate after order tables exist.

Failure states: `READ_MODEL_NOT_READY`, `FORBIDDEN_ORG_SCOPE`.

### 5.8 `get_procurement_pricing_governance_summary_safe`

Purpose: Provide safe read-only pricing governance signals for `/procurement-admin/pricing`.

Actor allowed: owner/admin, procurement admin, pricing reviewer; assigned sales may receive limited safe status labels only.

Required `organization_id`: Yes.

RLS expectation: general sales must not see supplier cost, internal margin, margin floors, or guardrail thresholds.

Source tables:

1. Phase 3C with Phase 3B-1 schema: no pricing base tables exist; return safe availability/status from approved read model only.
2. Future: `procurement_price_books`, `procurement_price_book_items`, `procurement_customer_price_rules`, supplier quote summaries after approved migrations.

Excluded sensitive fields: supplier cost, landed cost, internal margin, minimum allowed price, guardrail thresholds, raw customer price rule formulas, approval notes not safe for sales.

DTO shape:

```ts
export interface GetProcurementPricingGovernanceSummarySafeInput extends ProcurementReadModelRequestBase {
  customerId?: string;
  category?: 'sake' | 'tableware' | 'meat' | 'seafood' | 'other';
}

export interface GetProcurementPricingGovernanceSummarySafeOutput extends ProcurementReadModelResponseBase {
  availability: 'safe_summary_only' | 'future_backend_required';
  summary: {
    priceBookStatus: 'not_available' | 'configured_future' | 'safe_read_only';
    customerRuleStatus: 'not_available' | 'configured_future' | 'safe_read_only';
    reviewRequiredCount: number;
    expiredRuleCount?: number;
    supplierVolatilityLabels: Array<'none' | 'supplier_review_required' | 'market_volatility' | 'seasonal_review'>;
  };
  visibleToSales: {
    canSeeSafeLabels: boolean;
    canSeeSupplierCost: false;
    canSeeInternalMargin: false;
    canSeeGuardrailThresholds: false;
  };
}
```

Pagination/filter/sort: not paginated in Phase 3C; filters are optional and safe.

Audit/logging expectation: read trace only; do not expose or query raw audit stream for general UI.

Phase availability: Phase 3C safe summary only; richer pricing read model requires future pricing table migrations and CTO review.

Failure states: `FORBIDDEN_ROLE`, `SAFE_FIELD_BLOCKED`, `READ_MODEL_NOT_READY`.

## 6. Shared Types

```ts
export interface ProcurementPageInfo {
  page: number;
  pageSize: number;
  totalCount: number;
  hasNextPage: boolean;
}
```

DTO references:

1. `ProcurementQueueItemDTO`
2. `ProcurementCustomerSummaryDTO`
3. `ProcurementCustomerDetailDTO`
4. `ProcurementProductSummaryDTO`
5. `ProcurementQuoteRequestSummaryDTO`
6. `ProcurementQuoteDraftSummaryDTO`
7. `ProcurementOrderDraftSummaryDTO`

These DTOs are defined or seeded by `PROCUREMENT_API_READ_MODEL_CONTRACT.md`; Phase 3C narrows their backend availability and safety rules.

## 7. Implementation Gate

Phase 3C implementation may be planned only after:

1. Phase 3B disposable dry-run passes.
2. Rollback is proven clean.
3. RLS denial tests pass.
4. CTO reviews dry-run evidence.
5. CTO approves read model implementation scope.

Phase 3C implementation must still not include:

1. Production writes.
2. Direct Readdy table access.
3. Customer-user admin read model access.
4. Audit event general read API.
5. LINE integration.
6. AI pricing automation.
7. Formal order creation.
8. Inventory mutation.
9. Pricing rule write APIs.
