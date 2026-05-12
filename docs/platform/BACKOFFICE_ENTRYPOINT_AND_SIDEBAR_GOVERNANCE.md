# Backoffice Entrypoint And Sidebar Governance

Status: Proposed
Date: 2026-05-12
Scope: Frontend information architecture, navigation governance, RBAC visibility contract

This document defines the next backoffice entrypoint model for 皇上吉祥. It is planning-only and does not authorize production UI rewrites, database changes, migrations, or secret handling.

## 1. Current Route Inventory

Source: `contracts/readdy_ver289_frontend_alignment_v1.md`

### Public Site Routes

| Route | Current product line | Notes |
| --- | --- | --- |
| `/` | Platform / public | Marketing or public landing entry. |
| `/about` | Platform / public | Public content. |
| `/products` | Sake / public commerce | Public product browsing. |
| `/contact` | Platform / public | Public contact. |

### Public Storefront Routes

| Route | Current product line | Notes |
| --- | --- | --- |
| `/store/:slug` | Sake storefront | Merchant storefront. |
| `/store/:slug/catalog` | Sake storefront | Merchant catalog. |
| `/store/:slug/p/:variant_id` | Sake storefront | Merchant product detail. |

### Current Admin Base Routes

| Route | Current label / intent | Classification | Current inferred role |
| --- | --- | --- | --- |
| `/admin/login` | Admin login | Platform Core | unauthenticated / admin / store_owner |
| `/admin/stores` | 店家列表 | Sake | admin |
| `/admin/stores/:id/hourly` | 店家 hourly telemetry | Sake | admin |
| `/admin/devices` | 機器列表 | Sake | admin |
| `/admin/devices/:id` | 機器 detail | Sake | admin |
| `/admin/sake-products` | 酒機商品設定 | Sake | admin |
| `/admin/reports` | 報表分析 | Sake | admin |
| `/admin/top10` | Top10 排行 | Sake | admin |
| `/admin/machine-monitor` | 機器監控 | Sake | admin |

### Current Merchant Routes

| Route | Current label / intent | Classification | Current inferred role |
| --- | --- | --- | --- |
| `/admin/merchant/catalog` | 酒款目錄 | Sake | admin / store_owner |
| `/admin/merchant/brands` | 我的品牌 | Sake | admin / store_owner |
| `/admin/merchant/products` | 我的商品 | Sake | admin / store_owner |
| `/admin/merchant/clients` | 客戶管理 | Sake | admin / store_owner |
| `/admin/merchant/orders` | 訂單管理 | Sake | admin / store_owner |
| `/admin/merchant/reports` | 業務回報 | Sake | admin / store_owner |
| `/admin/merchant/storefront` | 店面設定 | Sake | admin / store_owner |
| `/admin/merchant/machine-config` | 機器設定 | Sake | admin / store_owner |

### Current Operations Routes

| Route | Current label / intent | Classification | Current inferred role |
| --- | --- | --- | --- |
| `/admin/catalog/import-review` | 資料管理 / 匯入審核 | Legacy / Demo / Beta, Platform Core candidate | admin |
| `/admin/agent-workspace` | AI 助理 | AI Agent / Agent Workspace | admin / store_owner with org scope |
| `/admin/shipment` | 出貨管理 / 出貨單 | Inventory / Logistics, Sake currently | admin / store_owner |
| `/admin/shipment/:id` | 出貨單 detail | Inventory / Logistics, Sake currently | admin / store_owner |
| `/admin/inventory` | 庫存總覽 | Inventory / Logistics, Sake currently | admin / store_owner |
| `/admin/inventory/receipts` | 入庫單 | Inventory / Logistics, Sake currently | admin / store_owner |
| `/admin/inventory/receipts/:id` | 入庫單 detail | Inventory / Logistics, Sake currently | admin / store_owner |
| `/admin/inventory/batches` | 批次管理 | Inventory / Logistics, Sake currently | admin / store_owner |
| `/admin/inventory/movements` | 異動紀錄 | Inventory / Logistics, Sake currently | admin / store_owner |

## 2. Current Sidebar Assessment

The current sidebar is inferred from VER289 route groups and product labels:

