# Readdy VER294 Procurement Phase 2 Acceptance

Status: Accepted with notes
Date: 2026-05-15
Scope: Read-only acceptance / governance backfill

本輪為只讀驗收與治理文件回填。

本文件不涉及 production code、不涉及 DB migration、不涉及 secrets / env、不涉及 LINE integration、不涉及 AI pricing automation、不涉及正式訂單寫入、不涉及真實扣庫存。

## 1. Readdy VER294 Summary

Source artifact inspected:

```text
[local Readdy artifact: 皇上吉祥-Ver294]
```

Safety handling:

1. The artifact contains `.env`; it was not opened, copied into docs, or referenced.
2. Build was run from a temporary copy at `/private/tmp/kisho-ver294-build`, excluding `.env`.
3. No production DB migration or runtime write action was executed during this acceptance pass.

VER294 adds a Procurement Phase 2 shell aligned to:

| Contract | Readdy VER294 alignment |
| --- | --- |
| `docs/procurement/PROCUREMENT_ADMIN_UI_SHELL_CONTRACT.md` | `/procurement-admin` shell, pages, disabled states, Phase 2 banner |
| `docs/procurement/PROCUREMENT_API_READ_MODEL_CONTRACT.md` | `src/types/procurement.ts` and `src/mocks/procurementAdmin.ts` mock DTOs |
| `docs/governance/READDY_PROCUREMENT_PHASE2_INSTRUCTIONS.md` | Mock/read-only copy, blocked high-risk actions, no LINE/pricing automation |

Acceptance result:

```text
PASS WITH NOTES
```

The note is specific: the Procurement Audit page performs a read-only `user_roles` lookup to gate owner-only debug access. This is a safe read-only check, but it is not purely mock-only.

## 2. Routes Added

Source: `src/router/config.tsx`

| Route | Page | Status |
| --- | --- | --- |
| `/procurement-admin` | Overview Dashboard | Present |
| `/procurement-admin/customers` | Customers list | Present |
| `/procurement-admin/customers/:customerId` | Customer detail | Present |
| `/procurement-admin/products` | Products catalog | Present |
| `/procurement-admin/quote-requests` | Quote Requests | Present |
| `/procurement-admin/quote-drafts` | Quote Drafts | Present |
| `/procurement-admin/orders` | Orders | Present |
| `/procurement-admin/pricing` | Pricing Governance | Present |
| `/procurement-admin/audit` | Audit / Debug | Present |

Platform launcher also includes a `B2B 採購管理` card linking to `/procurement-admin` with a `Phase 2` badge.

## 3. Contract Compliance Checklist

| Requirement | Result | Evidence |
| --- | --- | --- |
| `/procurement-admin` route shell exists | PASS | Router includes Procurement Admin layout and children |
| Overview Dashboard includes required widgets | PASS | Dashboard includes 今日詢價, 待業務確認訂單草稿, 待報價調貨品, 低毛利警示, 客戶常用採購清單 |
| Customers page exists | PASS | Customer list and detail pages exist |
| Customer detail includes locations, users, sales ownership, LINE status, preferences | PASS | Customer detail renders these sections from mock data |
| Products page includes categories `sake`, `tableware`, `meat`, `seafood`, `other` | PASS | Category tabs present |
| Products distinguish fixed stock vs supplier sourced | PASS | `supplyType` shown from mock DTO |
| Quote Requests page includes source channels and workflow | PASS | LINE/sales/platform/manual source channel vocabulary and workflow legend present |
| Quote Drafts show AI-assisted as mock and human approval required | PASS | `ai_assisted_mock`, approval workflow, disabled send quote |
| Orders page separates drafts and confirmed display states | PASS | Draft and confirmed tabs present |
| Orders do not create real orders or trigger fulfillment | PASS | Copy states no real orders, reserve inventory, or fulfillment |
| Pricing Governance read-only MVP | PASS | Read-only header, disabled Add controls, pricing automation not enabled |
| Audit / Debug owner-only | PASS WITH NOTES | Uses Supabase auth + `user_roles` read to gate role |
| Phase 2 safety banner present | PASS | `PhaseBanner` states mock/read-only and no real quote/order/inventory/LINE/pricing automation |
| Mock DTO contract represented | PASS | `src/types/procurement.ts` and `src/mocks/procurementAdmin.ts` align with DTO contract |

## 4. Mock-Only / Disabled Features

Observed mock-only or disabled behavior:

| Area | Behavior |
| --- | --- |
| Global Procurement pages | Persistent banner: `Phase 2 Shell — mock / read-only mode` |
| Dashboard | Uses `PROCUREMENT_DASHBOARD_MOCK`; cards navigate only |
| Customers | Uses `PROCUREMENT_CUSTOMERS_MOCK`; search/filter disabled |
| Customer detail | Uses mock customer context; reassignment and LINE integration copy indicate disabled |
| Products | Uses `PROCUREMENT_PRODUCTS_MOCK`; Add Product disabled |
| Quote Requests | Uses mock requests; Create Draft disabled; LINE integration not active |
| Quote Drafts | Uses mock drafts; Send Quote disabled; AI-assisted is mock label |
| Orders | Uses mock order drafts and mock/read-only confirmed orders |
| Pricing Governance | Uses mock price books/rules/guardrails; Add buttons disabled |
| Audit / Debug | Shows safe aliases/placeholders only when owner gate passes |

