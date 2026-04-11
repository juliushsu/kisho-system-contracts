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
Shipment Scope v1

Status

Accepted (staging-first planning)

⸻

Context

The system currently has:
	•	product / variant catalog
	•	inventory foundation
	•	inventory query layer
	•	inventory operation RPCs
	•	inbound / receipt capability

However, there is no formal outbound shipment layer.

Existing concepts such as:
	•	inventory movements
	•	inventory reservations
	•	purchase orders
	•	inbound receipts

must not be treated as shipment substitutes.

A dedicated shipment layer is required to bridge:
	•	yellow business layer (order / customer / sales intent)
	•	green inventory layer (batch / position / movement)

⸻

Core Decision

Shipment is a separate business object.

It must not be collapsed into:
	•	Order
	•	Inventory movements
	•	Inventory reservations
	•	Inbound receipts

Shipment belongs to the outbound / logistics domain.

⸻

Purpose

Shipment exists to represent:

the operational execution of outbound goods movement

It answers:
	•	what is being sent
	•	to whom it is being sent
	•	how much is planned vs actually shipped
	•	which inventory batches were used
	•	whether the shipment is only drafted, confirmed, shipped, or delivered

⸻

In Scope (v1)

The first shipment phase may include the following objects:

1. Shipment Header

Represents a single outbound shipment document.

Suggested fields:
	•	id
	•	org_id
	•	shipment_no
	•	status
	•	shipment_method
	•	order_reference (or optional order_id)
	•	buyer_business_entity_id
	•	supplier_id (if relevant in B2B flow)
	•	planned_ship_date
	•	shipped_at
	•	delivered_at
	•	notes
	•	created_at
	•	updated_at

2. Shipment Lines

Represents which product variants are being shipped.

Suggested fields:
	•	id
	•	shipment_id
	•	line_no
	•	product_variant_id
	•	ordered_qty
	•	planned_qty
	•	shipped_qty
	•	unit
	•	notes

3. Shipment Allocations

Represents which inventory batch / stock source fulfills each shipment line.

Suggested fields:
	•	id
	•	shipment_line_id
	•	batch_id
	•	source_position_id
	•	allocated_qty
	•	picked_qty (optional later)
	•	loaded_qty (optional later)
	•	created_at

4. Shipment Events (optional but recommended)

Represents shipment state changes.

Suggested fields:
	•	id
	•	shipment_id
	•	event_type
	•	event_time
	•	actor_type
	•	actor_id
	•	metadata

⸻

Shipment Status Model

Recommended v1 statuses:
	•	draft
	•	allocated
	•	ready_to_ship
	•	shipped
	•	delivered
	•	cancelled

Definitions:
	•	draft
Shipment exists but has not been fully allocated or confirmed.
	•	allocated
Inventory source has been assigned conceptually.
	•	ready_to_ship
Operationally ready to leave warehouse / location.
	•	shipped
Shipment has physically left origin.
	•	delivered
Recipient-side completion confirmed.
	•	cancelled
Shipment will not proceed.

⸻

Shipment Method Model

Recommended v1 methods:
	•	sales_direct
	•	courier
	•	pickup

Definitions:
	•	sales_direct
Delivered by salesperson directly.
	•	courier
Delivered by third-party logistics provider.
	•	pickup
Picked up by customer / partner.

⸻

Relationship to Order

Shipment may optionally relate to an order.

Rules:
	1.	One order may produce multiple shipments.
	2.	One shipment may represent only part of an order.
	3.	Shipment must not be stored merely as a status field inside Order.
	4.	Order and Shipment are linked, but remain independent objects.

Therefore:
	•	order_id or order_reference may exist on shipment header
	•	but shipment must still stand as its own model

⸻

Relationship to Inventory

Shipment does not replace inventory.

Shipment also does not automatically equal movement ledger.

Correct relationship:

Order
  -> Shipment
  -> Allocation
  -> Inventory execution
``` id="dsc6k1"

Rules:

1. Shipment line defines intended outbound quantity.
2. Shipment allocation defines which batch / position will fulfill it.
3. Inventory movement records physical execution.
4. Inventory remains the source of truth for stock state.

---

## What Shipment Must NOT Be

Shipment must NOT be implemented as:

### 1. A field inside Order
Example of what NOT to do:
- `orders.shipped = true`

### 2. A simple movement row
Example of what NOT to do:
- directly using `inventory_movements` as shipment document

### 3. A reservation alias
Example of what NOT to do:
- treating `inventory_reservations` as shipment allocation layer

### 4. An inbound document reuse
Example of what NOT to do:
- using `inventory_receipts` or `purchase_orders` as outbound shipment objects

---

## v1 Out of Scope

The following are explicitly excluded from Shipment Scope v1:

- courier API integration
- proof of delivery data model
- digital signature implementation
- invoice generation / dispatch
- customer-facing delivery portal
- packing / carton / pallet model
- picking task / route optimization
- financial settlement
- tax / accounting posting

These may be introduced in future phases.

---

## Alignment Note

This phase still follows current staging constraint:

- `org_id` remains temporarily aligned to `stores.id`

This is a staging-first compatibility decision only, not the final canonical organization model.

---

## Recommended Implementation Strategy

### Phase 1
- shipment header
- shipment lines
- shipment allocations
- create / allocate / confirm minimal RPC

### Phase 2
- inventory execution integration
- shipment_out / outbound_ship movement semantics (if needed)

### Phase 3
- delivery confirmation
- signature / proof of delivery
- invoice linkage

---

## Summary

Shipment is a dedicated outbound business object.

It sits between:

- order / customer / commercial intent
- inventory / batch / position / physical execution

This separation is necessary to preserve:

- partial shipment support
- batch-level traceability
- delivery state visibility
- long-term scalability
:::
