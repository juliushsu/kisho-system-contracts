Merchant Orders Domain Boundary v1

Status

Accepted

⸻

Purpose

This document defines the canonical boundary for the merchant customer order domain.

Its purpose is to ensure that:
	•	merchant customer orders are treated as a distinct domain
	•	procurement orders remain a separate domain
	•	order item variant identity is canonicalized
	•	read models and UI do not regress to legacy catalog paths

⸻

Core Principle

Merchant customer orders and procurement orders are different domains.

Merchant orders represent:
	•	customer-facing merchant sales orders

Purchase orders represent:
	•	supplier-facing procurement orders

These must not be merged semantically or technically.

⸻

Domain Separation

Merchant Order Domain

Canonical base:
	•	merchant_orders
	•	merchant_order_items

Procurement Domain

Separate base:
	•	purchase_orders
	•	purchase_order_items

Rule

Merchant UI, merchant services, and merchant read contracts must not use procurement tables as substitute sources for customer order features.

⸻

Canonical Header / Line Definition

Merchant Order Header

merchant_orders is the canonical merchant order header base.

Merchant Order Line

merchant_order_items is the canonical merchant order line base.

⸻

Variant Identity Rule

merchant_order_items.variant_id is canonically defined as:

product_variant_id
``` id="merchant-orders-variant-identity"

The legacy column name `variant_id` may remain for backward compatibility, but its domain meaning is fixed to canonical product variant identity.

### Implication
Frontend DTO and new service logic should progressively normalize to:
- `product_variant_id`

---

## Allowed Mapping Sources

Merchant order line product mapping may use:

- `product_variants`
- `product_master`
- `merchant_products`

These are the only approved paths for canonical item/product mapping.

---

## Forbidden Legacy Paths

The following are forbidden for new merchant orders UI or service logic:

- `v_variant_catalog`
- `v_variant_catalog_bridge_v1`
- `merchant_org_variants`
- `core_variants`
- direct `sake_products` reads
- ad hoc debug / bridge adapters as formal order data source

---

## Read Contract Principle

Orders page and service layer must eventually converge to canonical contracts such as:

- `merchant_orders_v1(...)`
- `merchant_order_detail_v1(...)`

Pages must not directly depend on raw tables once canonical contracts are available.

---

## Backward Compatibility Rule

Backward compatibility may preserve:
- table names
- legacy column name `variant_id`

But backward compatibility must not justify:
- legacy semantic ambiguity
- bridge-based UI sourcing
- mixed-generation DTO design

---

## Scope Rule

Merchant order read contracts must be scoped by merchant identity.

Allowed scope input:
- `merchant_id`

Backend may internally normalize:
- `merchant_id`
- `store_id`
- `org_id`
- `business_entity_id`

But UI should treat merchant scope as a single clear entry contract.

---

## Write Boundary

This document defines domain identity and read boundary only.

It does not approve:
- order creation write path
- order status mutation write path
- payment / settlement / write-off logic

Those must be governed separately.

---

## Anti-Patterns

Forbidden patterns include:

- treating `purchase_orders` as merchant customer orders
- treating `variant_id` as ambiguous identity
- using legacy catalog bridge views for order line display
- allowing UI to guess item identity from mixed source tables
- allowing merchant order pages to regress into old catalog adapters

---

## Summary

Merchant orders are their own canonical domain.

The system enforces:

- `merchant_orders` = customer order header
- `merchant_order_items` = customer order line
- `variant_id` semantic = `product_variant_id`
- procurement remains separate
- legacy catalog paths are forbidden for new UI
:::
