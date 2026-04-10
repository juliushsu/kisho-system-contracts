# Catalog Code Governance

## Decision

Canonical catalog entities must use a human-readable code scheme in addition to UUIDs.

UUID remains the true system key.
Human-readable codes are governance-layer identifiers for interoperability and recognition.

---

## Why This Exists

The system must support:
- human review
- ERP / inventory integration
- reporting
- cross-org shared catalog usage
- stable operational references

Relying only on free-text names is insufficient.
Relying only on UUIDs is not human-friendly.

---

## Governance Principles

1. UUID is authoritative for relations
2. Code is authoritative for business readability
3. Code generation must be rule-based, not ad hoc
4. Codes must be stable and avoid temporary operational states
5. Batch / inventory attributes must never redefine canonical identity

---

## Boundaries

### Catalog Layer
Owns:
- brewery_code
- brand_code
- product_master_code
- variant_code

### Inventory Layer
Owns:
- batch_no
- expiration_date
- storage location
- quantity

Inventory data must not mutate canonical codes.

---

## Mutation Rules

### Allowed
- generate new code when creating a new canonical entity
- regenerate proposal during review before final approval

### Restricted
- changing an already-issued canonical code requires explicit governance approval
- code mutation must not silently cascade across organizations

---

## Review Implications

Import Review may propose:
- new brewery code
- new brand code
- new product code
- new variant code

But final canonical code issuance is a controlled action, not an arbitrary free-text field.

---

## Future Extensions

- reserved code registry
- code conflict checker
- barcode-to-variant governance rules
- manual override workflow for historical exceptions

---

## Summary

Canonical code is a governed business identifier.
It is not the system primary key, and it must remain separate from inventory-state data.
