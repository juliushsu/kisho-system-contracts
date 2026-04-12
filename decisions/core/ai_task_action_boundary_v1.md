# AI Task Action Boundary v1

## 1. Purpose

This document defines the **execution boundary** for AI task actions.

It ensures that:
- AI-assisted workflows remain **human-gated**
- Collaboration layer (`ai_tasks`) does **not mutate canonical business state**
- System integrity is preserved across shipment, procurement, inventory, and pricing domains

This document is **binding for both backend (Codex) and frontend (Readdy)**.

---

## 2. Layer Separation Principle

The system is divided into 4 layers:

1. AI Read Layer (`v_ai_org_*`, ai_query_role)
2. Task / Collaboration Layer (`ai_tasks`)
3. Business Layer (shipment / purchase / import)
4. Inventory Layer (batch / position / movement)

### Rule

> Task Layer MAY reference Business Layer  
> Task Layer MUST NOT mutate Business Layer

---

## 3. Allowed Actions (Phase A8-6)

The following actions are permitted:

### 3.1 approve_ai_task_v1

- Transition:
  - `awaiting_human_review -> approved`

- Writes:
  - `state = approved`
  - `reviewer_id`
  - `human_decision`
  - `updated_at`

- Meaning:
  - Human approves AI suggestion
  - DOES NOT imply execution of business action

---

### 3.2 return_ai_task_to_draft_v1

- Transition:
  - `awaiting_human_review -> draft`

- Writes:
  - `state = draft`
  - `reviewer_id`
  - `human_decision`
  - `updated_at`

- Meaning:
  - Human rejects or requests revision
  - Task re-enters editable state

---

### 3.3 resolve_ai_task_v1

- Transition:
  - `approved -> resolved`

- Writes:
  - `state = resolved`
  - `reviewer_id`
  - `resolution`
  - `resolved_at`
  - `updated_at`

- Meaning:
  - Task is closed after human review
  - DOES NOT imply canonical transaction completion

---

## 4. Forbidden Actions

The following are strictly prohibited within AI Task Actions:

### 4.1 Canonical State Mutation

AI Task RPC MUST NOT:

- change `shipments.status`
- change `purchase_orders.order_status`
- change `inventory_positions`
- write `inventory_movements`
- modify `cost_price`
- modify `distribution_rights`

---

### 4.2 Automatic Execution

AI MUST NOT:

- auto-dispatch shipment
- auto-deduct inventory
- auto-create purchase orders
- auto-send supplier communication
- auto-update pricing

---

### 4.3 Cross-Layer Coupling

Task actions MUST NOT:

- directly call shipment RPC
- directly call inventory RPC
- embed business execution logic

---

## 5. State Model (Task Layer Only)

Valid states:

- `draft`
- `awaiting_human_review`
- `approved`
- `sent` (future)
- `supplier_replied` (future)
- `resolved`

### Important

> These states represent **collaboration workflow**,  
> NOT business execution state.

---

## 6. State Transition Matrix (A8-6)

| From                      | To                         | Allowed |
|---------------------------|----------------------------|--------|
| awaiting_human_review     | approved                   | ✅     |
| awaiting_human_review     | draft                      | ✅     |
| approved                  | resolved                   | ✅     |
| any                       | any other                  | ❌     |

---

## 7. Human-Gated Enforcement

All task actions require:

- explicit user interaction (UI button)
- confirmation modal
- optional human input:
  - `human_decision`
  - `resolution`

No background execution is allowed.

---

## 8. UI Responsibility (Readdy)

Frontend MUST:

- clearly label task state as **AI Task State**
- avoid confusing users with business completion signals
- require confirmation before action
- reflect backend state (no fake optimistic override)
- never imply:
  - shipment completed
  - PO confirmed
  - inventory deducted

---

## 9. Backend Responsibility (Codex)

Backend MUST:

- enforce state transition constraints
- reject illegal transitions
- guarantee no canonical table mutation
- log `reviewer_id`
- maintain audit-safe fields:
  - `human_decision`
  - `resolution`
  - `updated_at`

---

## 10. Audit Principle

Every task action must be:

- attributable (`reviewer_id`)
- explainable (`human_decision` / `resolution`)
- reversible (via state control, not data mutation)

---

## 11. Future Extensions (Deferred)

The following are NOT part of v1:

- `sent` state execution
- supplier communication delivery
- message threading
- event timeline / audit log table
- notifications
- automatic workflow chaining

---

## 12. Core Guarantee

> AI Task Layer provides **decision support**,  
> NOT **decision execution**.

Human remains the final authority.
