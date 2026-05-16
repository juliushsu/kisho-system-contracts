# Procurement RLS And Audit Plan

Status: Proposed
Date: 2026-05-16
Scope: Documentation / architecture / migration draft only

本輪為 Phase 3A backend implementation design only。

本文件不涉及 production code、不執行 DB migration、不碰 secrets / env、不接 LINE、不做 AI pricing automation、不建立真實訂單寫入、不改 Readdy UI、不建立 API route、不實作 Edge Function。

## 1. Tenant Isolation Model

Procurement data must be isolated by organization/tenant while supporting platform owner governance.

Recommended scope fields:

| Field | Usage |
| --- | --- |
| `organization_id` | Primary tenant boundary for procurement-owned records |
| `customer_id` | Customer boundary inside organization |
| `customer_location_id` | Branch/location boundary |
| `assigned_sales_rep_id` | Sales scoped access |
| `created_by_user_id` | Audit and creator scope |
| `archived_at` | Soft archive visibility |

Default rule: no user sees a row unless an RLS policy grants access by owner/admin, assigned sales scope, procurement role, or customer account membership.

## 2. `organization_id` Rules

1. All tenant-owned procurement tables require `organization_id`.
2. `organization_id` is immutable after creation except controlled admin repair.
3. Cross-organization reads are owner/admin only.
4. AI agent queries must include organization scope.
5. Service-role jobs must still write explicit `organization_id` and audit events.

## 3. Customer Account Access

Customer users:

1. Can see only their own customer account.
2. Can see only assigned customer locations.
3. Cannot see other customer quote requests, quote drafts, quotes, order drafts, orders, procurement lists, or pricing rules.
4. Cannot see supplier costs, internal margin, margin thresholds, or internal approval notes.
5. Cannot directly update pricing rules or confirm orders without the approved confirmation workflow.

Hard rule:

```text
customer users 不可看其他 customer
```

## 4. Sales Rep Scoped Access

Sales reps:

1. Can see assigned customers only.
2. Assignment may be by customer, location, product line, or temporary coverage.
3. Cannot see unassigned customers unless owner/admin grants support scope.
4. Cannot override pricing thresholds without approval.
5. Cannot confirm orders without audit.

Hard rule:

```text
sales reps 只能看自己 assigned customers，除非 owner/admin
```

## 5. Owner / Admin Access

Owner/admin access:

1. Can view organization-wide procurement data.
2. Can manage governance and support workflows.
3. Can approve or delegate high-risk actions if policy allows.
4. Must still produce audit events for approval, reassignment, pricing, and order confirmation.
5. Must not use UI to bypass service-layer validation.

## 6. Customer Portal Access

Future `/b2b` portal access:

| Data | Customer visibility |
| --- | --- |
| Customer identity | Own customer only |
| Locations | Own assigned locations |
| Procurement lists | Own customer/location scope |
| Quote requests | Own requests |
| Quote drafts | Not visible unless issued as customer quote |
| Orders | Own confirmed/read-only order state |
| Pricing | Customer-facing price only |
| Internal margin/cost | Never |

## 7. Quote Visibility Rules

| Record | Internal visibility | Customer visibility |
| --- | --- | --- |
| `quote_requests` | procurement/admin + assigned sales | own submitted requests |
| `quote_drafts` | procurement/admin + assigned sales | not visible by default |
| approved customer quote | procurement/admin + assigned sales | visible to customer when issued |
| pricing review notes | internal only | never |

## 8. Order Visibility Rules

| Record | Internal visibility | Customer visibility |
| --- | --- | --- |
| `order_drafts` | procurement/admin + assigned sales | own draft only if customer-facing flow enabled |
| `orders` | procurement/admin + assigned sales | own confirmed orders |
| fulfillment status | internal + customer-safe summary | customer-safe summary only |
| inventory allocation detail | internal fulfillment | not customer-visible by default |

Order confirmation must create an audit event.

## 9. Pricing Visibility Rules

Pricing visibility:

1. Price books are internal by default.
2. Customer price rules are visible internally; customer sees only resulting approved price.
3. Supplier quote and cost are internal-only.
4. Internal margin is internal-only.
5. Pricing rules must not be written directly by frontend UI.

