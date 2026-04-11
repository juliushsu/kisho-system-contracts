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
# Inventory Org Identity – Temporary Alignment (A6-1)

## Status
Accepted (Staging-first)

## Context

During A6-1 (Inventory Batch Layer Foundation), the system required a minimal, staging-compatible way to establish a working inventory chain:

- inventory_receipts
- inventory_receipt_lines
- inventory_batches
- inventory_positions
- inventory_movements

However, the existing staging schema and data model are not fully aligned with the intended canonical organization model (`merchant_orgs.org_id`).

Instead, the currently functional and connected scope is based on:

- `stores.id`
- `locations`
- existing inventory-related tables
- admin/debug org resolution logic

To ensure:
- minimal disruption
- compatibility with existing staging data
- successful end-to-end smoke tests

a temporary alignment strategy was introduced.

---

## Decision

In A6-1 and A6-2:

> `inventory.*.org_id` is temporarily aligned to `public.stores.id`

This means:

- `org_id` in inventory tables **does NOT represent the final canonical organization identity**
- It is a **staging compatibility key**, not a semantic org boundary

---

## Scope of Temporary Alignment

Applies to:

- `inventory_receipts.org_id`
- `inventory_receipt_lines.org_id`
- `inventory_batches.org_id`
- `inventory_positions.org_id`
- `inventory_movements.org_id`

All of the above currently reference:

public.stores(id)

---

## Intended Final Model (Target State)

The intended long-term identity model is:

- `merchant_orgs.org_id` → canonical organization identity
- `stores.id` → branch / store / site level
- `locations.id` → physical storage / warehouse / area
- `devices.id` → machine / endpoint

Target relationships:

inventory_receipts.org_id → merchant_orgs.org_id
inventory_receipts.branch_id → stores.id
inventory_positions.location_id → locations.id
inventory_positions.machine_id → devices.id

---

## Why This Was Not Applied in A6-1

Applying the final model immediately would have caused:

- incompatibility with existing staging tables
- broken joins with legacy inventory structures
- inability to complete smoke verification flows
- need for additional mapping layers (org ↔ store ↔ location)

This would violate the A6-1 principle:

> "staging-first, minimal viable chain, no over-engineering"

---

## Risks

If this temporary alignment is misunderstood as final:

- org-level isolation may be incorrect
- multi-tenant boundary may be violated
- future migrations will become significantly harder
- data integrity across merchants may be compromised

---

## Migration Strategy (Future Work)

Planned in future phase (post A6-3):

1. Introduce canonical `merchant_orgs.org_id` into inventory tables
2. Add dual-key support:
   - `org_id` (canonical)
   - `store_id` (branch)
3. Backfill mapping:
   - `stores.id → merchant_orgs.org_id`
4. Gradually update:
   - RPC functions
   - views
   - RLS policies
5. Deprecate direct reliance on `stores.id` as org identity

---

## Non-Goals (Current Phase)

- No change to production
- No refactor of legacy tables
- No RLS redefinition
- No accounting / financial integration
- No telemetry coupling

---

## Summary

This decision explicitly defines:

> The current `org_id → stores.id` mapping is a **temporary alignment for staging compatibility only**, not the final system design.

All future development must treat this as a transitional state and not a permanent contract.

