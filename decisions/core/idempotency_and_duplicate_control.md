# Idempotency and Duplicate Control

## Decision

Catalog write operations must be both idempotent and duplicate-aware.

---

## Idempotency

The same action must not be applied more than once.

Execution identity is determined by:

- source_raw_id
- action_type
- target_table (if any)
- target_id (if any)

An idempotency key must be generated and enforced at the database level.

If the same idempotency key is submitted again:
- return the existing result
- do not write again
- do not create duplicate merge action rows

---

## Duplicate Control

Before any create action, the system must check for existing canonical candidates.

Covered subjects:
- brewery
- brand
- product_master
- product_variant

---

## Matching Strategy

The system uses three outcomes:

- exact
- probable
- none

### exact
Block direct create and redirect reviewer to merge.

### probable
Warn reviewer and require explicit human confirmation.

### none
Allow create.

---

## Exclusion Scope

Duplicate detection does NOT apply to inventory-layer attributes, including:

- batch number
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

If barcode conflicts with another candidate:
- mark as high-risk conflict
- require manual review

---

## Summary

Idempotency prevents duplicate execution.
Duplicate control prevents duplicate canonical entities.
