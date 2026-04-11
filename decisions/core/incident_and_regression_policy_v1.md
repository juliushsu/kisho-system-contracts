Incident and Regression Policy v1

Status

Accepted

⸻

Purpose

This document defines how the system must handle:
	•	incidents (unexpected failures)
	•	regressions (fix A, break B situations)
	•	unstable changes introduced by schema, RPC, UI, or AI agents

Its purpose is to ensure:
	•	system stability
	•	fast containment of issues
	•	safe rollback capability
	•	prevention of repeated breakage

⸻

Core Principle

No fix is considered complete if it introduces new instability.

⸻

Definitions

Incident

Any unexpected behavior that breaks:
	•	system functionality
	•	data consistency
	•	UI usability
	•	contract expectations

Examples:
	•	API returns wrong shape
	•	inventory count incorrect
	•	shipment cannot be created
	•	UI crashes or shows incorrect data

⸻

Regression

A previously working feature becomes broken after a change.

Examples:
	•	fixing inventory view breaks dashboard
	•	modifying RPC breaks UI page
	•	updating contract breaks AI agent

⸻

Incident Severity Levels

P0 — Critical
	•	system unusable
	•	data corruption risk
	•	inventory inconsistency
	•	shipment execution blocked

Action:
	•	immediate stop
	•	rollback or hotfix required

⸻

P1 — Major
	•	core feature broken
	•	incorrect data displayed
	•	workflow blocked but recoverable

Action:
	•	urgent fix required
	•	staging verify before release

⸻

P2 — Minor
	•	UI issue
	•	non-critical logic mismatch
	•	cosmetic inconsistency

Action:
	•	fix in next iteration

⸻

Immediate Response Protocol

When incident is detected:

Step 1 — Stop Change Propagation
	•	do NOT continue development on top of broken state
	•	freeze related changes

⸻

Step 2 — Identify Scope
	•	which layer is affected:
	•	Order
	•	Shipment
	•	Inventory
	•	Delivery
	•	UI
	•	AI

⸻

Step 3 — Reproduce Issue
	•	use staging
	•	confirm consistent reproduction
	•	identify exact trigger

⸻

Step 4 — Classify Severity
	•	P0 / P1 / P2

⸻

Step 5 — Decide Action

For P0
	•	rollback immediately OR
	•	apply minimal hotfix

For P1
	•	fix in staging
	•	re-run verify
	•	then release

For P2
	•	log and schedule

⸻

Regression Prevention Rule

Every fix must include:

1. Root Cause Identification

Must explain:
	•	what broke
	•	why it broke
	•	which layer caused it

⸻

2. Verify Coverage Expansion

Add or update:
	•	verify SQL
	•	seed scenario
	•	UI check

to ensure issue cannot repeat

⸻

3. Boundary Check

Confirm:
	•	no violation of data_boundary_rules_v1.md
	•	no RPC bypass
	•	no contract drift

⸻

Mandatory Regression Checklist

Before marking fix complete:
	•	verify script passes
	•	seed scenario still valid
	•	UI still renders correctly
	•	no unrelated feature broken
	•	contract unchanged OR versioned
	•	cross-layer behavior consistent

⸻

Rollback Strategy

When to Rollback

Rollback is required if:
	•	P0 issue
	•	unknown root cause
	•	multi-layer instability
	•	data inconsistency risk

⸻

What Can Be Rolled Back
	•	UI changes (Readdy)
	•	RPC changes (Codex)
	•	view definitions
	•	feature flags

⸻

What Must NOT Be Rolled Back Carelessly
	•	schema migrations (must use forward fix)
	•	production data mutations

⸻

Safe Fix Strategy

When fixing incident:

Rule 1 — Minimal Fix First
	•	fix only what is broken
	•	avoid refactor during incident

⸻

Rule 2 — No Multi-Layer Fix

❌ do NOT fix UI + RPC + schema together

⸻

Rule 3 — Verify Before Extend
	•	fix must pass staging acceptance
	•	only then continue feature work

⸻

Anti-Patterns (Strictly Forbidden)

❌ “Quick Fix” Without Verify
	•	fix deployed without test
	•	no reproduction confirmation

⸻

❌ Fix + Feature Together
	•	mixing bug fix with new feature
	•	impossible to isolate regression

⸻

❌ Silent Contract Change
	•	changing RPC response without versioning
	•	breaking UI or AI agent

⸻

❌ Ignoring Seed Scenario
	•	fixing logic but not updating story data
	•	UI becomes inconsistent

⸻

❌ Continuing Development on Broken Base
	•	building new features while bug exists

⸻

Incident Reporting Format

Every incident must include:
	•	A. issue description
	•	B. severity (P0 / P1 / P2)
	•	C. reproduction steps
	•	D. impacted layers
	•	E. root cause
	•	F. fix applied
	•	G. verify result
	•	H. regression prevention added

⸻

Relationship to Other Decisions

This policy enforces:
	•	staging_acceptance_policy_v1.md
	•	decision_change_control_v1.md
	•	rpc_write_policy_v1.md
	•	data_boundary_rules_v1.md

⸻

Summary

Incidents are expected.
Uncontrolled regressions are not.

Fix must stabilize the system, not just remove symptoms.

Every fix must:
	•	be verified
	•	respect boundaries
	•	prevent recurrence

This ensures the system becomes more stable over time, not less.
:::
