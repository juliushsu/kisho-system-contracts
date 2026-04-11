API Contract Versioning v1

Status

Accepted

⸻

Purpose

This document defines how API / RPC contracts must evolve without breaking:
	•	frontend applications
	•	admin tools
	•	AI agents
	•	staging verification scripts
	•	existing business flows

The goal is to ensure:
	•	backward compatibility
	•	controlled evolution
	•	explicit contract ownership
	•	safe multi-phase rollout

⸻

Core Principle

API contracts are versioned products, not implementation details.

Once a contract is consumed by:
	•	frontend UI
	•	external integration
	•	AI agent
	•	staging verify SQL
	•	internal service adapters

it must be treated as a stable interface.

⸻

Scope

This policy applies to:
	•	backend endpoints
	•	RPC function payload shape
	•	view output shape (when used as API source)
	•	service-layer DTO contracts
	•	agent-consumed JSON payloads

It does not apply to:
	•	purely internal helper SQL functions not externally consumed
	•	one-off migration scripts
	•	temporary debug output not used by product code

⸻

Contract Types

1. Public API Contract

Used by:
	•	frontend
	•	external integrations
	•	partner systems
	•	AI agents

Examples:
	•	REST endpoints
	•	Edge Functions
	•	RPC responses exposed to UI

2. Internal Product Contract

Used by:
	•	internal service adapters
	•	UI data services
	•	dashboard DTOs
	•	query-layer outputs explicitly depended on by product code

3. Experimental Contract

Used for:
	•	staging-only evaluation
	•	feature flags
	•	temporary pilot integrations

Experimental contracts must be clearly marked and must not silently replace stable ones.

⸻

Versioning Rule

Every stable API / RPC / DTO contract must follow explicit versioning.

Recommended suffix patterns:
	•	_v1
	•	_v2
	•	_v3

Examples:
	•	receive_inventory_v1
	•	create_shipment_v1
	•	v_inventory_stock_by_batch_v1

⸻

Breaking vs Non-Breaking Change

Non-Breaking Change

Allowed within same version:
	•	adding optional fields
	•	adding new enum values only if consumers are already tolerant
	•	improving descriptions / metadata
	•	adding new endpoints or RPCs

Breaking Change

Requires new version:
	•	renaming existing fields
	•	removing fields
	•	changing field types
	•	changing enum meaning
	•	changing required/optional semantics
	•	changing status transition behavior
	•	changing return shape structure
	•	changing core business meaning

⸻

Stable Contract Rule

Once a contract is marked stable:
	•	it must not be changed in-place in a breaking way
	•	breaking updates must be released as a new version
	•	old version must remain operational until consumers migrate

⸻

RPC Versioning Rule

All business RPCs must be versioned.

Examples:
	•	receive_inventory_v1
	•	transfer_inventory_v1
	•	create_shipment_v1

If behavior changes in a breaking way, do not overwrite silently.

Instead:
	•	create *_v2
	•	migrate consumers gradually
	•	deprecate *_v1 later

⸻

View Versioning Rule

Query views used by product code must be versioned.

Examples:
	•	v_inventory_stock_by_batch_v1
	•	v_inventory_stock_by_location_v1
	•	v_inventory_stock_by_variant_v1

If the output shape or semantics change in a breaking way:
	•	create a new view version
	•	do not silently replace the old one

⸻

DTO / Service Adapter Rule

Frontend and service adapters must consume explicit contract versions.

Allowed:
	•	InventoryStockByBatchV1
	•	ShipmentDetailV1

Not allowed:
	•	generic unversioned DTOs tied to unstable backend shape

⸻

AI Agent Contract Rule

If an AI agent consumes structured payloads:
	•	payload schema must be versioned
	•	agent prompts must reference version explicitly when needed
	•	silent payload shape changes are forbidden

Reason:
AI agents are especially fragile to shape drift.

⸻

Deprecation Policy

When a new version is introduced:

Phase 1 — Introduce
	•	add v2
	•	keep v1 working

Phase 2 — Migrate
	•	update consumers one by one
	•	verify staging compatibility

Phase 3 — Deprecate
	•	mark v1 as deprecated in docs
	•	stop new consumers from using it

Phase 4 — Remove
	•	only remove when all known consumers are migrated

⸻

Documentation Rule

Every stable contract must document:
	•	version name
	•	owner
	•	consumers
	•	expected input
	•	expected output
	•	breaking-change notes

If a new version is created, docs must state:
	•	why v2 exists
	•	what changed
	•	which consumers must migrate

⸻

Ownership Rule

Codex

Owns:
	•	SQL function contract
	•	view contract
	•	DB-level semantics

Readdy

Owns:
	•	UI consumption layer
	•	adapter stability
	•	no silent contract assumption

Platform / CTO

Owns:
	•	versioning policy
	•	deprecation timing
	•	cross-project consistency

⸻

Forbidden Patterns

❌ Silent In-Place Breaking Change

Example:
	•	changing movement_type meaning inside same _v1

❌ Reusing Same Name for New Shape

Example:
	•	overwriting v_inventory_stock_by_batch_v1 with incompatible output

❌ Frontend Guessing Shape

Example:
	•	UI infers fields without documented DTO contract

❌ AI Prompt Assuming Unversioned Payload

Example:
	•	agent prompt depends on whatever current JSON looks like

⸻

Recommended Versioning Strategy

For database / RPC
	•	explicit suffix:
	•	_v1, _v2

For frontend DTO / adapters
	•	explicit type naming:
	•	InventoryMovementRowV1
	•	ShipmentHeaderV1

For docs
	•	store contracts in Git decisions / contracts repo

⸻

Relationship to Other Decisions

This policy enforces and protects:
	•	rpc_write_policy_v1.md
	•	data_boundary_rules_v1.md
	•	shipment_phase_strategy_v1.md
	•	all versioned A5 / A6 / shipment contracts

⸻

Summary

The system must evolve by versioned contracts, not silent mutation.

Stable contracts may grow carefully,
but breaking changes require a new version.

This protects:
	•	frontend stability
	•	AI agent stability
	•	multi-team coordination
	•	long-term maintainability
:::
