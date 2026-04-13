# Merchant Orders Page Convergence Policy v1

## Status
Accepted

---

## Purpose

This document defines the convergence policy for merchant orders pages.

Its purpose is to ensure that orders list/detail UI:

- converges to canonical read contracts
- does not directly read tables or legacy views
- does not mix old catalog adapters with new merchant order contracts
- preserves UI structure while replacing data source safely

---

## Core Principle

> Orders page should keep its UI structure,  
> but replace its data source with canonical contracts.

---

## Canonical Read Contracts

### Orders List
Must converge to:
- `merchant_orders_v1(p_merchant_id, p_limit)`

### Orders Detail
Must converge to:
- `merchant_order_detail_v1(p_merchant_id, p_order_id)`

These are the only approved primary read contracts for merchant orders pages once available.

---

## Page Rules

### List Page
The orders list page must:
- read from `merchant_orders_v1`
- use service-layer access only
- avoid direct table reads
- avoid page-level joins

### Detail Page
The orders detail page must:
- read from `merchant_order_detail_v1`
- consume item payload from canonical detail contract
- not separately query legacy variant/catalog sources

---

## Service Layer Rule

Orders page must use a dedicated service layer such as:
- `ordersService.ts`

Page components must not directly query:
- `merchant_orders`
- `merchant_order_items`
- legacy catalog views
- legacy merchant variant tables

---

## Item DTO Rule

Canonical item identity must be:
- `product_variant_id`

If temporary backward compatibility requires `variantId` in frontend code, it may be adapter-mapped from:
- `productVariantId`

But new UI logic and DTO definitions should progressively converge to `productVariantId`.

---

## Forbidden Paths

The following are forbidden for orders page UI/service:

- `v_variant_catalog`
- `v_variant_catalog_bridge_v1`
- `merchant_org_variants`
- page-level direct reads from `merchant_orders`
- page-level direct reads from `merchant_order_items`
- client-side joins for product naming using legacy sources
- debug / ad hoc read endpoints as formal page source

---

## Read-Only Convergence First

The orders page convergence should happen in this order:

### Phase 1
Read convergence only:
- list query
- detail query
- product dropdown query
- client dropdown reuse where possible

### Phase 2
Write path convergence:
- create order RPC
- update order status RPC

### Rule
Do not redesign UI before read convergence is completed.

---

## Preserve UI Structure

The following UI elements may remain unchanged while data source is replaced:

- list table / list cards
- detail header layout
- item table columns
- status badge components
- date/currency formatting
- loading/empty/error states
- modal structure

The preferred strategy is:
- replace service/data source
- preserve UI surface

---

## Write Path Restriction

Until canonical write RPC is available:

- direct insert/update from UI must be treated as transitional only
- such paths must be explicitly marked as forbidden pattern
- new write logic must not be added on direct table mutation

---

## Scope Rule

Orders page must use a single merchant-scoped entry contract.

UI scope input:
- `merchant_id` or resolved org-to-merchant value

Page must not scatter scope resolution logic across components and modals.

---

## Transitional Rule

If a transitional path still exists:

- it must be isolated in service layer
- clearly marked as transitional
- have a declared retirement plan
- not be treated as canonical truth

---

## Anti-Patterns

Forbidden patterns include:

- page.tsx querying multiple order tables directly
- detail modal calling old catalog views for item names
- create modal querying `merchant_org_variants`
- UI mixing canonical list contract with legacy item detail path
- patching old read paths instead of converging to formal RPC

---

## Summary

Merchant orders pages must converge through service-layer replacement, not page-level improvisation.

The system should:
- keep UI structure stable
- replace data source with canonical contracts
- forbid legacy catalog adapters
- postpone write convergence until formal RPC exists
:::