| Sidebar area | Item | Current route | Classification | Governance note |
| --- | --- | --- | --- | --- |
| 酒機管理 | 店家列表 | `/admin/stores` | Sake | Keep under Sake Admin. |
| 酒機管理 | 機器列表 | `/admin/devices` | Sake | Keep under Sake Admin. |
| 酒機管理 | 酒機商品設定 | `/admin/sake-products` | Sake | Keep under Sake Admin. |
| 酒機管理 | 機器監控 | `/admin/machine-monitor` | Sake | Keep under Sake Admin. |
| 日本酒奉行 | 日本酒奉行 | TBD / mixed with catalog/import | Sake / AI Agent candidate | Needs a dedicated product capability definition before route migration. |
| AI 助理 | Agent Workspace | `/admin/agent-workspace` | AI Agent / Agent Workspace | Move to `/agent-workspace`; expose from Platform and Sake only by role and org context. |
| 出貨管理 | 出貨單 | `/admin/shipment` | Inventory / Logistics | Shared pattern, Sake data domain today. Meat must receive its own logistics namespace later. |
| 庫存管理 | 庫存總覽 | `/admin/inventory` | Inventory / Logistics | Shared pattern, Sake data domain today. Do not reuse data tables for Meat without explicit contract. |
| 庫存管理 | 入庫單 | `/admin/inventory/receipts` | Inventory / Logistics | Same as above. |
| 庫存管理 | 批次管理 | `/admin/inventory/batches` | Inventory / Logistics | Same as above. |
| 庫存管理 | 異動紀錄 | `/admin/inventory/movements` | Inventory / Logistics | Same as above. |
| 資料管理 | 匯入審核 | `/admin/catalog/import-review` | Legacy / Demo / Beta | Mark as beta/governance tool until promoted to Platform Core. |
| Merchant Ops | 酒款目錄 | `/admin/merchant/catalog` | Sake | Keep under Sake Admin. |
| Merchant Ops | 我的品牌 | `/admin/merchant/brands` | Sake | Keep under Sake Admin. |
| Merchant Ops | 我的商品 | `/admin/merchant/products` | Sake | Keep under Sake Admin. |
| Merchant Ops | 客戶管理 | `/admin/merchant/clients` | Sake | Keep under Sake Admin. |
| Merchant Ops | 訂單管理 | `/admin/merchant/orders` | Sake | Keep under Sake Admin. |
| Merchant Ops | 業務回報 | `/admin/merchant/reports` | Sake | Keep under Sake Admin. |
| Merchant Ops | 店面設定 | `/admin/merchant/storefront` | Sake | Keep under Sake Admin. |
| Merchant Ops | 機器設定 | `/admin/merchant/machine-config` | Sake | Keep under Sake Admin. |

Key issue: multiple product lines and operational concepts are being routed through `/admin`. This creates a high risk that future Meat Admin screens, agent tools, platform governance, and Sake merchant workflows pollute each other through one sidebar and one role vocabulary.

## 3. Proposed Three-Layer Entrypoint Architecture

### 3.1 Platform Portal / 皇上吉祥平台入口

Route namespace: `/platform`

Purpose: system owner and platform governance. This portal controls tenants, product lines, plans, governance, integration surfaces, and subsystem launch.

Recommended sections:

| Section | Items | Notes |
| --- | --- | --- |
| Organizations | 組織管理 | Cross-product tenant registry. |
| Access | 使用者/角色 | Platform roles and membership management. |
| Billing | 訂閱與方案 | Plan, product entitlement, quota policy. |
| Integrations | API Key / Webhook 管理 | Secret values must never be displayed after creation; documents may name env vars only. |
| AI Governance | AI Agent 管理 | Agent registry, permissions, quota, approval gates. |
| Project Governance | 專案治理連結 | Link to `/project-governance` and Project Command Center metadata. |
| Audit | Audit Log | Platform-wide audit readout. |
| Launcher | 子系統 Launcher | Launch Sake Admin, Meat Admin, Agent Workspace, Project Governance by role and entitlement. |

### 3.2 Sake Admin / 酒商酒機後台

Route namespace: `/sake-admin`

Purpose: Sake merchants, machines, store operations, inventory/logistics for sake, and sake product operations.

Recommended sections:

| Section | Items |
| --- | --- |
| 酒機管理 | 店家列表, 機器列表, 酒機商品設定, 機器監控 |
| 酒商營運 | 日本酒奉行, 酒款目錄, 我的品牌, 我的商品 |
| 客戶與訂單 | 客戶管理, 訂單管理, 業務回報 |
| 通路設定 | 店面設定, 機器設定 |
| 出貨管理 | 出貨單 |
| 庫存管理 | 庫存總覽, 入庫單, 批次管理, 異動紀錄 |
| 分析 | 報表分析, Top10 排行 |

### 3.3 Meat Admin / 熟成肉後台

Route namespace: `/meat-admin`

