RPC Write Policy v1

Status

Accepted

⸻

Purpose

This document defines how all data mutations must be executed across the system.

It enforces a strict rule:

All writes must go through controlled RPC functions.
Direct table mutation is forbidden.

This ensures:
	•	data consistency
	•	auditability
	•	boundary enforcement (Order / Shipment / Inventory separation)
	•	protection of A6 inventory foundation

⸻

Core Rule

No component is allowed to write directly to database tables.

All mutations must go through:
	•	approved RPC functions (PostgreSQL functions)
	•	controlled backend endpoints (if applicable)

⸻

Write Path Architecture

UI / Agent / API
        ↓
    RPC Layer (Codex controlled)
        ↓
   Database Tables


⸻

Who Can Write

1. Codex (Backend / SQL Owner)

Allowed:
	•	create RPC functions
	•	maintain mutation logic
	•	enforce constraints
	•	define transactional behavior

Not Allowed:
	•	❌ expose raw table writes to frontend
	•	❌ bypass RPC layer

⸻

2. Readdy (Frontend)

Allowed:
	•	call RPC functions
	•	pass validated payloads
	•	render results

Not Allowed:
	•	❌ insert/update/delete directly on tables
	•	❌ construct business logic that bypasses RPC
	•	❌ write to Supabase tables directly from UI

⸻

3. AI Agents (OpenClaw / GPT / Automation)

Allowed:
	•	call approved RPC endpoints
	•	suggest actions
	•	generate payloads

Not Allowed:
	•	❌ direct DB access
	•	❌ writing raw SQL mutations
	•	❌ bypassing validation

⸻

4. System Admin / Scripts

Allowed:
	•	run migration scripts
	•	run controlled seed scripts
	•	execute verified SQL patches

Not Allowed:
	•	❌ manual ad-hoc mutation in production
	•	❌ bypassing migration or RPC logic

⸻

Allowed Write Mechanisms

1. RPC Functions (Primary)

Examples:
	•	receive_inventory_v1
	•	transfer_inventory_v1
	•	load_machine_inventory_v1
	•	create_shipment_v1
	•	allocate_shipment_batch_v1
	•	confirm_shipment_v1

All business writes must be implemented as RPC.

⸻

2. Migration SQL (Schema Only)

Allowed:
	•	create table
	•	alter table
	•	create index
	•	create constraint

Not Allowed:
	•	❌ business data mutation (except seed scripts)

⸻

3. Seed Scripts (Controlled Data Only)

Allowed:
	•	demo data
	•	staging verification
	•	story-based dataset

Requirements:
	•	must be idempotent OR cleanup-first
	•	must not corrupt production logic

⸻

Forbidden Write Patterns

❌ Direct Table Mutation from Frontend

Example (forbidden):

supabase.from('inventory_positions').update(...)


⸻

❌ Bypassing Inventory RPC

Example:
	•	shipment deducting stock directly
	•	UI adjusting batch quantities

⸻

❌ Mixed Layer Writes

Example:
	•	order writing shipment tables
	•	shipment writing inventory tables (Phase 1/2)

⸻

❌ AI Direct SQL Execution

Example:
	•	agent writing SQL to production DB
	•	auto-fixing data without RPC

⸻

RPC Design Rules

Rule 1 — Single Responsibility

Each RPC must represent a clear business operation.

Example:
	•	receive_inventory_v1
	•	transfer_inventory_v1

⸻

Rule 2 — Atomic Execution

Each RPC must:
	•	run inside transaction
	•	succeed fully or rollback

⸻

Rule 3 — Explicit Input Contract

RPC must:
	•	validate all inputs
	•	reject invalid state early

⸻

Rule 4 — Explicit Output Contract

All RPCs should return:
	•	ok boolean
	•	identifiers (e.g. batch_id, shipment_id)
	•	structured detail (jsonb)

⸻

Rule 5 — No Hidden Side Effects

RPC must not:
	•	mutate unrelated tables
	•	trigger implicit logic outside scope

⸻

Inventory-Specific Rule

Only inventory RPCs may modify inventory tables.

Tables protected:
	•	inventory_batches
	•	inventory_positions
	•	inventory_movements

Shipment / Order / UI must not write these directly.

⸻

Shipment-Specific Rule

Phase 1–2

Shipment RPC:
	•	may write shipment tables only

Phase 3+

Shipment RPC:
	•	may trigger inventory RPC
	•	must not mutate inventory directly

⸻

Logging & Audit

All critical RPCs must:
	•	write inventory_movements (for stock changes)
	•	include:
	•	operator_type
	•	operator_id
	•	reference_type
	•	reference_id

⸻

Enforcement Strategy

Technical
	•	Supabase RLS (future)
	•	restricted table permissions
	•	RPC-only write access

Process
	•	PR review must check:
	•	no direct table write
	•	correct RPC usage

⸻

Relationship to Other Decisions

This policy enforces:
	•	data_boundary_rules_v1.md
	•	shipment_phase_strategy_v1.md
	•	inventory_position_state_rules_v1.md

⸻

Summary

The system enforces a strict rule:

Tables are not APIs. RPC is the API.

All writes must go through controlled, auditable, and validated RPC functions.

This prevents:
	•	data corruption
	•	hidden logic
	•	cross-layer contamination

and ensures long-term system stability.
