# Procurement API Read Model Contract

Status: Proposed
Date: 2026-05-15
Scope: Phase 2 mock/read-only DTO contract

本輪仍以治理與實作前契約為主。

本文件不授權 production code、不授權 DB migration、不授權 secrets / env access、不授權 LINE integration、不授權 AI pricing automation、不授權正式訂單寫入、不授權真實扣庫存。

Phase 2 Readdy UI may use mock data or an existing safe read model that matches these DTO shapes. These DTOs are conceptual front-end contracts, not production API route definitions.

## 1. Purpose

This document defines the read-only data shapes Readdy may use for `/procurement-admin` Phase 2 shell.

It exists to keep mock data, future backend read models, and UI terminology aligned without implying production readiness.

## 2. Global Rules

| Rule | Requirement |
| --- | --- |
| Mock allowed | DTOs may be local fixtures |
| Read-only | DTOs must not imply write behavior |
| Safe by default | No secrets, tokens, DB URLs, LINE secrets, or supplier confidential details unless explicitly allowed |
| No real action | UI must not claim real order, real inventory deduction, or real quote activation |
| Stable IDs | Use mock UUID-like IDs or stable fixture IDs |
| Traceable | Include safe `traceId` when useful |

Recommended shared enums:

```ts
type ProcurementSourceChannel = 'line' | 'sales' | 'platform' | 'manual' | 'quote';
type ProcurementCategory = 'sake' | 'tableware' | 'meat' | 'seafood' | 'other';
type SupplyType = 'fixed_stock_item' | 'supplier_sourced_item';
type ArchiveStatus = 'active' | 'inactive' | 'archived';
type LineLinkageStatus = 'unlinked' | 'candidate_match' | 'linked_user' | 'linked_group' | 'suspended';
type ReviewRisk = 'none' | 'identity_ambiguous' | 'product_ambiguous' | 'supplier_required' | 'low_margin' | 'expired_quote' | 'inventory_required';
```

## 3. Dashboard Summary DTO

Purpose: Powers `/procurement-admin` Overview Dashboard.

```ts
export interface ProcurementDashboardSummaryDTO {
  mode: 'mock' | 'read_only';
  generatedAt: string;
  traceId: string;
  counters: {
    inquiriesToday: number;
    orderDraftsAwaitingSalesReview: number;
    supplierSourcedItemsAwaitingQuote: number;
    lowMarginAlerts: number;
    activeProcurementLists: number;
  };
  queues: {
    recentQuoteRequests: ProcurementQueueItemDTO[];
    orderDraftsAwaitingReview: ProcurementQueueItemDTO[];
    lowMarginDrafts: ProcurementQueueItemDTO[];
    supplierReviewItems: ProcurementQueueItemDTO[];
  };
  warnings: ProcurementShellWarningDTO[];
}

export interface ProcurementQueueItemDTO {
  id: string;
  code: string;
  title: string;
  customerId?: string;
  customerName?: string;
  status: string;
  sourceChannel?: ProcurementSourceChannel;
  assignedSalesRepName?: string;
  riskFlags: ReviewRisk[];
  updatedAt: string;
}

export interface ProcurementShellWarningDTO {
  level: 'info' | 'warning' | 'blocked';
  message: string;
  blockingReason?: string;
}
```

Phase 2 notes:

1. Counters can be mock.
2. Queue links can route to shell pages.
3. Do not show production readiness language.

## 4. Customer List DTO

Purpose: Powers `/procurement-admin/customers`.

```ts
export interface ProcurementCustomerListDTO {
  mode: 'mock' | 'read_only';
  generatedAt: string;
  traceId: string;
  customers: ProcurementCustomerSummaryDTO[];
}

export interface ProcurementCustomerSummaryDTO {
  customerId: string;
  customerCode: string;
  displayName: string;
  segment: 'restaurant' | 'restaurant_group' | 'bar' | 'hotel' | 'distributor' | 'corporate' | 'other';
  status: 'active' | 'review_required' | 'archived';
  locationCount: number;
  assignedSalesRep?: {
    salesRepId: string;
    displayName: string;
  };
  lineLinkageStatus: LineLinkageStatus;
  procurementPreferencesSummary: string[];
  openQuoteRequestCount: number;
  openOrderDraftCount: number;
  tags: string[];
  lastActivityAt?: string;
}
```

Optional customer detail shape:

