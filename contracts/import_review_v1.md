# Import Review Contract v1

## PURPOSE

Normalize external data into canonical structure:

brewery → brand → product → variant

---

## SUBJECT TYPES

- brewery
- brand
- product
- variant

Each import item MUST map to one subject type.

---

## ACTION TYPES (FINAL)

- create_brewery
- create_brand
- create_catalog_product

- merge_existing_brewery
- merge_existing_brand
- merge_existing_product

- skip_noise

---

## CORE RULES

1. NO AUTO WRITE
All actions must go through review.

2. NO CROSS-SUBJECT MERGE
- brewery cannot merge into brand
- brand cannot merge into product

3. NO DATA LOSS
- original payload must remain stored
- normalization must be reversible

4. NO CROSS-ORG LEAK
- org-scoped data must not mix

---

## DATA FLOW

external_import_items
  → normalize
  → staged_products / staged_variants
  → import_review_queue
  → apply_live_import_review_action_v1
  → canonical tables

---

## CANONICAL TARGETS

- breweries
- brands
- product_master
- product_variants

---

## FIELD RULES

### brewery / brand (IMPORTANT)

MUST store:

- name
- region / prefecture
- address
- phone
- website_url
- contact_name
- contact_email
- source_url
- source_type

MUST NOT store these in product_master.metadata

---

## UI REQUIREMENTS (FRONTEND)

Each review item MUST display:

- subject type
- normalized name
- raw name
- source_url
- suggested action
- candidate target (if merge)

---

## FORBIDDEN

- Auto-create without review
- Writing contact data into product metadata
- Inferring missing fields silently
- Renaming action types

---

## VERSION

v1.0 (2026-04-09)
