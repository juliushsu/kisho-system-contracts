Data Boundary Rules v1

Status

Accepted

⸻

Purpose

This document defines strict data ownership and write boundaries between:
	•	Order layer (Business)
	•	Shipment layer (Fulfillment)
	•	Inventory layer (Stock)
	•	Delivery layer (Proof)
	•	AI layer (Automation)

The goal is to prevent:
	•	cross-layer data corruption
	•	duplicated business logic
	•	uncontrolled side effects
	•	breaking A6 inventory foundation

⸻

Core Principle

Each layer owns its own data.
No layer may directly mutate another layer’s state outside defined contracts.

⸻

Layer Definitions

1. Order Layer (Business / Sales)

Represents:
	•	customer intent
	•	sales agreements
	•	commercial commitments

Examples:
	•	orders
	•	order_lines
	•	quotes
	•	CRM interactions

Ownership
	•	owns order data
	•	owns customer-facing business state

Forbidden
	•	❌ must NOT modify inventory_positions
	•	❌ must NOT write inventory_movements
	•	❌ must NOT create shipment allocations directly

⸻

2. Shipment Layer (Fulfillment / Execution Planning)

Represents:
	•	outbound execution plan
	•	what will be shipped
	•	how it will be fulfilled

Examples:
	•	shipments
	•	shipment_lines
	•	shipment_allocations

Ownership
	•	owns shipment documents
	•	owns allocation plan (which batch, which position)

Allowed
	•	reference:
	•	orders
	•	inventory_batches
	•	inventory_positions (read-only in Phase 1/2)

Forbidden (Phase 1 & 2)
	•	❌ must NOT deduct stock
	•	❌ must NOT write inventory_movements
	•	❌ must NOT mutate inventory_positions

Controlled (Phase 3 only)
	•	may trigger inventory execution via RPC
	•	must NOT bypass inventory layer

⸻

3. Inventory Layer (Stock / Physical Truth)

Represents:
	•	actual stock state
	•	physical availability
	•	movement ledger

Examples:
	•	inventory_batches
	•	inventory_positions
	•	inventory_movements

Ownership
	•	owns all stock quantities
	•	owns movement history
	•	owns position state (unshelved / location / machine)

Allowed
	•	mutate stock via controlled RPC only
	•	maintain consistency via movement ledger

Forbidden
	•	❌ must NOT depend on shipment existence
	•	❌ must NOT depend on order state
	•	❌ must NOT infer business meaning (e.g. revenue)

⸻

4. Delivery Layer (Proof / Completion)

Represents:
	•	actual delivery completion
	•	proof of handover

Examples:
	•	delivery_events
	•	signatures
	•	proof_of_delivery

Ownership
	•	owns delivery confirmation
	•	owns recipient validation

Forbidden
	•	❌ must NOT change inventory state
	•	❌ must NOT change shipment allocation
	•	❌ must NOT back-propagate into order layer

⸻

5. AI Layer (Automation / Assistance)

Represents:
	•	recommendations
	•	automation helpers
	•	communication agents

Examples:
	•	auto-generated shipment drafts
	•	supplier communication
	•	demand forecasting

Allowed
	•	suggest actions
	•	generate drafts
	•	trigger approved RPCs

Forbidden
	•	❌ must NOT directly write core tables
	•	❌ must NOT bypass RPC contracts
	•	❌ must NOT become source of truth

⸻

Write Authority Matrix

Layer	Can Write Own Tables	Can Write Other Layers
Order	✅	❌
Shipment	✅	❌ (except via RPC in Phase 3)
Inventory	✅	❌
Delivery	✅	❌
AI	❌	❌


⸻

Cross-Layer Interaction Rules

Order → Shipment
	•	allowed via explicit creation flow
	•	shipment may reference order_id or order_reference

Shipment → Inventory
	•	Phase 1–2: read-only
	•	Phase 3: via controlled RPC only

Inventory → Shipment
	•	never pushes data
	•	shipment must pull (read)

Delivery → Shipment
	•	may update shipment status (e.g. delivered)
	•	must not change allocation

AI → All Layers
	•	may call approved RPCs
	•	must not directly write tables

⸻

Movement Ledger Rule

inventory_movements is the only source of truth for stock changes.

Therefore:
	•	no other table may simulate stock change
	•	no “implicit deduction” allowed
	•	all stock changes must be auditable

⸻

Position Integrity Rule

Position state must remain strictly:
	•	unshelved = no location_id AND no machine_id
	•	location-backed = location_id is not null
	•	machine-backed = machine_id is not null

No other layer may redefine this.

⸻

Anti-Pattern (Strictly Forbidden)

1. Shipment directly deducting stock

❌ Writing inventory_positions from shipment logic

2. Order reserving stock without inventory layer

❌ Direct write into positions or batches

3. UI bypassing RPC

❌ Frontend writing raw DB tables

4. AI auto-writing core tables

❌ Agent writing shipments / inventory without RPC

5. Mixing business meaning into inventory

❌ inventory storing revenue / order status

⸻

Enforcement Strategy
	•	All writes must go through:
	•	RPC (Codex controlled)
	•	All reads:
	•	must prefer view layer (A6-2)
	•	UI:
	•	must not call raw table mutation

⸻

Relationship to Other Decisions

This document must be enforced together with:
	•	shipment_phase_strategy_v1.md
	•	shipment_scope_v1.md
	•	shipment_order_inventory_boundary_v1.md
	•	inventory_position_state_rules_v1.md
	•	inventory_org_identity_temporary_alignment.md
	•	modern_delivery_and_signature_flow_v1.md

⸻

Summary

The system is intentionally layered:
	•	Order = intent
	•	Shipment = plan
	•	Inventory = physical truth
	•	Delivery = proof
	•	AI = assistant

Each layer must remain independent.

Breaking these boundaries will result in:
	•	inconsistent stock
	•	untraceable movements
	•	system instability

This document defines the non-negotiable rules to prevent that.
:::
