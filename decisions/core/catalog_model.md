# Catalog Model

## Decision

Canonical catalog is shared across all organizations.

Organizations do not own products.
They reference products and manage:

- availability
- visibility
- inventory

## Implication

- No duplication of product data
- Multiple organizations can sell the same product
- Inventory is scoped by (org_id, variant_id)

## Non-goals

- Organization-specific product copies
