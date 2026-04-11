Staging Acceptance Policy v1

Status

Accepted

⸻

Purpose

This document defines what qualifies as “accepted” in staging before any feature, schema, or workflow is allowed to move forward.

Its purpose is to prevent:
	•	incomplete features entering production
	•	UI built on unstable data
	•	silent regression between layers
	•	“looks OK but actually broken” situations
	•	uncontrolled release of partially verified logic

⸻

Core Principle

A feature is not accepted because it runs.
A feature is accepted only when it is verified, observable, and consistent across layers.

⸻

Acceptance Levels

Level 0 — Not Ready
	•	code exists
	•	no verify
	•	no UI confirmation
	•	no stable contract

👉 Not allowed to be used or demoed

⸻

Level 1 — Schema / Logic Verified

Requirements:
	•	SQL / RPC exists
	•	verify SQL passes
	•	smoke test passes
	•	no runtime errors

Still missing:
	•	UI validation
	•	human readability
	•	cross-layer confirmation

👉 Allowed for backend testing only

⸻

Level 2 — Data Flow Verified (Core Acceptance)

Requirements:
	•	verify SQL passes
	•	story-based seed data works
	•	views return expected data
	•	RPC outputs match contract
	•	no data inconsistency
	•	data is visible in UI (even minimal)

👉 This is the minimum acceptance level for staging

⸻

Level 3 — Product Verified (UI + Flow)

Requirements:
	•	UI displays data correctly
	•	empty state handled
	•	edge cases do not break UI
	•	data is human-readable (labels, formatting)
	•	workflow makes sense to user

👉 Required before demo / internal usage

⸻

Level 4 — Operational Ready

Requirements:
	•	real-world scenario tested
	•	no logical gaps in workflow
	•	no blocking UX issue
	•	stable enough for limited production rollout

👉 Required before enabling for real users

⸻

Minimum Acceptance Criteria (MANDATORY)

A feature cannot be considered “accepted” unless all are satisfied:

1. Verify Script

Must exist and pass:
	•	verify SQL or test script
	•	explicit checks (not just “no error”)

Example:
	•	has_stock_by_batch_rows = ok
	•	movement_sequence = expected

⸻

2. Story-Based Seed

Must exist:
	•	at least one realistic data scenario
	•	multi-step flow (not trivial insert)
	•	reflects real business usage

Example:
	•	receive → shelf → load_machine → dispense
	•	shipment → allocation → confirm

⸻

3. UI Visibility

Must confirm:
	•	data appears in UI
	•	no blank critical screens
	•	empty states explain next step

⸻

4. Contract Consistency

Must confirm:
	•	RPC input/output matches contract
	•	view output matches expected fields
	•	no silent schema drift

⸻

5. Cross-Layer Integrity

Must confirm:
	•	Order / Shipment / Inventory boundaries respected
	•	no illegal direct writes
	•	no layer bypass

⸻

Additional Acceptance Requirements

Inventory (A6)

Must confirm:
	•	position states correct:
	•	unshelved
	•	location-backed
	•	machine-backed
	•	movement ledger consistent
	•	stock numbers correct after operations

⸻

Shipment

Phase-based acceptance:

Phase 1
	•	shipment created
	•	lines created
	•	allocation works
	•	no inventory mutation

Phase 2
	•	allocation validation works
	•	status transitions correct

Phase 3 (future)
	•	inventory deduction correct
	•	movement written correctly

⸻

AI / Automation

Must confirm:
	•	AI output matches contract
	•	AI does not write directly
	•	AI only calls approved RPC

⸻

Explicit Rejection Conditions

A feature must be rejected if:
	•	verify script missing
	•	verify result unclear
	•	UI shows incorrect data
	•	data exists but cannot be interpreted by user
	•	contract changed without versioning
	•	data layer bypass detected
	•	only “happy path” works but breaks on edge case
	•	no story-based scenario exists

⸻

Acceptance Output Format

Every staging acceptance must include:
	•	A. feature scope
	•	B. verify result
	•	C. seed scenario summary
	•	D. UI confirmation
	•	E. contract alignment
	•	F. known limitations

⸻

Relationship to Other Decisions

This policy enforces:
	•	decision_change_control_v1.md
	•	rpc_write_policy_v1.md
	•	data_boundary_rules_v1.md
	•	api_contract_versioning_v1.md
	•	shipment_phase_strategy_v1.md

⸻

Summary

Staging is not a sandbox.
It is a verification gate.

No verify → not accepted
No data flow → not accepted
No UI visibility → not accepted

Only features that pass all acceptance levels may move forward.
:::
