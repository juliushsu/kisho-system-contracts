# Inventory Model Contract v1

## Scope
Org-scoped inventory system.

## Layers

1. Receipt
2. Receipt Line
3. Batch
4. Position
5. Movement

## Rules

- Inventory is org-scoped
- Canonical catalog is global
- Inventory must not modify catalog identity

## Identity Separation

Catalog:
- brewery
- brand
- product_master
- product_variant

Inventory:
- batch_no
- expiration_date
- location
- quantity

## Core Flow

receipt → receipt_lines → batches → positions → movements

## Movement Semantics

- inbound
- shelf
- transfer
- load_machine
- dispense
- adjust