VER294 correctly avoids UI language such as:

1. Real order completed.
2. Formal quote activated.
3. Inventory deducted.
4. LINE fully connected.
5. AI automatic pricing enabled.

## 5. Risk Review

### 5.1 Procurement Phase 2 Scope

No high-risk Procurement Phase 2 behavior was found.

Specific checks:

| Risk item | Finding |
| --- | --- |
| Production DB write from `/procurement-admin` | Not found |
| Procurement Edge Function implementation | Not found |
| LINE API integration from `/procurement-admin` | Not found |
| AI pricing automation | Not found |
| Real order submit/confirm | Not found |
| Inventory reserve/allocation/deduction from Procurement shell | Not found |
| Pricing rule create/update/delete from Procurement shell | Not found |
| Supplier procurement execution | Not found |

### 5.2 Artifact-Wide Legacy Surfaces

The VER294 artifact still contains legacy/non-Procurement surfaces with writes and an Edge Function, including existing Sake/Admin services and `supabase/functions/create-store-user/index.ts`.

These were not introduced as Procurement Phase 2 shell behavior and were not executed during this acceptance pass. They should remain out of scope for Procurement Phase 2 acceptance, but future release review should avoid confusing artifact-wide legacy write capability with the new Procurement shell.

## 6. Audit Page `user_roles` Read-Only Note

Source: `src/pages/procurement-admin/audit/page.tsx`

Observed behavior:

1. Calls `supabase.auth.getUser()`.
2. Reads `user_roles` with:

```text
from('user_roles').select('role').eq('user_id', user.id).maybeSingle()
```

3. Allows debug content only when `role === 'admin'`.
4. Displays safe debug values only: route, mock API base alias, org placeholder, customer placeholder, request trace ID, mock fixture name, feature flags, data mode, build version.
5. Explicitly lists forbidden debug outputs such as tokens, API keys, DB URLs, LINE secrets, `.env` values, and supplier confidential cost.

Judgment:

```text
PASS WITH NOTES
```

The `user_roles` query is read-only and supports owner-only access, so it does not violate the no-write/no-secret rule. However, it is not pure mock-only. If Phase 2 must be strictly mock-only in some deployment context, replace the live role read with a mock owner gate or an already-approved safe read model.

## 7. Build Result

Build method:

```text
rsync source to /private/tmp/kisho-ver294-build excluding .env, node_modules, dist
npm install
npm run build
```

Result:

```text
PASS
```

Observed output:

```text
vite v7.3.3 building client environment for production...
317 modules transformed.
built in 2.78s
```

Notes:

1. Build output was generated in `/private/tmp/kisho-ver294-build/out`.
2. The downloaded Readdy artifact was not modified.
3. `.env` was excluded from the build copy.

## 8. CTO Recommendation

Recommendation:

```text
Approve VER294 as PASS WITH NOTES for Procurement Phase 2 shell review.
```

Rationale:

1. The `/procurement-admin` route tree and page set match the Phase 2 shell contract.
2. Mock/read-only signals are consistently present.
3. High-risk actions are disabled or marked as requiring backend contracts.
4. Pricing Governance is read-only.
5. Build passes in a no-env temporary copy.
6. Audit page role lookup is read-only, but should be explicitly reviewed as a Phase 2 exception to pure mock-only behavior.

## 9. Next Phase Gating

Do not proceed beyond Phase 2 until CTO approves the next scoped implementation plan.

Before Phase 3 or any backend integration:

1. Decide whether Audit page may continue using live `user_roles` read in Phase 2 deployments.
2. Define approved safe backend read models for procurement customers, products, quote requests, quote drafts, orders, and pricing governance.
3. Confirm no production writes are introduced for quote drafts, orders, pricing rules, inventory allocation, or supplier procurement.
4. Confirm customer context and LINE identity linkage remain inactive until a separate LINE integration phase.
5. Confirm AI pricing remains disabled until pricing guardrails, approval workflow, and audit are implemented.
6. Add explicit release notes distinguishing Procurement Phase 2 shell from legacy Sake/Admin write-capable surfaces already present in the artifact.

## 10. Final Acceptance

Final result:

```text
PASS WITH NOTES
```

Blocking issues:

```text
None for Procurement Phase 2 shell.
```

Non-blocking notes:

1. Audit page uses safe read-only `user_roles` lookup and is not pure mock-only.
2. Artifact-wide legacy Sake/Admin write-capable surfaces and Edge Function remain present but are outside Procurement Phase 2 scope.
