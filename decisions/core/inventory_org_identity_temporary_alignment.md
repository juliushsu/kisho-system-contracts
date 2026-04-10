# Inventory Org Identity Temporary Alignment

## Status
Temporary alignment for staging compatibility.

## Decision

In A6-1, inventory-layer tables temporarily use:

- `org_id -> stores.id`

This is a staging-first compatibility choice, not the final semantic model.

## Why

Current staging-compatible chains are centered on:
- `stores`
- `locations`
- legacy inventory-related tables
- existing smoke-testable paths

Using `stores.id` allows the following chain to be introduced with minimal disruption:

`receipt -> line -> batch -> position -> movement`

## What This Does NOT Mean

This does NOT mean:
- `store = org`
- `stores.id` is the final canonical organization identity

## Expected Final Model

Long-term semantic direction should be:

- `merchant_orgs.org_id` = organization identity
- `stores.id` = branch / site / store identity

Inventory tables should eventually align as:

- `org_id -> merchant_orgs.org_id`
- `branch_id / store_id -> stores.id`

## Consequence

A6-1 can proceed without over-engineering or breaking staging compatibility.

A later migration will be required to normalize org identity at the inventory layer.

## Follow-up

Planned future work:
- A6-1.1 org identity correction proposal
- compatibility migration from `stores.id` to `merchant_orgs.org_id`
- explicit branch/store modeling

# Inventory Org Identity Temporary Alignment

## Status
Temporary alignment for staging compatibility (A6-1).

---

## Decision

In A6-1 (Inventory Batch Layer Foundation), all inventory tables use:

- `org_id -> stores.id`

This is a **staging-first compatibility decision**, not the final domain model.

---

## Context

Current staging environment has the following characteristics:

- Existing inventory-related tables are scoped around `stores`
- `locations`, `devices`, and legacy inventory flows are linked to `stores`
- Debug / admin tooling resolves org context via `stores.id`
- Smoke-testable data paths are built on top of `stores`

To achieve a **minimal working inventory chain**:
supplier → receipt → receipt_line → batch → position → movement
Using `stores.id` as `org_id` allows:

- Direct FK compatibility with existing tables
- No need for additional mapping layer
- Immediate staging verification (verify + smoke)

---

## What This Does NOT Mean

This decision does NOT imply:

- `store = organization`
- `stores.id` is the canonical org identity
- inventory model is finalized

---

## Intended Final Model

The long-term architecture should distinguish:

### Organization Layer
- `merchant_orgs.org_id`
- Represents the business entity (酒商 / 代理商)

### Store / Branch Layer
- `stores.id`
- Represents physical locations / outlets / sites

---

## Expected Future Alignment

Inventory tables should eventually follow:

- `org_id -> merchant_orgs.org_id`
- `branch_id / store_id -> stores.id`
- `location_id` for warehouse / storage
- `machine_id` for device-level placement

---

## Consequences

### Positive
- Enables A6-1 to be delivered without breaking staging
- Allows immediate validation of inventory chain
- Keeps migration scope minimal

### Trade-offs
- Semantic mismatch between `org_id` and true org identity
- Requires future migration to normalize identity

---

## Migration Plan (Future Work)

Planned in A6-1.1 or A6-2+:

1. Introduce explicit mapping:
   - `stores.org_id -> merchant_orgs.org_id`

2. Add new column:
   - `inventory_*`.`org_id` → reference `merchant_orgs.org_id`

3. Backfill:
   - Map existing `stores.id` to corresponding `merchant_orgs.org_id`

4. Deprecate:
   - Remove `org_id -> stores.id` FK

5. Validate:
   - Ensure no cross-org leakage
   - Ensure all queries use new org identity

---

## Decision Summary

| Item | Status |
|------|--------|
| A6-1 org_id → stores.id | Temporary |
| Final org identity | merchant_orgs.org_id |
| Requires migration | Yes |

---

## Next Step

Proceed to:
- A6-2: Movement semantics + query model
- Then A6-1.1: org identity normalization


