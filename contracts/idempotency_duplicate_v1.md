# Idempotency + Duplicate Contract v1

## Scope

This contract applies to canonical catalog write operations triggered by Import Review.

Covered actions:
- create_brewery
- create_brand
- create_product
- create_variant
- merge_to_existing

---

## RPC: apply_import_merge_action_v1

### Required behavior

The RPC must generate an `idempotency_key`.

Suggested composition:
- source_raw_id
- action_type
- target_table (if any)
- target_id (if any)

Examples:
- create_product => `source_raw_id + action_type`
- merge_to_existing => `source_raw_id + action_type + target_table + target_id`

### Idempotency rule

If the same `idempotency_key` already exists:
- return the existing action result
- do not perform write again
- do not create duplicate merge action rows

### Required response

- action_id
- result_status
- idempotent_replay (boolean)

Suggested result_status values:
- applied
- already_applied
- skipped
- blocked_duplicate
- error

---

## Create Action Rules

Before executing:
- create_brewery
- create_brand
- create_product
- create_variant

the system must run duplicate candidate detection.

### Outcomes

- exact  
  block create, suggest merge
- probable  
  warn reviewer, require human confirmation
- none  
  allow create

---

## Duplicate Candidate Detection

### Brewery
Suggested candidate key:
- normalized_brewery_name
- prefecture
- country_code

### Brand
Suggested candidate key:
- normalized_brand_name
- brewery_id

### Product
Suggested candidate key:
- normalized_product_name
- brand_id
- brewery_id

### Variant
Suggested candidate key:
- product_master_id
- volume_ml
- abv

---

## Exclusion Scope

Duplicate detection does NOT apply to inventory-layer attributes, including:

- batch number (lot)
- expiration date
- storage location
- inventory quantity

These belong to the inventory layer, not the canonical catalog.

---

## Barcode Rule

Barcode is treated as a strong identifier.

If a barcode already exists in the canonical catalog:
- creation of a new variant is not allowed
- merge to existing variant is required

If barcode conflicts with a different candidate result:
- mark as high-risk conflict
- require manual review

---

## UI / Review Implication

Import Review should surface duplicate risk as:

- exact duplicate
- probable duplicate
- no duplicate detected

This status is advisory for reviewers and must not silently auto-create new canonical entities when exact duplicate is detected.