```ts
export interface ProcurementCustomerDetailDTO extends ProcurementCustomerSummaryDTO {
  locations: CustomerLocationShellDTO[];
  customerUsers: CustomerUserShellDTO[];
  salesOwnership: SalesOwnershipShellDTO[];
  lineLinks: LineLinkShellDTO[];
  procurementPreferences: ProcurementPreferenceShellDTO;
  activeCommerceSummary: {
    quoteRequests: ProcurementQueueItemDTO[];
    quoteDrafts: ProcurementQueueItemDTO[];
    orderDrafts: ProcurementQueueItemDTO[];
  };
}

export interface CustomerLocationShellDTO {
  locationId: string;
  label: string;
  type: 'branch' | 'billing' | 'delivery' | 'warehouse' | 'headquarters';
  city?: string;
  district?: string;
  receivingNotes?: string;
  status: ArchiveStatus;
}

export interface CustomerUserShellDTO {
  userId: string;
  displayName: string;
  role: 'customer_owner' | 'customer_buyer' | 'customer_approver' | 'customer_viewer' | 'location_buyer';
  scopedLocationIds: string[];
  status: 'active' | 'inactive';
}

export interface SalesOwnershipShellDTO {
  salesRepId: string;
  displayName: string;
  scope: 'customer' | 'location' | 'product_line' | 'temporary';
  effectiveFrom: string;
  effectiveTo?: string;
}

export interface LineLinkShellDTO {
  linkId: string;
  status: LineLinkageStatus;
  scope: 'customer' | 'location' | 'user' | 'group';
  safeDisplayName: string;
  lastVerifiedAt?: string;
}

export interface ProcurementPreferenceShellDTO {
  preferredCategories: ProcurementCategory[];
  commonUnits: string[];
  commonQuantities: string[];
  deliveryPreferences: string[];
  substitutionTolerance: 'none' | 'same_category' | 'sales_confirm_required';
  notes: string[];
}
```

Phase 2 notes:

1. LINE linkage is status-only.
2. Do not expose raw LINE IDs if not needed.
3. Do not enable real reassignment or customer merge.

## 5. Product List DTO

Purpose: Powers `/procurement-admin/products`.

```ts
export interface ProcurementProductListDTO {
  mode: 'mock' | 'read_only';
  generatedAt: string;
  traceId: string;
  products: ProcurementProductSummaryDTO[];
}

export interface ProcurementProductSummaryDTO {
  productId: string;
  variantId: string;
  productName: string;
  variantName: string;
  category: ProcurementCategory;
  supplyType: SupplyType;
  status: ArchiveStatus;
  unit: string;
  packSize?: string;
  priceVisibility: 'list_price_exists' | 'customer_rule_exists' | 'review_required' | 'not_available';
  supplierReviewStatus: 'none' | 'required' | 'stale_quote' | 'ready';
  tags: string[];
  updatedAt: string;
}
```

Phase 2 notes:

1. Product status may be mock.
2. Supplier review status is read-only.
3. Do not trigger catalog sync or supplier availability fetch.

## 6. Quote Request List DTO

Purpose: Powers `/procurement-admin/quote-requests`.

```ts
export interface ProcurementQuoteRequestListDTO {
  mode: 'mock' | 'read_only';
  generatedAt: string;
  traceId: string;
  quoteRequests: ProcurementQuoteRequestSummaryDTO[];
}

export interface ProcurementQuoteRequestSummaryDTO {
  quoteRequestId: string;
  requestCode: string;
  customerId: string;
  customerName: string;
  sourceChannel: ProcurementSourceChannel;
  requestedItems: RequestedItemShellDTO[];
  assignedSalesRep?: {
    salesRepId: string;
    displayName: string;
  };
  status: 'new' | 'triage' | 'needs_clarification' | 'draft_created' | 'closed' | 'archived';
  riskFlags: ReviewRisk[];
  receivedAt: string;
  updatedAt: string;
}

export interface RequestedItemShellDTO {
  text: string;
  candidateVariantId?: string;
  candidateProductName?: string;
  quantity?: number;
  unit?: string;
  confidence?: 'low' | 'medium' | 'high';
}
```

Phase 2 notes:

1. `sourceChannel: 'line'` may appear as mock data only.
2. Do not connect live LINE.
3. Do not run live AI product search.

## 7. Quote Draft List DTO

Purpose: Powers `/procurement-admin/quote-drafts`.

