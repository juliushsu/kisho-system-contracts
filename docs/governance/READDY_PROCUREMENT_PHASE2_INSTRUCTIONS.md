# Readdy Procurement Phase 2 Instructions

Status: Proposed
Date: 2026-05-15
Scope: Readdy construction instructions for `/procurement-admin` shell

本輪仍以治理與實作前契約為主。

本文件不授權 production code、不授權 DB migration、不授權 secrets / env access、不授權 LINE integration、不授權 AI pricing automation、不授權正式訂單寫入、不授權真實扣庫存。

## 1. Mission

Build only the `/procurement-admin` shell for 大皇居 B2B procurement management.

The result should feel like an internal backoffice skeleton that is ready for review, but it must not behave like a live commerce system.

Primary contracts:

| Contract | Use |
| --- | --- |
| `docs/procurement/PROCUREMENT_ADMIN_UI_SHELL_CONTRACT.md` | Page structure and UI behavior |
| `docs/procurement/PROCUREMENT_API_READ_MODEL_CONTRACT.md` | Mock/read-only DTO shapes |
| `docs/procurement/PROCUREMENT_CANONICAL_DATA_CONTRACT.md` | Entity vocabulary |
| `docs/platform/CUSTOMER_CONTEXT_GOVERNANCE.md` | Customer context vocabulary |
| `docs/procurement/PRICING_GOVERNANCE_CONTRACT.md` | Pricing restrictions |
| `docs/procurement/AI_COMMERCE_EVENT_CONTRACT.md` | Event and approval language |

## 2. Allowed Work

Readdy may implement:

1. `/procurement-admin` route shell.
2. Sidebar/navigation for procurement admin.
3. Overview Dashboard page.
4. Customers list and detail shell.
5. Products catalog shell.
6. Quote Requests shell.
7. Quote Drafts shell.
8. Orders shell.
9. Pricing Governance read-only shell.
10. Audit / Debug owner-only shell.
11. Local mock fixtures matching `PROCUREMENT_API_READ_MODEL_CONTRACT.md`.
12. Empty/loading/error states.
13. Disabled high-risk buttons with clear explanatory copy.

## 3. Forbidden Work

Readdy must not:

1. Connect production DB.
2. Add or run migrations.
3. Read, copy, or expose `.env`.
4. Add pricing automation.
5. Connect LINE.
6. Create real order writes.
7. Send real quotes.
8. Activate price books or customer price rules.
9. Reserve, allocate, or deduct inventory.
10. Trigger supplier procurement.
11. Implement Edge Functions.
12. Generate production API routes.
13. Show secrets in debug drawer.

## 4. Data Source Rules

Allowed data sources:

| Source | Allowed? | Notes |
| --- | --- | --- |
| Local mock fixtures | Yes | Preferred for Phase 2 |
| Existing safe read model | Yes, only if already available and non-production |
| Production Supabase | No | Not allowed in Phase 2 |
| LINE webhook/API | No | Not allowed in Phase 2 |
| AI pricing service | No | Not allowed in Phase 2 |
| Supplier live API | No | Not allowed in Phase 2 |

Every page using mock data should display a Phase 2 shell marker.

Recommended marker:

```text
Phase 2 Shell - mock/read-only data. No live quote, order, inventory, LINE, or pricing automation is active.
```

## 5. Required Pages

### 5.1 Overview Dashboard

Show cards:

1. 今日詢價.
2. 待業務確認訂單草稿.
3. 待報價調貨品.
4. 低毛利警示.
5. 客戶常用採購清單.

Cards may link to shell pages. They must not execute live action.

### 5.2 Customers

Implement:

1. Customer list.
2. Customer detail.
3. Customer locations.
4. Assigned sales rep.
5. LINE linkage status.
6. Procurement preferences.

Do not implement real LINE linking, customer merge, or sales reassignment.

### 5.3 Products

Implement:

1. Product catalog.
2. Categories: `sake`, `tableware`, `meat`, `seafood`, `other`.
3. Fixed stock item vs supplier-sourced item.
4. Active/inactive/archive display state.

Do not implement real catalog edits or supplier availability sync.

### 5.4 Quote Requests

Implement:

1. Customer inquiry list.
2. Requested items summary.
3. Source channel: LINE / sales / platform / manual.
4. Status workflow.

Do not connect LINE or run live AI product search.

### 5.5 Quote Drafts

Implement:

1. AI-assisted mock/source label.
2. Human approval required labels.
3. Price/margin fields visible as read-only/mock.
4. Approval state.

Do not auto-finalize pricing or send customer-facing quote.

### 5.6 Orders

Implement:

1. Order drafts tab.
2. Confirmed orders tab as mock/read-only if needed.
3. Source channel.
4. Sales attribution.
5. Fulfillment status badges.

Do not create confirmed orders, reserve inventory, deduct inventory, or trigger shipment.

### 5.7 Pricing Governance

Implement read-only MVP:

1. Price book summaries.
2. Customer price rule summaries.
3. Margin/volatility flags.
4. Quote expiration reminders.
5. AI pricing assistant guardrail notes.

Do not create, update, delete, or activate pricing rules.

### 5.8 Audit / Debug

Implement owner-only debug drawer or page.

May show:

1. API base alias.
2. Org ID.
3. Customer ID.
4. Request trace.
5. Mock fixture name.
6. Feature flag names if non-secret.

Must not show:

1. Tokens.
2. API keys.
3. `.env`.
4. Database URLs.
5. Supabase service role keys.
6. LINE channel secret.
7. LINE access token.
8. Raw sensitive webhook payload.

## 6. Required Risk Labels

Use explicit labels for high-risk features:

| Feature | Required label |
| --- | --- |
| Create order | `需後端契約完成` |
| Confirm order | `需後端契約完成` |
| Send quote | `需後端契約完成` |
| Update price | `Phase 2 read-only` |
| Link LINE | `LINE integration not active` |
| Allocate inventory | `Inventory action blocked in Phase 2` |
| AI pricing | `AI pricing automation not active` |

## 7. Copy Rules

Do say:

1. "Mock data".
2. "Read-only".
3. "Requires sales review".
4. "Requires pricing approval".
5. "Requires backend contract".
6. "No live action".

Do not say:

1. "已完成真實下單".
2. "正式報價已生效".
3. "庫存已扣除".
4. "LINE 已串接".
5. "AI 已自動定價".
6. "供應商已採購".

## 8. Recommended Build Order

Build in this order:

1. Route shell and sidebar.
2. Mock DTO fixtures.
3. Overview Dashboard.
4. Customers.
5. Products.
6. Quote Requests.
7. Quote Drafts.
8. Orders.
9. Pricing Governance.
10. Audit / Debug.
11. Final pass for disabled high-risk actions and safety copy.

## 9. Acceptance Checklist

Readdy Phase 2 is acceptable when:

1. `/procurement-admin` opens and renders shell navigation.
2. All required pages render with mock/read-only data.
3. No production DB connection is required.
4. No `.env` value is read or displayed.
5. No LINE connection is active.
6. No pricing automation is active.
7. No real order can be created or confirmed.
8. No inventory action can execute.
9. Pricing Governance is read-only.
10. Debug drawer is owner-only and secret-free.

## 10. Handoff Note

When Phase 2 UI is complete, the next review should decide whether to proceed to:

1. Procurement Admin Skeleton with approved safe backend read models.
2. Customer B2B portal shell.
3. LINE commerce integration design.

Do not proceed to those without separate CTO review and implementation approval.