Purpose: future isolated vertical SaaS for meat brands, factories, aging operations, tags, food safety, and future app contracts. This is an architecture placeholder only.

Recommended sections:

| Section | Items |
| --- | --- |
| 廠商與工廠 | 肉品廠商管理 |
| Tag Registry | QR / NFC / RFID Tag Registry |
| 批次與熟成 | 真空熟成袋批次管理, 肉品批次 `meat_batch`, 熟成參數 `aging_profile`, 熟成任務 `aging_session`, 熟成日記 `aging_diary` |
| 偏好資料 | 使用者喜好 `flavor_feedback`, 地區偏好分布 `regional_preference` |
| 肉品資料庫 | 和牛, 澳和, 美牛, 部位, 熟成天數 |
| 食安治理 | 食安/召回/防偽掃描紀錄 |
| 分析 | 肉品報表分析 |
| API Contract | 未來 App API Contract |

## 4. Route Namespace Recommendation

Do not add new product lines to the existing `/admin` sidebar.

| Namespace | Owner | Purpose |
| --- | --- | --- |
| `/platform` | Platform Core | Tenant, plan, user, role, audit, integration, launcher, governance. |
| `/sake-admin` | Sake product line | Sake merchant, machine, sake inventory/logistics, sake reports. |
| `/meat-admin` | Meat product line | Meat brand/factory/aging/tag/food-safety workflows. Placeholder until implemented. |
| `/agent-workspace` | AI Agent layer | Cross-product agent workbench, role filtered by product context. |
| `/project-governance` | Governance / local command center | Project status, repo links, deployment aliases, docs, migrations, verification state. |

Suggested migration mapping:

| Current route | Future route |
| --- | --- |
| `/admin/login` | `/platform/login` or shared `/login` with product launcher |
| `/admin/stores` | `/sake-admin/stores` |
| `/admin/stores/:id/hourly` | `/sake-admin/stores/:id/hourly` |
| `/admin/devices` | `/sake-admin/machines` |
| `/admin/devices/:id` | `/sake-admin/machines/:id` |
| `/admin/sake-products` | `/sake-admin/machine-products` |
| `/admin/reports` | `/sake-admin/reports` |
| `/admin/top10` | `/sake-admin/top10` |
| `/admin/machine-monitor` | `/sake-admin/machine-monitor` |
| `/admin/merchant/catalog` | `/sake-admin/catalog` |
| `/admin/merchant/brands` | `/sake-admin/brands` |
| `/admin/merchant/products` | `/sake-admin/products` |
| `/admin/merchant/clients` | `/sake-admin/clients` |
| `/admin/merchant/orders` | `/sake-admin/orders` |
| `/admin/merchant/reports` | `/sake-admin/sales-reports` |
| `/admin/merchant/storefront` | `/sake-admin/storefront` |
| `/admin/merchant/machine-config` | `/sake-admin/machine-config` |
| `/admin/catalog/import-review` | `/platform/data-imports/import-review` or `/project-governance/import-review`, depending on ownership |
| `/admin/agent-workspace` | `/agent-workspace` |
| `/admin/shipment` | `/sake-admin/shipments` |
| `/admin/shipment/:id` | `/sake-admin/shipments/:id` |
| `/admin/inventory` | `/sake-admin/inventory` |
| `/admin/inventory/receipts` | `/sake-admin/inventory/receipts` |
| `/admin/inventory/receipts/:id` | `/sake-admin/inventory/receipts/:id` |
| `/admin/inventory/batches` | `/sake-admin/inventory/batches` |
| `/admin/inventory/movements` | `/sake-admin/inventory/movements` |

## 5. Role And Entrypoint Matrix

| Role | Platform Portal | Sake Admin | Meat Admin | Agent Workspace | Project Governance | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| `platform_owner` | Full access | Cross-org read / governed support | Cross-org read / governed support | Full governance | Full access | Highest platform governance role. |
| `platform_admin` | Admin access except ownership/security-critical settings | Cross-org read / governed support | Cross-org read / governed support | Manage platform agents | Full or delegated access | Operational platform administrator. |
| `sake_org_admin` | Launcher and own org profile only | Full own-org Sake Admin | No | Own-org Sake agents | Own-org project links if delegated | Cannot see Meat data by default. |
| `sake_store_manager` | Launcher only | Store/machine/customer/order/inventory operational access | No | Own-store Sake agents | No by default | Scoped to assigned store/org. |
| `sake_staff` | Launcher only | Limited operational tasks | No | Limited approved agent actions | No | No cross-org visibility. |
| `meat_brand_admin` | Launcher and own org profile only | No | Brand-level Meat Admin | Own-brand Meat agents | Own-brand project links if delegated | Cannot see Sake data by default. |
| `meat_factory_admin` | Launcher only | No | Factory-level Meat Admin | Factory-scoped Meat agents | No by default | Can manage factory operations and operators. |
| `meat_operator` | Launcher only | No | Operational aging/tag/diary tasks | Limited approved agent actions | No | Factory floor or operations role. |
| `meat_viewer` | Launcher only | No | Read-only Meat Admin | Read/summarize agents only | No | Reporting or QA read access. |
| `consumer_app_user` | No | No | No backoffice | No | No | Consumer app identity only; never receives backoffice sidebar. |

