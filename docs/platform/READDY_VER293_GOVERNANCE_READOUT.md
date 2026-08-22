# Readdy Ver293 Governance Readout

Status: Proposed
Date: 2026-05-15
Scope: Documentation / governance only

本輪為 documentation/governance only。

本文件不涉及 production code、不涉及 DB migration、不涉及 secrets、不涉及 Readdy UI 修改。後續需由 CTO review 後才可進入 implementation phase。

## 1. Source Artifact

本輪只讀盤點來源：

```text
[local Readdy artifact: 皇上吉祥-Ver293]
```

安全限制：

1. 該 artifact 內含 `.env`，本輪未讀取、未複製、未引用 `.env` 內容。
2. 本輪未修改 Readdy Ver293 artifact。
3. 本輪未執行 npm install、dev server、build、DB migration 或 production API call。
4. 本文件僅記錄 route/navigation governance observation。

## 2. Package Snapshot

Ver293 是 React / Vite 專案。

觀察到的主要 dependency：

| Area | Package |
| --- | --- |
| Frontend | React 19, React DOM 19, React Router DOM 7 |
| Build | Vite 7, TypeScript 5.8, Tailwind CSS 3 |
| Data / SDK | Supabase JS 2.57, Firebase 12 |
| Charts | Chart.js, react-chartjs-2, Recharts |
| i18n | i18next, react-i18next |

此 snapshot 不代表 production readiness，也不代表任何 package 需要升級或變更。

## 3. Route Inventory

來源：`src/router/config.tsx`

| Route | Ver293 狀態 | Governance note |
| --- | --- | --- |
| `/` | Present | Public site |
| `/about` | Present | Public site |
| `/products` | Present | Public product browsing |
| `/contact` | Present | Public site |
| `/admin/login` | Present | Shared login remains under old admin path |
| `/platform` | Present | Platform launcher exists |
| `/sake-admin` | Present | New Sake Admin shell exists |
| `/meat-admin` | Present | Meat Admin placeholder exists |
| `/agent-workspace` | Present | Agent Workspace shell exists |
| `/project-governance` | Present | Project Governance shell exists |
| `/admin` | Present | Backward compatibility shell exists |
| `/store/:slug` | Present | Sake merchant storefront |
| `/store/:slug/catalog` | Present | Sake merchant storefront catalog |
| `/store/:slug/p/:variant_id` | Present | Sake merchant product detail |
| `/procurement-admin` | Not present | Required by this governance package before B2B implementation |
| `/b2b` | Not present | Required by this governance package before customer procurement implementation |
| `/platform/ai-agents` | Not present | Ver293 currently uses `/agent-workspace`; future governance can keep workspace separate or add platform registry |
| `/platform/line-bot` | Not present | Required before LINE Bot governance UI implementation |

## 4. Navigation Inventory

來源：`src/config/navigation/*`

| Navigation config | Ver293 狀態 | Governance note |
| --- | --- | --- |
| `platformNavConfig.ts` | Present | Launcher includes Sake, Meat, Agent Workspace, Project Governance |
| `sakeAdminNavConfig.ts` | Present | Centralized Sake Admin sidebar, already points to `/sake-admin/*` |
| `meatAdminNavConfig.ts` | Present | Meat sidebar is placeholder / coming soon |
| `agentWorkspaceNavConfig.ts` | Present | Agent workspace marked Beta |
| `projectGovernanceNavConfig.ts` | Present | Governance nav items share `/project-governance` placeholder |
| Procurement navigation | Not present | Needs future `/procurement-admin` nav contract |
| B2B customer navigation | Not present | Needs future `/b2b` customer IA contract |
| LINE Bot governance navigation | Not present | Needs future platform/LINE governance contract |

## 5. Alignment With This Governance Package

| Governance item | Ver293 alignment | Notes |
| --- | --- | --- |
| Stop adding new product lines to old `/admin` | Partial | Ver293 has new `/sake-admin` and `/meat-admin`, while `/admin` remains backward compatibility |
| `/platform` as launcher | Partial | Ver293 has platform launcher, but this package expands it into 大皇居 platform governance |
| `/sake-admin` for 酒與酒機 | Strong | Ver293 already routes Sake Admin pages under `/sake-admin` |
| `/meat-admin` for 熟成肉 | Partial | Placeholder exists, routes/nav are coming soon |
| `/procurement-admin` for B2B management | Missing | Required before procurement implementation |
| `/b2b` for customer procurement | Missing | Required before customer procurement implementation |
| AI Agent as assistive layer | Partial | Agent workspace exists; approval and data boundary need governance binding |
| LINE Bot as information transformation layer | Missing | No dedicated LINE Bot governance route observed |
| Project Governance | Partial | Shell exists; source-of-truth content should bind to contracts repo docs |

## 6. Ver293 Gap List

These are planning gaps only; this file does not authorize implementation.

| Gap | Proposed source of truth |
| --- | --- |
| 大皇居 `/platform` needs group-level governance definition | `docs/platform/DAIKOJU_PLATFORM_ARCHITECTURE.md` |
| Route namespace for procurement and B2B not present | `docs/platform/BACKOFFICE_ENTRYPOINT_GOVERNANCE.md` |
| Procurement roadmap not represented in Ver293 | `docs/procurement/PROCUREMENT_PLATFORM_ROADMAP.md` |
| AI LINE Bot commerce flow not represented in Ver293 | `docs/procurement/AI_LINE_BOT_COMMERCE_FLOW.md` |
| Shared module boundaries not encoded in Ver293 | `docs/platform/DOMAIN_MODULE_BOUNDARY.md` |
| Ver293 Project Governance page currently placeholder-style | `docs/governance/GITHUB_BRANCH_AND_DOCS_CLEANUP_PLAN.md` and project metadata contracts |

## 7. Recommended Next Readdy Instruction

After CTO review, Readdy Ver293 follow-up should be scoped as a separate implementation phase.

Recommended instruction boundary:

1. Do not modify DB schema.
2. Do not read or expose `.env`.
3. Add only route/navigation shells for `/procurement-admin` and `/b2b` if approved.
4. Keep tableware as a procurement category, not `/tableware-admin`.
5. Treat LINE Bot as draft/confirmation workflow, not automatic order execution.
6. Bind Project Governance content to reviewed contracts docs before adding live integrations.
