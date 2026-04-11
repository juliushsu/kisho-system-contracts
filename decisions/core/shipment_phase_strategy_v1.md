Shipment Phase Strategy v1

Status

Accepted

⸻

Purpose

This decision defines how the shipment layer must evolve without breaking the existing A6 inventory foundation.

The shipment layer is allowed to grow only by adding on top of:
	•	A6-1 inventory foundation
	•	A6-2 query layer
	•	A6-3 inventory operation RPCs
	•	A6-4 inventory UI

It must not redefine or bypass them.

⸻

Core Rule

A6 inventory is the foundation.
Shipment must be layered on top of A6, not pushed underneath it.

This means:
	•	inventory remains the stock source of truth
	•	shipment remains a separate outbound business object
	•	order, shipment, and inventory must stay separated

⸻

Phase Structure

Shipment must evolve in controlled phases.

⸻

Phase 1 — Shipment Document Layer

Goal

Create shipment as a business document layer only.

Allowed
	•	shipment header
	•	shipment lines
	•	shipment allocations
	•	create shipment
	•	allocate batch to shipment line
	•	confirm shipment document

Not Allowed
	•	no inventory deduction
	•	no inventory movement writes
	•	no reservation mutation
	•	no dispatch execution
	•	no delivery proof

Required Meaning
	•	confirm_shipment_v1 = document confirmation only
	•	not physical shipment execution

Notes

This phase may include:
	•	shipment_method
	•	source_position_id

because they are semantic header/allocation requirements, not inventory execution.

⸻

Phase 2 — Dispatch Preparation Layer

Goal

Prepare shipment for operational execution.

Allowed
	•	validate shipment allocations
	•	validate batch / position consistency
	•	introduce dispatch-specific RPC planning
	•	introduce clearer shipment status transitions

Recommended Additions
	•	dispatch_shipment_v1 (planning / validation first)
	•	shipment status expansion:
	•	allocated
	•	ready_to_ship
	•	cancelled

Not Allowed
	•	still no stock deduction
	•	still no inventory movement writes
	•	still no automatic physical completion

Why

This phase separates:
	•	document confirmed
from
	•	physically dispatched

⸻

Phase 3 — Inventory Execution Integration

Goal

Allow confirmed shipment to consume stock in a controlled and auditable way.

Allowed
	•	deduct stock from source_position_id
	•	write outbound inventory movement
	•	bind shipment execution to inventory ledger

Requirements
	•	must run transactionally
	•	all-or-nothing execution
	•	full audit trail
	•	allocation must already be validated
	•	source position must be explicit

Recommended RPC
	•	complete_shipment_v1
or
	•	dispatch_shipment_v1 (execution version)

Rules
	•	shipment execution must consume inventory through formal inventory logic
	•	shipment must not directly mutate raw stock outside controlled RPC flow

⸻

Phase 4 — Delivery and Proof Layer

Goal

Digitize delivery completion and recipient confirmation.

Allowed
	•	delivered status
	•	proof of delivery
	•	signature capture
	•	courier confirmation
	•	delivery timeline

Recommended Models
	•	delivery event
	•	signature / proof object
	•	delivered timestamp
	•	signer metadata

Notes

This phase belongs to delivery fulfillment, not inventory foundation.

Inventory consumption should already be completed before this phase finalizes recipient-side proof.

⸻

Phase 5 — AI / Automation Layer

Goal

Add operational automation on top of stable shipment and delivery flows.

Examples
	•	shipment drafting from order
	•	supplier / partner coordination
	•	email / LINE notifications
	•	exception reminders
	•	outbound planning suggestions

Rules

AI may:
	•	propose
	•	draft
	•	summarize
	•	notify

AI may not:
	•	bypass shipment contract
	•	bypass inventory execution rules
	•	become source of truth

⸻

Non-Negotiable Safety Rules

Rule 1

Shipment must never redefine inventory position semantics.

Rule 2

Shipment must never bypass A6 RPC boundaries.

Rule 3

Shipment must not turn inventory movements into shipment documents.

Rule 4

Order, Shipment, Inventory, and Delivery Proof remain distinct layers.

Rule 5

Any new shipment feature must declare which phase it belongs to.

⸻

Allowed vs Forbidden by Phase

Phase	Allowed	Forbidden
Phase 1	shipment docs, lines, allocations, confirm document	deduct stock, write movement
Phase 2	dispatch planning, validation, richer statuses	stock deduction
Phase 3	inventory execution, outbound ledger write	bypassing controlled RPC
Phase 4	delivery proof, signature, delivered status	changing inventory semantics
Phase 5	AI suggestions and automation	AI direct source-of-truth writes


⸻

Relationship to Existing Decisions

This strategy must be interpreted together with:
	•	platform_operating_model_v1.md
	•	shipment_scope_v1.md
	•	shipment_order_inventory_boundary_v1.md
	•	inventory_position_state_rules_v1.md
	•	inventory_org_identity_temporary_alignment.md
	•	modern_delivery_and_signature_flow_v1.md

⸻

Summary

Shipment must grow in phases.

It must start as a document layer, then become a dispatch layer, then integrate with inventory execution, and only later expand into delivery proof and AI automation.

This phased model protects the A6 foundation and prevents shipment logic from corrupting the existing inventory system.
:::
