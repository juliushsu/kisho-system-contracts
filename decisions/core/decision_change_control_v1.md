Decision Change Control v1

Status

Accepted

⸻

Purpose

This document defines how architectural, schema, RPC, UI, and workflow changes must be controlled across the platform.

Its purpose is to protect the system from:
	•	breaking stable foundations
	•	uncontrolled cross-layer changes
	•	silent contract drift
	•	“fix A, break B” regressions
	•	inconsistent work between Codex, Readdy, and AI agents

⸻

Core Principle

Stable foundations must not be modified casually.

Any change that affects:
	•	schema
	•	RPC
	•	query views
	•	core workflow meaning
	•	shared contracts
	•	multi-tenant boundaries

must go through explicit change control.

⸻

Foundation Protection Rule

The following are considered foundation layers:
	•	A5 governance / idempotency / duplicate control
	•	A6-1 inventory foundation
	•	A6-2 query layer
	•	A6-3 inventory operation RPCs
	•	A6 contract / decision files
	•	shared catalog / distribution rights model
	•	shipment phase strategy
	•	RPC write policy
	•	data boundary rules
	•	API contract versioning

These foundations may only be changed through controlled process.

⸻

Change Categories

Category A — Foundation Change

Changes to:
	•	DB schema
	•	versioned RPC behavior
	•	query view output shape
	•	org boundary rules
	•	inventory semantics
	•	shipment phase meaning
	•	AI quota / billing core model

Category B — Product Layer Change

Changes to:
	•	UI routes
	•	page composition
	•	read-only dashboards
	•	display labels
	•	non-breaking adapter logic

Category C — Content / Cosmetic Change

Changes to:
	•	copy
	•	colors
	•	spacing
	•	layout refinement
	•	help text
	•	empty state wording

⸻

Required Process by Category

Category A — Foundation Change

Must:
	1.	write or update Git decision / contract first
	2.	review boundary impact
	3.	implement in staging first
	4.	run verify / smoke script
	5.	only then allow UI consumption

Not allowed:
	•	direct implementation without decision
	•	production-first changes
	•	silent replacement of stable contracts

⸻

Category B — Product Layer Change

Must:
	1.	align with existing Git decisions
	2.	avoid creating implicit schema assumptions
	3.	use staging data / stable contracts
	4.	report impacted routes / files

May proceed without new decision only if:
	•	no boundary meaning changes
	•	no write contract changes
	•	no new cross-layer coupling

⸻

Category C — Content / Cosmetic Change

May proceed directly if:
	•	no logic changes
	•	no data model implications
	•	no change in meaning

Still recommended:
	•	report changed files
	•	preserve humanized wording consistency

⸻

Mandatory “Write-to-Git First” Cases

A Git decision / contract must be created or updated before implementation if the change introduces:
	•	a new business layer
	•	a new cross-layer relationship
	•	a new role / permission model
	•	a new inventory or shipment semantic
	•	a new billing / quota rule
	•	a new AI automation boundary
	•	a new document / legal compliance rule
	•	a new versioned contract

Examples:
	•	shipment layer
	•	delivery proof model
	•	distribution rights
	•	AI quota billing model
	•	org identity changes

⸻

Mandatory Staging Verification Cases

The following changes must have staging verification before being accepted:
	•	schema migrations
	•	new RPCs
	•	new view contracts
	•	inventory logic changes
	•	shipment logic changes
	•	seed / demo story changes that affect product pages
	•	any change touching A6 foundation

Verification may include:
	•	verify SQL
	•	smoke SQL
	•	story-based seed validation
	•	UI walkthrough on staging

⸻

Prohibited Change Patterns

1. UI First, Schema Later

❌ Readdy builds semantics before Codex defines data model

2. Schema First, No Contract

❌ Codex creates new tables/RPC without Git decision

3. Silent Meaning Shift

❌ Existing field / status / movement meaning changes without versioning

4. Direct Production Mutation

❌ Manual patching of production business data without staging path

5. Multi-Layer Refactor in One Step

❌ Changing order + shipment + inventory + UI in one uncontrolled jump

⸻

Safe Rollout Pattern

Recommended rollout order:
	1.	Git decision / contract
	2.	Codex audit / gap analysis
	3.	staging schema / RPC
	4.	verify / smoke
	5.	Readdy UI
	6.	demo seed / walkthrough
	7.	production planning

This order is mandatory for all core workflows.

⸻

Role Responsibility

CTO / Platform Governance

Responsible for:
	•	deciding change category
	•	approving foundation changes
	•	deciding when a new Git decision is required
	•	protecting A5 / A6 foundations

Codex

Responsible for:
	•	schema / RPC / SQL implementation
	•	verify scripts
	•	not exceeding contract scope

Readdy

Responsible for:
	•	UI implementation within contract
	•	no hidden schema assumptions
	•	no write-path bypass

AI Agents / Automation

Responsible for:
	•	following approved flows only
	•	not improvising architecture changes

⸻

Decision Update Rule

When a stable decision is changed:
	•	do not silently rewrite meaning
	•	update document explicitly
	•	note what changed
	•	state whether existing consumers are affected
	•	create v2 if semantic change is breaking

⸻

Minimum Change Report Format

For any Category A or major Category B change, report must include:
	•	A. what changed
	•	B. why it changed
	•	C. impacted files / contracts
	•	D. staging verification result
	•	E. whether any existing behavior changed

This format is mandatory for cross-team coordination.

⸻

Relationship to Other Decisions

This document enforces:
	•	platform_operating_model_v1.md
	•	data_boundary_rules_v1.md
	•	rpc_write_policy_v1.md
	•	api_contract_versioning_v1.md
	•	shipment_phase_strategy_v1.md

⸻

Summary

This platform must evolve through controlled steps.

If the change touches foundations, write the rule first.
If the change touches behavior, verify in staging first.
If the change only affects presentation, keep it lightweight.

This policy exists to protect the system from uncontrolled drift and regression.
:::
