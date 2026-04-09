# Product Flow Contract v1

## PURPOSE

Define canonical relationship:

catalog → merchant_product → machine_assignment → machine

---

## FLOW STRUCTURE

1. catalog_products
   ↓
2. merchant_products
   ↓
3. machine_assignments
   ↓
4. machines

---

## DEFINITIONS

### catalog_products
- global shared products
- no org ownership

### merchant_products
- org-scoped
- pricing / SKU defined here

### machine_assignments
- mapping between machine and merchant_product
- slot / channel defined here

### machines
- physical device
- must not contain product logic

---

## RULES

1. NO DIRECT MACHINE → CATALOG LINK
machine MUST NOT reference catalog directly

2. ALL ASSIGNMENTS VIA merchant_product

3. ONLY ONE ACTIVE ASSIGNMENT PER SLOT

4. INACTIVE PRODUCT MUST NOT BE ASSIGNED

---

## INTEGRITY CHECKS

- orphan_merchant_products
- orphan_assignments
- machines_without_location
- assignments_without_product
- cross_org_leaks
- inactive_products_assigned
- duplicate_active_assignments

---

## FRONTEND RULES

- MUST NOT compute flow
- MUST use product-flow API
- MUST render warnings[] only

---

## FORBIDDEN

- Direct DB join on frontend
- Reconstructing relationships manually
- Ignoring integrity warnings

---

## VERSION

v1.0 (2026-04-09)