## 6. Sidebar Governance Principles

### 6.1 Centralized Sidebar Config

Sidebar definitions should be centralized per product line and composed by a router/role layer:

- `platformNavConfig`
- `sakeAdminNavConfig`
- `meatAdminNavConfig`
- `agentWorkspaceNavConfig`
- `projectGovernanceNavConfig`

Each config owns only its product line. Shared components may render nav items, but no vertical may append items directly into another vertical's sidebar.

### 6.2 Nav Item Schema

Recommended schema:

```ts
type ProductLine = 'platform' | 'sake' | 'meat' | 'agent' | 'contracts';
type NavLifecycle = 'stable' | 'beta' | 'demo' | 'legacy' | 'hidden';

type NavItem = {
  id: string;
  label: string;
  route: string;
  productLine: ProductLine;
  section: string;
  icon?: string;
  requiredRoles: string[];
  requiredEntitlements?: string[];
  requiredFeatureFlags?: string[];
  orgContextRequired: boolean;
  orgTypes?: Array<'platform' | 'sake_merchant' | 'meat_brand' | 'meat_factory'>;
  lifecycle: NavLifecycle;
  badge?: 'Beta' | 'Demo' | 'Legacy';
  auditEventKey?: string;
};
```

### 6.3 Feature Flag / Beta / Demo Rules

1. `stable`: visible when role, entitlement, and org context match.
2. `beta`: visible only with a feature flag and a Beta badge.
3. `demo`: visible only in demo/staging or for explicitly allowlisted roles; must display Demo badge.
4. `legacy`: hidden by default from new orgs; visible only for migration/support roles.
5. `hidden`: never shown in sidebar; route access still requires guard checks.

### 6.4 Role Filtering Rules

Navigation filtering is a convenience only. Route guards and API authorization remain mandatory.

Visibility requires all of:

1. user role intersects `requiredRoles`
2. product entitlement exists for current org
3. feature flags match lifecycle requirements
4. active organization context matches `orgTypes`
5. route guard confirms the same scope server-side or service-side

### 6.5 Organization Context Switching Rules

1. Platform users may switch product/org context only inside Platform Portal or Project Governance surfaces.
2. Sake users default to a `sake_merchant` org context.
3. Meat users default to a `meat_brand` or `meat_factory` context.
4. Switching from Sake to Meat must use the Platform Launcher or a top-level product switcher, never the same sidebar group.
5. Context labels must be visible in every backoffice shell.
6. Cross-org support mode must be explicit, audited, and time-bounded.

### 6.6 Vertical SaaS Anti-Pollution Rules

1. New Meat Admin routes must never be added under `/admin` or `/sake-admin`.
2. Sake-specific inventory/logistics screens must not be reused for Meat unless the data contract is explicitly product-neutral.
3. Product-line nav configs must not import each other.
4. Shared UI primitives are allowed; shared business state is not implied.
5. AI Agent tools must declare product line and org scope before reading or drafting.
6. Demo/Beta tools must not appear in production sidebars unless explicitly allowlisted.
7. Consumer app users must not be represented as backoffice users.

## 7. Readdy Next-Round UI Tasks

Recommended next UI tasks for Readdy:

1. Add a top-level product shell concept for `/platform`, `/sake-admin`, `/meat-admin`, `/agent-workspace`, and `/project-governance`.
2. Create a Platform Launcher mock that routes users into allowed product lines.
3. Split the existing `/admin` sidebar mock into Sake Admin sections first, without changing production data behavior.
4. Add visual badges for Beta, Demo, and Legacy nav items.
5. Add visible organization context and product-line context in each shell.
6. Build Meat Admin as a disabled/placeholder architecture screen only until contracts and data model are approved.

## 8. Explicit Non-Scope For This Planning Round

This planning round does not change:

- production UI implementation
- database schema
- migrations
- RLS policies
- secrets
- environment values
- API keys
- service role keys
