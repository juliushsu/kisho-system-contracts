# Idempotency + Duplicate Contract v1

## RPC: apply_import_merge_action_v1

### Required behavior
- Generate idempotency_key
- If key already exists:
  - return existing result
  - do not write again

### Response
- action_id
- result_status
- idempotent_replay (boolean)

---

## Create Action Rules

Before:
- create_brewery
- create_brand
- create_product
- create_variant

The system must run duplicate candidate detection.

### Outcomes
- exact: block create, suggest merge
- probable: warn reviewer
- none: allow create
- 
## Exclusion Scope

Duplicate detection does NOT apply to inventory-level attributes, including:

- batch number (lot)
- expiration date
- storage location
- inventory quantity

These belong to the inventory layer, not the canonical catalog.


## Barcode Rule

Barcode is treated as a strong identifier.

If a barcode already exists in the canonical catalog:
- creation of a new variant is not allowed
- merge to existing variant is required
