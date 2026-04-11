# Shipment / Order / Inventory Boundary v1

## Status
Accepted

## Core Decision

Order, Shipment, and Inventory are separate domains and must not be collapsed into one object.

- Order = commercial intent / customer commitment
- Shipment = physical outbound execution
- Inventory = source of truth for stock state

## Relationships

Order may produce one or more Shipments.

Shipment may consume one or more inventory batches / positions.

Inventory movements are execution records derived from shipment confirmation, not the shipment object itself.

## Rules

1. Order must not directly mutate inventory tables.
2. Shipment must not be modeled as a simple field inside Order.
3. Shipment lines define what should go out.
4. Shipment allocations define from which batch / position stock is actually consumed.
5. Inventory remains the stock source of truth.

## Why

This separation is necessary because:

- one order may ship in multiple batches
- one shipment may only partially fulfill an order
- shipped stock and delivered stock are different states
- inventory traceability requires batch-level allocation

## Non-Goals

This decision does not yet define:
- invoicing
- courier API integration
- signature UI
- delivery document PDF generation
