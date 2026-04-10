# Catalog Model

## Decision

The canonical catalog is shared across all organizations.

Organizations do not own products.  
They reference products and manage their availability, visibility, and inventory.

---

## Structure

### Canonical Layer (Global)

- brands
- breweries
- product_master
- product_variants

This layer is the single source of truth.

---

### Organization Layer

- merchant_products
- listings / availability
- pricing (future)
- visibility (public / private)

Organizations decide:
- whether to sell a product
- whether to expose it to others

---

### Inventory Layer

Inventory is scoped by:

(org_id, variant_id)

Each organization tracks its own stock independently.

---

## Implications

- No duplication of product data across organizations
- Multiple organizations can sell the same product
- Product identity is globally consistent
- Inventory and pricing remain organization-specific

---

## Non-goals

- Organization-specific copies of products
- Independent product catalogs per organization

---

## Summary

Canonical catalog defines "what exists".  
Organizations define "what they sell".
