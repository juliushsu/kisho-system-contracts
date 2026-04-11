# Shipment Scope v1

## Status
Accepted (staging-first planning)

## Goal

Introduce a dedicated outbound management layer between Order and Inventory.

## In Scope

### Entities
- shipment_headers
- shipment_lines
- shipment_allocations
- shipment_events (optional but recommended)

### Core Capabilities
- create shipment draft
- link shipment to order optionally
- define shipment lines
- allocate stock by batch / position
- confirm shipment and write inventory execution records
- track shipment status

## Shipment Status
- draft
- allocated
- ready_to_ship
- shipped
- delivered
- cancelled

## Shipment Method
- sales_direct
- courier
- pickup

## Out of Scope (v1)
- invoice generation
- courier tracking integration
- signature capture
- PDF generation
- customer-facing delivery portal
- accounting integration

## Alignment Note

Shipment will belong to outbound / logistics domain.

It is related to both:
- yellow business layer (orders / customer / sales)
- green inventory layer (batch / position / movement)

But should be implemented as a separate module, not collapsed into either side.
