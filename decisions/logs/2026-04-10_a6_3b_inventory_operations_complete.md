# A6-3b Inventory Operations Complete

## Date
2026-04-10

---

## Summary

A6-3b has been completed and validated in staging.

This phase adds the remaining happy-path inventory operation RPCs:

- `shelf_inventory_v1`
- `unshelf_inventory_v1`
- `unload_machine_inventory_v1`
- `adjust_inventory_v1`

Together with A6-3a, the inventory operation engine v1 is now complete.

---

## Scope

### Previously completed in A6-3a
- `receive_inventory_v1`
- `transfer_inventory_v1`
- `load_machine_inventory_v1`

### Completed in A6-3b
- `shelf_inventory_v1`
- `unshelf_inventory_v1`
- `unload_machine_inventory_v1`
- `adjust_inventory_v1`

---

## Validation Result

### Existence
All four RPCs exist in staging.

### Happy Path Verification
Validated successfully:

- unshelf happy path
- shelf happy path
- unload_machine happy path
- adjust happy path

### Quantity Validation
Post-operation quantity checks passed.

### Summary Validation
Per-case summaries were successfully produced for:

- shelf
- unshelf
- unload_machine
- adjust

---

## Operational Meaning

Inventory operation engine v1 now supports:

- receiving stock
- shelving stock into location-backed positions
- unshelving stock out of location-backed positions
- transferring stock between locations
- loading stock into machine positions
- unloading stock from machine positions back to location-backed positions
- adjusting on-hand quantity on existing positions

---

## Position Model Status

The following position semantics are now active:

- unshelved position
- location-backed position
- machine-backed position

These semantics are documented separately in:

- `decisions/core/inventory_position_state_rules_v1.md`

---

## Alignment Note

This phase still follows temporary staging alignment:

- `org_id -> stores.id`

This remains a staging compatibility choice, not the final org identity model.

---

## Next Step

Recommended next phase:

- A6-4 backoffice inventory UI
  - receipt page
  - batch list
  - stock by location
  - movement history
  - machine replenishment view

Alternative path:
- A6-4a reporting / alerts
- A6-4b permission / role refinement for inventory operations
