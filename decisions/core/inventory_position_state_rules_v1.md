1. unshelved 的定義
	•	location_id is null
	•	machine_id is null

2. location-backed 的定義
	•	location_id is not null

3. machine-backed 的定義
	•	machine_id is not null
# Inventory Position State Rules v1

## Status
Active from A6-3b.

---

## Purpose

This decision defines the semantic meaning of inventory position states used by the inventory operation engine.

The goal is to ensure inventory operations do not ambiguously mix:

- unshelved stock
- location-backed stock
- machine-backed stock

---

## Position Types

### 1. Unshelved Position
A position is considered **unshelved** when:

- `location_id is null`
- `machine_id is null`

### Meaning
Stock exists in inventory scope, but is not currently placed in a physical location or machine.

### Typical operations
- created after unshelf
- source for shelf
- temporary holding state

---

### 2. Location-backed Position
A position is considered **location-backed** when:

- `location_id is not null`

### Meaning
Stock is physically assigned to a warehouse / shelf / branch location.

### Typical operations
- receive to location
- shelf into location
- transfer between locations
- load_machine source
- unshelf source
- unload_machine target

---

### 3. Machine-backed Position
A position is considered **machine-backed** when:

- `machine_id is not null`

### Meaning
Stock is physically assigned to a dispensing machine inventory position.

### Typical operations
- load_machine target
- unload_machine source
- dispense source

---

## Precedence Rules

When interpreting a position:

1. If `machine_id is not null`, treat as machine-backed
2. Else if `location_id is not null`, treat as location-backed
3. Else treat as unshelved

This rule avoids ambiguity when reading or aggregating positions.

---

## Operation Mapping

### Shelf
- source: unshelved position
- target: location-backed position

### Unshelf
- source: location-backed position
- target: unshelved position

### Load Machine
- source: location-backed position
- target: machine-backed position

### Unload Machine
- source: machine-backed position
- target: location-backed position

### Adjust
- applies only to an existing position
- in v1 only adjusts `on_hand_qty`

---

## Exclusions

This decision does NOT define:

- costing
- accounting meaning
- invoice meaning
- catalog identity

These remain outside the position state model.

---

## Related Decisions

- `decisions/core/inventory_org_identity_temporary_alignment.md`
- `decisions/logs/2026-04-10_a6_1_inventory_foundation_complete.md`
- `decisions/logs/2026-04-10_a6_2_inventory_query_layer_complete.md`
- `decisions/logs/2026-04-10_a6_3b_inventory_operations_complete.md`
