# Customer Context Governance

Status: Proposed
Date: 2026-05-15
Scope: Documentation / governance / architecture only

本輪為 canonical contracts phase only。

本文件不涉及 production code、不涉及 DB migration、不涉及 secrets / env、不涉及 Readdy UI 修改、不產生 API route、不實作 Edge Function。後續需由 CTO review 後才可進入 implementation phase。

## 1. Purpose

This document defines `customer_context` as the shared core context used by LINE Bot, Procurement, Sales, and AI Agent.

`customer_context` is not a single required database table in this phase. It is a canonical read model concept that gathers safe, scoped customer identity and commercial context for decision support.

## 2. Customer Identity

Customer identity is the canonical representation of a buying organization.

Customer identity may represent:

1. A single restaurant.
2. A multi-location restaurant group.
3. A distributor.
4. A corporate buyer.
5. A hotel, bar, catering group, or retail account.
6. A future cross-business customer that buys sake, aged meat, tableware, and sourcing-only goods.

Identity governance:

| Rule | Decision |
| --- | --- |
| Canonical owner | Platform Core |
| Duplicate prevention | Prefer merge/review workflow, not automatic AI merge |
| Customer code | Human-readable only; not canonical ID |
| Historical records | Quotes/orders retain original customer reference |
| Cross-domain use | Allowed only through scoped access |

## 3. Multi-Location Restaurant Groups

Restaurant groups may have multiple locations with different procurement behavior.

Canonical structure:

```text
customer
-> customer_locations
   -> delivery preferences
   -> location-specific buyer contacts
   -> location-specific sales ownership when needed
```

Governance rules:

1. Headquarters may own billing and approval.
2. Branches may own receiving and recurring purchase preferences.
3. A quote or order should identify both customer and relevant location when location matters.
4. LINE identity may be linked to headquarters, branch, or individual buyer context.
5. AI must not assume all branches share the same price, preference, or approval authority.

## 4. Customer Account Hierarchy

Customer account hierarchy defines who can see and approve procurement activity.

Recommended hierarchy:

| Level | Meaning |
| --- | --- |
| Customer group | Legal or commercial buying group |
| Location | Restaurant branch, warehouse, billing site |
| User | Human buyer, manager, chef, finance contact, approver |
| Membership | User-to-customer or user-to-location access relationship |
| Approval scope | What the user may request, confirm, or view |

Customer users may have roles such as:

| Role | Scope |
| --- | --- |
| `customer_owner` | Manage customer account and users |
| `customer_buyer` | Create requests and confirm orders within scope |
| `customer_approver` | Approve quotes/orders |
| `customer_viewer` | Read-only |
| `location_buyer` | Buy for assigned locations only |

## 5. LINE Identity Linkage

LINE identity linkage connects a LINE user or group conversation to `customer_context`.

Linkage states:

| State | Meaning | AI behavior |
| --- | --- | --- |
| `unlinked` | LINE identity not mapped to a customer | Ask clarifying questions or route to sales |
| `candidate_match` | Possible customer match exists | AI may suggest match, human/customer confirmation required |
| `linked_user` | LINE user linked to customer user | AI may use scoped customer context |
| `linked_group` | LINE group linked to customer or location | AI may use group-scoped context |
| `suspended` | Link is disabled or disputed | Do not use context until resolved |

Rules:

1. AI may not create final identity linkage without explicit confirmation.
2. LINE group membership can change; group identity should not automatically grant every participant account access.
3. Sensitive pricing and margin data must not be sent into LINE by default.
4. LINE message history should be summarized into scoped context rather than used as unrestricted memory.

## 6. Sales Ownership

Sales ownership determines who is responsible for relationship, quote review, follow-up, and final commercial confirmation.

Ownership scope may apply to:

1. Entire customer.
2. Customer location.
3. Product line.
4. Product category.
5. Temporary opportunity or quote.

Canonical relationship:

```text
customer_context
-> primary_sales_rep
-> secondary_sales_rep
-> escalation_owner
-> product_line_owner
```

Rules:

1. Every high-value quote should have an accountable sales owner.
2. AI follow-up recommendations route to the current owner.
3. Sales ownership changes must not rewrite historical quote/order ownership.
4. Temporary coverage should have effective dates.

## 7. Reassignment Rules

Customer reassignment is a governed action.

Reassignment triggers:

1. Sales territory change.
2. Staff departure or role change.
3. Customer request.
4. Account escalation.
5. Product-line expansion.

Required audit:

| Field | Purpose |
| --- | --- |
| Previous owner | Historical accountability |
| New owner | Current accountability |
| Effective date | Prevent retroactive ambiguity |
| Reason | Governance trace |
| Approved by | Manager or platform admin |

AI may suggest reassignment candidates based on workload or response history, but reassignment requires human approval.

## 8. CRM Context Sharing

CRM context sharing allows Sales, Procurement, LINE Bot, and AI Agent to use shared customer signals without leaking sensitive data.

Allowed shared context:

1. Customer identity and locations.
2. Assigned sales owner.
3. Safe contact preference.
4. Product categories of interest.
5. Procurement list summaries.
6. Quote/order status summaries.
7. Follow-up reminders.

Restricted context:

1. Supplier cost.
2. Internal margin.
3. Other customers' prices.
4. Private sales notes marked restricted.
5. Secrets, tokens, credentials, `.env` values.

## 9. AI Memory Boundaries

AI memory must be scoped and reviewable.

AI may remember:

| Memory | Scope |
| --- | --- |
| Preferred categories | Customer or location |
| Usual quantities | Customer/location/list |
| Delivery preferences | Location |
| Communication preferences | Customer user or LINE thread |
| Prior unresolved questions | Quote request or conversation |

AI must not remember or infer:

1. Another customer's pricing.
2. Hidden cost or margin unless the user has internal permission.
3. Private sales notes outside the current scope.
4. Identity linkage from unconfirmed LINE users.
5. Secrets or credentials.

Memory updates should be traceable to source events and be reversible or archivable.

## 10. Customer Tags / Segmentation

Customer tags and segments help routing, pricing review, and recommendations.

Examples:

| Tag type | Examples | Governance |
| --- | --- | --- |
| Business type | restaurant, bar, hotel, distributor | Safe if customer-scoped |
| Category interest | sake, aged_meat, tableware | Safe if customer-scoped |
| Commercial | high_volume, strategic_account | Internal-only |
| Risk | overdue_payment, requires_manager_review | Internal-only |
| Operational | needs_cold_chain, weekend_delivery | Role-scoped |

AI may suggest tags, but internal risk/commercial tags require human approval before becoming canonical.

## 11. Procurement Preference Memory

Procurement preference memory captures customer habits that improve quote and reorder workflows.

Allowed preference memory:

1. Usual products or categories.
2. Preferred units and pack sizes.
3. Usual order quantities.
4. Preferred delivery days or locations.
5. Substitution tolerance.
6. Seasonal buying patterns.
7. Quote language or contact preferences.

Governance:

1. Preference memory is customer-owned context.
2. It must not leak across customers.
3. It should feed `procurement_lists`, quote request suggestions, and follow-up recommendations.
4. AI recommendations should show why a preference was suggested when possible.
5. Customer-visible preferences should be editable or dismissible.

## 12. `customer_context` Canonical Read Model

`customer_context` is the shared read model for LINE Bot / Procurement / Sales / AI Agent.

Conceptual fields:

| Field | Meaning |
| --- | --- |
| `customer_id` | Canonical customer UUID |
| `customer_display_name` | Safe display name |
| `customer_status` | active, archived, review_required |
| `locations` | Scoped customer locations |
| `users` | Scoped customer users and roles |
| `line_links` | Confirmed LINE linkage summaries |
| `sales_owners` | Current sales ownership by scope |
| `segments` | Safe and internal tags by permission |
| `procurement_preferences` | Customer/location/list preference summaries |
| `active_quote_requests` | Current open requests |
| `active_quote_drafts` | Internal only |
| `active_quotes` | Customer-visible only if issued |
| `open_order_drafts` | Draft order state by permission |
| `recent_orders_summary` | Summary, not full unrestricted history |
| `ai_memory_summary` | Scoped, reviewable memory |
| `risk_flags` | Internal-only risk indicators |

Access rules:

| Consumer | Allowed context |
| --- | --- |
| LINE Bot | Confirmed customer/user/thread scope, no internal margin/cost |
| Procurement Admin | Internal procurement context by role |
| Sales | Assigned customers and governed support scopes |
| AI Agent | AI-safe context only, no base-table unrestricted access |
| Customer `/b2b` | Own customer-visible context only |

## 13. Implementation Gate

Before implementation:

1. Confirm customer identity merge and duplicate policy.
2. Confirm LINE linkage approval flow.
3. Confirm sales reassignment authorization.
4. Confirm AI memory storage, review, and deletion policy.
5. Confirm customer-visible vs internal-only context fields.
