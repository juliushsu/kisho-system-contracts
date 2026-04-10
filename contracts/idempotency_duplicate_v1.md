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
