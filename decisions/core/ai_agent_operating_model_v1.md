AI Agent Operating Model v1

Status

Accepted

⸻

Purpose

This document defines the operating model for all AI agents in the system, including:
	•	procurement assistants (Japan supplier coordination)
	•	shipment / logistics assistants
	•	inventory / replenishment assistants
	•	communication assistants (LINE / Email / Gmail)
	•	internal AI tools

The goal is to:
	•	maximize automation efficiency
	•	preserve human decision authority
	•	protect cost / pricing / org boundary integrity
	•	align AI behavior with system architecture (RBAC + data boundary)

⸻

Core Principle

AI assists.
Humans decide.
System enforces.

AI is responsible for:
	•	preparation
	•	summarization
	•	suggestion
	•	coordination

AI is NOT responsible for:
	•	final business decisions
	•	irreversible actions
	•	cross-org reasoning

⸻

Agent Capability Levels

Level 1 — Read & Summarize (Allowed)

AI may:
	•	read AI-safe org-scoped data
	•	summarize shipment / inventory / procurement state
	•	generate reports
	•	highlight anomalies

Examples:
	•	“近 7 天出貨摘要”
	•	“哪些批次快過期”
	•	“目前庫存結構分析”

⸻

Level 2 — Suggest & Draft (Allowed)

AI may:
	•	generate procurement suggestions
	•	propose shipment plans
	•	draft LINE / Email messages
	•	suggest reorder quantities
	•	prepare supplier communication

Examples:
	•	採購建議（依銷售 / 庫存）
	•	日本供應商詢價草稿
	•	船期安排建議
	•	補貨建議

⸻

Level 3 — Execute (Restricted)

AI must NOT directly execute:
	•	create confirmed procurement orders
	•	modify cost / pricing
	•	dispatch shipments
	•	deduct inventory
	•	change distribution rights
	•	commit financial actions

These actions require human approval.

⸻

Human Approval Checkpoints

The following operations must always require explicit human confirmation:

Procurement
	•	final order quantity
	•	supplier selection
	•	pricing / cost agreement

Logistics
	•	shipment dispatch
	•	cold chain / delivery method selection
	•	schedule confirmation

Financial / Pricing
	•	cost updates
	•	margin changes
	•	pricing adjustments

Inventory
	•	stock deduction (dispatch execution)
	•	adjustment with business impact

⸻

AI Task Lifecycle

All AI-driven operations must follow a controlled lifecycle:

draft
→ awaiting_human_review
→ approved
→ executed (by system / user action)
→ completed
``` id="ai-task-lifecycle"

### Rules
- AI can create `draft`
- AI can move to `awaiting_human_review`
- Only human can approve
- System executes after approval

---

## Agent Scope Rules

### Org Isolation
AI must operate strictly within:

```text
org_id scope only
``` id="ai-org-scope"

No cross-org reasoning or comparison is allowed.

---

### Data Access Constraint

AI must follow:

- `ai_query_role`
- AI-safe views
- controlled RPC

AI must not:
- access base tables
- infer hidden cost structures
- aggregate across organizations

---

## Procurement Agent Model (Japan Supplier)

### AI Responsibilities
- analyze inventory + sales trends
- generate reorder suggestion
- estimate container / shipment volume
- draft supplier communication (LINE / Email)
- summarize supplier replies

### Human Responsibilities
- confirm order quantity
- confirm supplier
- confirm schedule / shipment timing

---

### Example Flow

```text
inventory signal
→ AI suggests reorder plan
→ human reviews & adjusts
→ AI drafts email to supplier
→ human approves sending
→ supplier replies
→ AI summarizes reply
→ human confirms final order
``` id="procurement-flow"

---

## Shipment Agent Model

### AI Responsibilities
- summarize shipment readiness
- highlight missing allocations
- detect anomalies (e.g. unallocated lines)
- suggest dispatch readiness

### Human Responsibilities
- confirm dispatch
- handle exceptions
- validate delivery

---

## Communication Agent Model

AI may:
- draft LINE messages
- draft emails
- summarize conversations
- extract key points

AI must not:
- send messages without approval (Phase 1)
- negotiate pricing autonomously
- expose internal cost logic

---

## Inventory Intelligence Model

AI may:
- detect low stock
- suggest reorder timing
- highlight near-expiry batches
- suggest allocation priority (FEFO)

AI must not:
- auto-adjust inventory
- override position logic
- simulate cross-org inventory

---

## Cost & Pricing Protection

AI must NOT:

- reveal cost tier structure (A/B/C/D/E)
- infer upstream pricing
- suggest negotiation based on hidden cost
- compare cost across organizations

AI may:
- calculate margin within org scope
- suggest improvements based on internal data only

---

## Middleware Dependency

All agent execution must go through:

- AI middleware layer
- org context injection
- RPC routing control

AI agent must never:
- directly query database
- use unrestricted credentials

---

## Failure Handling

If any of the following occurs:

- missing org context
- data access failure
- inconsistent state

Then:

- AI must stop execution
- AI may return explanation
- AI must not fabricate data

---

## Anti-Patterns (Forbidden)

### 1. Autonomous decision-making
❌ AI directly places supplier orders

### 2. Cross-org intelligence
❌ "其他酒商平均成本較低"

### 3. Hidden cost leakage
❌ 推測上游成本

### 4. Direct DB access
❌ AI 查 base table

### 5. Unapproved execution
❌ AI 自動 dispatch shipment

---

## Phase Strategy

### Phase 1 (Current)
- Read + Suggest only
- Human approval mandatory
- No auto-execution

### Phase 2
- Limited auto-actions with approval
- shipment dispatch integration
- procurement workflow tooling

### Phase 3
- semi-automated execution
- exception-based human intervention
- advanced optimization

---

## Relationship to Other Decisions

This document must be used together with:

- `ai_data_access_boundary_v1.md`
- `ai_middleware_policy_v1.md`
- `distribution_pricing_cost_rbac_v1.md`
- `org_margin_reporting_scope_v1.md`
- `shipment_phase_strategy_v1.md`

---

## Summary

AI is a powerful assistant, not an autonomous operator.

The system ensures:

- AI operates within strict org boundaries
- AI prepares decisions, humans approve them
- AI never exposes hidden cost or cross-org data
- AI cannot execute critical actions without approval

This creates a scalable, safe, and commercially viable AI-driven system.
:::