Hard rule:

```text
pricing rules 不得由前端直接寫入
```

## 10. AI Agent Access Rules

AI agent access:

1. Must use AI-safe read models only.
2. Must include organization and customer scope.
3. Must not read base tables directly unless separately approved.
4. Must not see unrelated customer data.
5. Must not see hidden pricing/cost unless actor has internal permission and AI-safe view permits it.
6. Must not bypass human approval gate.

Hard rule:

```text
AI agent 不得繞過 human approval gate
```

## 11. Audit Event Requirements

Audit events required for:

1. Customer create/archive/merge/reassignment.
2. Sales assignment create/update/archive.
3. Quote request create/status change.
4. Quote draft create/update/submit for approval.
5. Pricing review and approval.
6. Customer-facing quote issuance.
7. Order draft create/update.
8. Customer confirmation.
9. Order confirmation.
10. Supplier procurement required mark.
11. Inventory allocation required mark.
12. AI draft creation or recommendation.
13. Service-role performed operation.

Minimum audit columns:

| Column | Purpose |
| --- | --- |
| `event_id` | Immutable audit ID |
| `organization_id` | Tenant scope |
| `actor_user_id` | User actor when available |
| `actor_type` | user, system, ai_agent, service_role |
| `event_type` | Canonical event name |
| `subject_type` | Table/entity type |
| `subject_id` | Entity ID |
| `customer_id` | Customer scope when applicable |
| `risk_class` | low, medium, high_pricing, high_commitment |
| `metadata` | Non-secret structured details |
| `created_at` | Timestamp |

## 12. Forbidden Direct Writes

Forbidden direct writes:

1. Frontend direct insert/update/delete to pricing rules.
2. Frontend direct order confirmation.
3. Frontend direct inventory deduction.
4. AI direct price update.
5. AI direct order confirmation.
6. AI direct supplier commitment.
7. Service role writes without audit.
8. Customer user writes to another customer's records.

## 13. Service Role Boundaries

Service role use must be rare and isolated.

Allowed future uses:

1. Controlled Edge Function webhook ingestion.
2. Background sync jobs.
3. Admin repair tools.
4. Audit export.

Requirements:

1. Never expose service role to frontend.
2. Every service role write includes audit.
3. Service role functions validate actor and tenant scope.
4. Secrets remain outside GitHub docs and UI.
5. Staging-first testing before production.

## 14. RLS Helper Function Candidates

Candidate helper functions:

| Function | Purpose |
| --- | --- |
| `current_app_user_id()` | Resolve current authenticated user |
| `is_platform_owner(user_id)` | Platform owner/admin access |
| `is_procurement_admin(user_id, organization_id)` | Procurement admin access |
| `is_sales_rep_for_customer(user_id, customer_id)` | Sales scoped customer access |
| `is_customer_user_for_customer(user_id, customer_id)` | Customer portal customer access |
| `can_view_quote_request(user_id, quote_request_id)` | Quote request visibility |
| `can_view_quote_draft(user_id, quote_draft_id)` | Internal quote draft visibility |
| `can_view_order(user_id, order_id)` | Order visibility |
| `can_view_pricing(user_id, organization_id)` | Pricing governance visibility |
| `can_ai_read_customer_context(agent_id, customer_id)` | AI-safe customer context access |

Helper functions must be stable, audited where appropriate, and reviewed for security-definer risk.

## 15. Testing Strategy

Testing must prove denial as well as access.

Required tests:

1. Customer A cannot read Customer B.
2. Customer location buyer cannot read another location if not assigned.
3. Sales rep cannot read unassigned customer.
4. Sales rep can read assigned customer.
5. Owner/admin can read organization data.
6. Customer cannot see supplier cost, margin, or internal price rules.
7. Frontend cannot directly write price rules.
8. AI role cannot confirm order.
9. Order confirmation writes audit event.
10. Service role path writes audit event.
11. Archived records are hidden by default where appropriate.
12. RLS policies hold in staging with seeded multi-tenant data.

Phase 3B should not proceed until these tests are represented in the migration implementation plan.
