# Inventory Demo Story Seed Complete

## Date
2026-04-11

## Summary

The minimal inventory demo story seed has been successfully created and verified in staging.

This seed is intended for:
- A6-4 / A6-4c UI validation
- product walkthrough
- demo-friendly inventory scenarios
- query / movement / position-state visibility

## Scope

The seed creates a minimal but narrative inventory story for the demo org.

### Story coverage
- 2 receipts
- 2 batches
- 2 variants
- 8 movements

### Movement types present
- receive_accept
- shelf
- unshelf
- load_machine
- dispense
- adjust

### Position states present
- location-backed
- machine-backed
- unshelved

## Verified UI impact

The seed guarantees non-empty data for:

- `/admin/inventory`
- `/admin/inventory/receipts`
- `/admin/inventory/batches`
- `/admin/inventory/movements`

Dashboard-related checks verified:
- sellable variants > 0
- near-expiry batches > 0
- unshelved batches > 0
- machine stock > 0
- recent movements > 0

## Notes

This is a staging-only demo story seed.
It is not production seed data.

The seed uses cleanup-first strategy and fixed demo prefixes:
- `DEMO-RCPT-001`
- `DEMO-RCPT-002`
- `DEMO-A1`
- `DEMO-B1`

## Follow-up

Recommended next steps:
- visually re-review A6-4 / A6-4c pages with live demo data
- normalize DEMO-A1 / DEMO-B1 naming consistency
- optionally extend to v2 demo story with:
  - transfer
  - unload_machine