```ts
export interface ProcurementQuoteDraftListDTO {
  mode: 'mock' | 'read_only';
  generatedAt: string;
  traceId: string;
  quoteDrafts: ProcurementQuoteDraftSummaryDTO[];
}

export interface ProcurementQuoteDraftSummaryDTO {
  quoteDraftId: string;
  draftCode: string;
  quoteRequestId?: string;
  customerId: string;
  customerName: string;
  createdBy: 'ai_assisted_mock' | 'sales' | 'procurement_user';
  approvalState: 'draft' | 'sales_review_required' | 'pricing_review_required' | 'approved_for_quote' | 'rejected';
  lines: QuoteDraftLineShellDTO[];
  totals: {
    customerVisibleSubtotal?: number;
    customerVisibleCurrency: 'TWD' | 'JPY' | 'USD';
    internalMarginEstimate?: number;
    marginDisplayMode: 'hidden' | 'internal_only' | 'mock_internal_only';
  };
  riskFlags: ReviewRisk[];
  expiresAt?: string;
  updatedAt: string;
}

export interface QuoteDraftLineShellDTO {
  lineId: string;
  variantId?: string;
  productName: string;
  category: ProcurementCategory;
  quantity: number;
  unit: string;
  listPrice?: number;
  customerRulePrice?: number;
  draftUnitPrice?: number;
  marginFlag?: 'none' | 'low_margin' | 'review_required';
  supplierReviewStatus?: 'none' | 'required' | 'stale_quote' | 'ready';
}
```

Phase 2 notes:

1. Price and margin fields are read-only or mock.
2. `approved_for_quote` must not imply an actual customer quote was sent.
3. No automatic price finalization.

## 8. Order Draft List DTO

Purpose: Powers `/procurement-admin/orders` order draft tab.

```ts
export interface ProcurementOrderDraftListDTO {
  mode: 'mock' | 'read_only';
  generatedAt: string;
  traceId: string;
  orderDrafts: ProcurementOrderDraftSummaryDTO[];
}

export interface ProcurementOrderDraftSummaryDTO {
  orderDraftId: string;
  draftCode: string;
  customerId: string;
  customerName: string;
  sourceChannel: ProcurementSourceChannel;
  sourceQuoteId?: string;
  assignedSalesRep?: {
    salesRepId: string;
    displayName: string;
  };
  status: 'draft' | 'sales_review_required' | 'customer_confirmation_pending' | 'confirmed_mock' | 'cancelled' | 'archived';
  fulfillmentStatus: 'not_started' | 'supplier_procurement_required' | 'inventory_review_required' | 'shipment_ready_mock' | 'fulfilled_mock';
  itemCount: number;
  customerVisibleTotal?: number;
  currency: 'TWD' | 'JPY' | 'USD';
  riskFlags: ReviewRisk[];
  updatedAt: string;
}
```

Optional confirmed order summary for mock/read-only display:

```ts
export interface ProcurementConfirmedOrderSummaryDTO {
  orderId: string;
  orderCode: string;
  customerId: string;
  customerName: string;
  sourceChannel: ProcurementSourceChannel;
  salesRepName?: string;
  status: 'confirmed_read_only' | 'cancelled_read_only' | 'fulfilled_read_only';
  fulfillmentStatus: 'not_started' | 'supplier_procurement_required' | 'inventory_review_required' | 'shipment_ready_mock' | 'fulfilled_mock';
  itemCount: number;
  customerVisibleTotal?: number;
  currency: 'TWD' | 'JPY' | 'USD';
  confirmedAt?: string;
}
```

Phase 2 notes:

1. `confirmed_mock` and `confirmed_read_only` are display states only.
2. Do not create real `orders`.
3. Do not allocate, reserve, or deduct inventory.

## 9. Safety Copy Requirements

Every DTO-backed page should be able to render one of these safety labels:

```ts
export type ProcurementDataSafetyMode =
  | 'mock_only'
  | 'safe_read_only'
  | 'requires_backend_contract'
  | 'blocked_high_risk';
```

Recommended UI copy:

| Safety mode | Copy |
| --- | --- |
| `mock_only` | Mock data only. No live commerce action is executed. |
| `safe_read_only` | Read-only view. Changes are disabled in this phase. |
| `requires_backend_contract` | 需後端契約完成 |
| `blocked_high_risk` | High-risk action blocked in Phase 2 |

## 10. Explicit Non-Goals

These DTOs must not be treated as:

1. Production API route definitions.
2. Migration schema.
3. Supabase table schema.
4. Edge Function contract.
5. LINE webhook contract.
6. Pricing automation contract.
7. Inventory allocation contract.

## 11. Acceptance Checklist

Phase 2 read model is acceptable if:

1. Readdy can build UI shells from these DTOs.
2. Mock fixtures can satisfy every listed page.
3. No DTO field requires secrets.
4. No DTO field implies direct write behavior.
5. Confirmed order and fulfillment states are clearly mock/read-only unless later authorized.
