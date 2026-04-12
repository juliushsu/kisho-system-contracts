AI Data Access Boundary v1

Status

Accepted

⸻

Purpose

This document defines the mandatory data access boundary for all AI features, AI agents, and automation flows.

Its purpose is to ensure that AI can provide useful organization-scoped analysis without exposing:
	•	other organizations’ data
	•	platform-only data
	•	hidden cost structures
	•	base-table level raw data

This policy protects:
	•	multi-tenant isolation
	•	cost confidentiality
	•	shipment / inventory boundaries
	•	prompt-injection resistance at the data layer

⸻

Core Principle

AI must not rely on trust alone.
AI must be technically constrained to organization-scoped data.

⸻

Primary Rule

All AI data access must go through a dedicated AI-safe access layer.

AI must NOT directly read:
	•	base tables
	•	cross-org views
	•	service-role unrestricted queries

AI must only read:
	•	AI-safe views
	•	controlled AI RPCs
	•	org-scoped datasets

⸻

Allowed AI Access Path

AI / Agent
   ↓
ai_query_role
   ↓
AI-safe views / controlled RPC
   ↓
org-scoped data only
``` id="l1ap46"

This is the only approved path for production AI data access.

---

## Forbidden AI Access Path

```text
AI / Agent
   ↓
service_role
   ↓
base tables / unrestricted query
``` id="x8drzn"

This path is forbidden.

---

## Role Policy

### Approved Role
- `ai_query_role`

### Forbidden for AI Runtime
- `service_role`
- any unrestricted DB role
- any role with direct base-table read access beyond AI-safe views

### Rule
If AI runtime is not using `ai_query_role`, it is out of policy.

---

## Org Scope Enforcement

AI access must always be scoped to the current organization.

### Required Rule
All AI-safe views and AI RPCs must enforce:

```text
org_id = current_org_id
``` id="e1mz7m"

This scope must be enforced in the data layer, not merely described in prompts.

---

## Fail-Closed Requirement

If organization context is missing, invalid, or cannot be resolved:

- AI must not receive fallback data
- AI must not default to platform or global scope
- AI-safe access must fail closed

### Required Behavior
No org context → no data

---

## AI-Safe View Rule

AI may only query views that are explicitly designed for AI use.

Examples:
- `v_ai_org_shipments`
- `v_ai_org_shipment_lines`
- `v_ai_org_shipment_allocations`
- `v_ai_org_inventory_summary`
- `v_ai_org_margin`
- `v_ai_org_sales_trend`

### Requirements for AI-safe views
1. built-in org filter
2. no cross-org leakage
3. no hidden joins to platform-only data
4. output limited to safe business meaning

---

## Controlled RPC Rule

AI may call only approved AI-facing RPCs.

Examples:
- `ai_list_shipments_v1`
- `ai_get_shipment_detail_v1`

### Requirements
- RPC must read only AI-safe views or equally safe sources
- RPC must not bypass org scope
- RPC must not expose raw base-table shape

---

## Base Table Access Rule

AI must not directly select from base tables such as:

- `shipments`
- `shipment_lines`
- `shipment_allocations`
- `inventory_positions`
- `inventory_movements`
- `org_variant_costs`
- any other multi-tenant base table

Even if technically possible in another context, it is forbidden for AI.

---

## Prompt Injection Defense Principle

Prompt injection must be defeated at the data layer.

### This means:
AI safety must not rely on:
- prompt wording alone
- polite refusal templates alone
- frontend-only guardrails

### Instead:
AI must be unable to retrieve out-of-scope data in the first place.

---

## Cross-Org Analytics Rule

AI features available to ordinary organization users must not expose:

- other org cost
- other org margin
- platform cost basis
- market average cost inferred from hidden data
- any benchmark derived from cross-org confidential data

### Exception
Platform-only governance analytics may exist separately, but must not be routed into org-facing AI features.

---

## Cost and Margin Rule

For any AI feature involving cost, margin, or profit:

- only org-scoped cost may be used
- only org-scoped revenue may be used
- only org-scoped shipment / inventory data may be used

AI must not infer or approximate:
- upstream hidden cost
- other organization cost range
- internal cost tier labels

---

## Safe Output Rule

AI may produce:
- organization-scoped summaries
- trend analysis
- internal recommendations
- shipment / inventory explanations
- margin insights based only on org data

AI must not produce:
- cross-org comparison
- hidden pricing inference
- supplier / platform cost hints
- "market average cost" statements derived from restricted data

---

## AI Middleware Rule

If middleware is used, it must reinforce this boundary, not replace it.

Middleware may:
- inject org context
- route AI calls to approved RPC
- reject obviously out-of-scope requests

Middleware must not:
- expand scope
- swap to `service_role`
- bypass AI-safe DB access rules

---

## Verification Rule

Any AI data access layer is not accepted unless it verifies:

1. `ai_query_role` exists
2. org resolver exists
3. fail-closed behavior works
4. AI-safe views exist
5. controlled AI RPC exists
6. AI role can read safe views
7. AI role cannot read base tables
8. org-scope filter prevents leakage

---

## Runtime Enforcement Rule

Deployment is not compliant unless the actual AI execution path uses the approved AI-safe role and views.

### Important
A correct SQL layer alone is insufficient if runtime still uses unrestricted credentials.

---

## Relationship to Other Decisions

This document must be interpreted together with:

- `org_margin_reporting_scope_v1.md`
- `distribution_pricing_cost_rbac_v1.md`
- `data_boundary_rules_v1.md`
- `rpc_write_policy_v1.md`
- `api_contract_versioning_v1.md`
- `incident_and_regression_policy_v1.md`

---

## Anti-Patterns (Forbidden)

### 1. AI using unrestricted service credentials
❌ AI runtime uses `service_role` to query business data

### 2. AI reading multi-tenant base tables directly
❌ AI bypasses safe views

### 3. Prompt-only protection
❌ "The prompt tells the model not to reveal other org data"

### 4. Cross-org benchmark leakage
❌ AI says "your cost is higher than average"

### 5. Hidden cost inference
❌ AI suggests negotiation based on upstream internal cost structure

---

## Summary

AI must be constrained by architecture, not by hope.

The system enforces:

- AI-safe role
- AI-safe views
- controlled AI RPCs
- mandatory org scope
- fail-closed behavior
- zero direct base-table access

This ensures that AI can remain useful while preserving multi-tenant confidentiality and commercial safety.
:::
	•	AI 只能走 ai_query_role
	•	AI 只能查 AI-safe views / RPC
	•	AI 不可直接查 base tables
	•	AI org scope 是 mandatory
	•	沒 org context 要 fail-closed
	
	•	AI 只能走 ai_query_role
	•	AI 只能查 AI-safe views / RPC
	•	AI 一律 org-scoped
	•	無 org context 必須 fail-closed
	•	不得用 service_role 直查 base tables
