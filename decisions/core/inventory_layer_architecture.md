# Inventory Layer Architecture Decision

## Decision

Inventory is separated into:
- receipt
- batch
- position
- movement

## Rationale

- Avoid mixing transaction and state
- Support machine integration
- Support multi-tenant isolation

## Consequence

- More tables but clearer logic
- Enables future IoT integration
