# Organization vs Catalog Boundary

## Decision

The system separates "data ownership" from "data usage".

Canonical catalog owns product data.  
Organizations only reference and operate on that data.

---

## Boundary Definition

### Canonical Owns:

- product identity
- brand identity
- structural relationships
- normalization

---

### Organization Owns:

- whether a product is listed
- whether it is available for sale
- inventory levels
- (future) pricing and channel strategy

---

## Key Rule

Organizations cannot mutate canonical data directly.

All mutations must go through:

Import Review → Merge Action → Canonical Update

---

## Example

A product exists in the catalog:

product_variant_id = X

Organization A:
- lists it
- has 10 units in inventory

Organization B:
- does not list it

Both refer to the same canonical entity.

---

## Implications

- consistent product identity across the system
- no duplication across organizations
- easier analytics and aggregation
- supports marketplace and multi-tenant scenarios

---

## Future Extensions

- permission model (who can write to catalog)
- public vs private catalog segments
- cross-org sharing controls

---

## Summary

Canonical defines reality.  
Organizations define participation.
