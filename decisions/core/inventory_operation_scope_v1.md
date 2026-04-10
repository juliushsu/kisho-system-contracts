# Inventory Operation Scope v1

## Status
A6-3a minimal operation scope.

## Decision

The first inventory operation layer only includes:

- receive_inventory_v1
- transfer_inventory_v1
- load_machine_inventory_v1

This is a happy-path-first scope.

## Why

These three operations are sufficient to validate:

- external receipt into inventory
- intra-location stock transfer
- loading stock from location into machine inventory

They establish the minimum operational backbone without introducing excessive complexity.

## Deferred Operations

The following are explicitly deferred to later phases:

- shelf_inventory_v1
- unshelf_inventory_v1
- unload_machine_inventory_v1
- adjust_inventory_v1
- reject-heavy receive flow
- exceptional / error path validation

## Happy Path Constraints

### receive_inventory_v1
- received_qty > 0
- rejected_qty = 0

### transfer_inventory_v1
- only location -> location
- source_location_id required
- target_location_id required

### load_machine_inventory_v1
- only location -> machine
- no reverse flow in this phase

## Alignment Note

This phase still follows temporary alignment:

- `org_id` currently aligns to `stores.id`

This is for staging compatibility only.

## Next Step

After A6-3a is validated, later phases may add:

- unload / shelf family
- adjust
- exceptional validations
- full inventory operation UI
