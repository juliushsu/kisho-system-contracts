# Inventory Backoffice Scope v1 (A6-4)

## Status
Accepted (Staging-first UI scope)

---

## Context

Following:

- A6-1: Inventory Batch Layer Foundation
- A6-2: Inventory Query Layer
- A6-3a / A6-3b: Inventory Operation RPCs

The system now has a complete backend foundation for inventory:

- canonical catalog (product_variants)
- inventory layer (batch / position / movement)
- query layer (views)
- operation layer (RPCs)

The next step (A6-4) is to introduce a **backoffice UI layer** for merchant organizations.

However, without strict scope control, UI development may:
- introduce new schema assumptions
- bypass RPC layer
- mix catalog / inventory / accounting concerns
- expand into unrelated modules (supplier CRUD, finance, frontend sales)

This decision explicitly constrains the initial UI scope.

---

## Decision

A6-4 defines a **minimal, read-oriented inventory backoffice UI v1**, limited to:

> "Inventory visibility and traceability, not full operational system"

---

## Scope (Allowed Pages)

The following 4 pages are **in-scope**:

### 1. Inventory Dashboard

Route:

/admin/inventory

Purpose:
- High-level inventory overview

Data sources:
- `v_inventory_stock_by_variant_v1`
- `v_inventory_stock_by_location_v1`
- `v_inventory_movement_history_by_batch_v1`
- `v_inventory_movement_history_by_machine_v1`

Key UI elements:
- total variants in stock
- total batches
- stock by location summary
- machine stock summary
- near-expiry summary
- recent movement events

---

### 2. Inventory Receipts

Routes:

/admin/inventory/receipts
/admin/inventory/receipts/:id

Purpose:
- View inbound inventory history

Displays:
- receipt list
- receipt header
- receipt lines
- related batches

Constraints:
- read-only
- no create/edit UI in v1

---

### 3. Inventory Batches

Route:

/admin/inventory/batches

Purpose:
- Track batch-level inventory

Displays:
- batch_no
- product_variant
- expiration_date
- accepted_qty
- status
- current stock summary
- position type (unshelved / location / machine)

Filters:
- batch_no
- variant
- status
- near expiry

---

### 4. Inventory Movements

Route:

/admin/inventory/movements

Purpose:
- Full traceability of inventory changes

Displays:
- event_time
- movement_type
- batch_id / batch_no
- variant
- quantity
- source location / machine
- target location / machine
- operator
- reference_type / reference_id

Must support:
- receive_accept
- transfer
- load_machine
- unload_machine
- shelf
- unshelf
- adjust
- dispense

---

## Explicit Non-Scope (v1)

The following are **strictly excluded** in A6-4:

### Data / Backend
- No new database schema
- No modification of existing tables
- No new RPCs

### UI Features
- No create / edit forms
- No supplier CRUD UI
- No accounting / finance UI
- No pricing / cost UI
- No front-facing store / ecommerce pages
- No LINE / BOT integration
- No telemetry / real-time machine dashboard

### System Design
- No redefinition of org identity
- No override of:
  - `inventory_position_state_rules_v1`
  - `inventory_org_identity_temporary_alignment`

---

## Data Model Constraints (Critical)

UI must strictly follow:

### Org Identity

org_id → public.stores.id   (temporary alignment)

NOT:

merchant_orgs.org_id

---

### Inventory Position Semantics

- unshelved:
  - `location_id IS NULL`
  - `machine_id IS NULL`

- location-backed:
  - `location_id IS NOT NULL`

- machine-backed:
  - `machine_id IS NOT NULL`

Precedence:

machine > location > unshelved

---

### Inventory Boundary

Inventory layer:
- references `product_variants` only

Must NOT:
- directly depend on `product_master`
- mix with catalog editing logic

---

## UI Design Principles

- read-first, not action-first
- emphasize traceability over manipulation
- clearly distinguish:
  - location stock
  - machine stock
  - unshelved stock
- near-expiry must only consider:
  - available stock
  - on_hand_qty > 0

- movement_type must be human-readable
  (no raw keys shown)

---

## Relationship to Import Review

Inventory UI must NOT:
- display duplicate_status
- handle exact/probable/barcode_conflict logic

Those belong to:

Import Review (A5)

---

## Future Extensions (Not in v1)

Planned for later phases:

- inventory operation UI (receive / transfer / adjust)
- supplier management
- cost / accounting integration
- machine telemetry dashboard
- real-time stock sync

---

## Summary

A6-4 defines a strictly limited UI scope:

> "A read-only inventory backoffice layer built on top of A6-1 to A6-3, without expanding system boundaries."

This ensures:
- stability
- contract compliance
- safe progression toward operational UI in later phases
