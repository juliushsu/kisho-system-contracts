# Domain Module Boundary

Status: Proposed
Date: 2026-05-15
Scope: Documentation / governance only

本輪為 documentation/governance only。

本文件不涉及 production code、不涉及 DB migration、不涉及 secrets、不涉及 Readdy UI 修改。後續需由 CTO review 後才可進入 implementation phase。

## 1. 目的

本文件定義皇上吉祥 / 大皇居平台各模組邊界，避免酒/酒機、熟成肉、B2B 採購、餐瓷/器皿、AI Agent、LINE Bot、共用客戶/業務/權限/商品資料互相污染。

## 2. 模組總覽

| 模組 | 入口 | Ownership | 說明 |
| --- | --- | --- | --- |
| Platform Core / 大皇居 | `/platform` | Platform | 跨事業入口、權限、客戶主檔、AI/LINE 治理、專案治理 |
| 酒 / 酒機 | `/sake-admin` | Sake | 酒商、酒款、酒機、機器商品、酒類庫存與出貨 |
| 熟成肉 | `/meat-admin` | Meat | 肉品品牌、工廠、熟成批次、Tag、防偽、食安 |
| B2B 採購 | `/procurement-admin`, `/b2b` | Procurement | 商品型錄、客戶價格、報價、訂單草稿、調貨、毛利 |
| 餐瓷 / 器皿 | `/procurement-admin` initial | Procurement category | 初期作為 B2B 採購商品分類，未來可升級獨立模組 |
| AI Agent | `/platform/ai-agents` or workspace | AI Governance | 跨模組摘要、建議、草稿，不作正式決策 |
| LINE Bot | `/platform/line-bot` governance | AI / Commerce | 客戶與業務 LINE 的資訊轉換層 |

## 3. 共用資料與專屬資料

| 資料 | 是否共用 | Governance |
| --- | --- | --- |
| 使用者 | 共用 | Platform Core 管理，角色決定可見入口 |
| 角色/權限 | 共用 | Platform Core source of truth |
| 客戶公司 | 共用主檔 | 可跨事業引用，但交易資料需隔離 |
| 客戶聯絡人 | 共用主檔 | 可授權給 `/b2b` 或業務流程 |
| 業務歸屬 | 共用關聯 | 可跨事業，但需清楚 scope |
| 商品主檔 | 可共用 | 平台治理，分類與品類歸屬需清楚 |
| 酒款/酒機商品細節 | 專屬 | Sake module |
| 熟成肉批次/Tag/食安資料 | 專屬 | Meat module |
| 採購報價/毛利/調貨條件 | 專屬 | Procurement module，內部角色控管 |
| LINE 對話摘要 | 受控共用 | 僅能依客戶、業務、案件 scope 查看 |
| AI 建議與草稿 | 受控共用 | 需保留來源、狀態、人工確認紀錄 |

## 4. 酒 / 酒機邊界

酒 / 酒機模組負責：

1. 酒商與門市。
2. 酒款、品牌、酒機商品設定。
3. 酒機、設備、機器監控。
4. 酒類庫存、出貨、批次與異動。
5. 酒類訂單與客戶營運。

不負責：

1. 熟成肉批次與食安。
2. B2B 採購平台的跨品類報價與毛利治理。
3. 餐瓷/器皿作為獨立產品線治理。
4. AI LINE Bot 的跨入口治理。
5. Platform Core 的角色與專案治理 source of truth。

## 5. 熟成肉邊界

熟成肉模組負責：

1. 肉品品牌與工廠。
2. 熟成批次、熟成參數、熟成日記。
3. QR / NFC / RFID Tag registry。
4. 防偽掃描、食安、召回。
5. 未來肉品消費者或 App API contract。

不負責：

1. 酒機商品、酒款與酒商營運。
2. 通用 B2B 採購報價 engine。
3. 共用客戶主檔 source of truth。
4. AI Agent 全局權限治理。

## 6. B2B 採購邊界

B2B 採購模組負責：

1. 客戶帳號與採購人進入 `/b2b` 的採購流程。
2. 跨品類商品型錄與可見商品。
3. 客戶專屬價格。
4. 報價版本。
5. 訂單草稿。
6. 業務歸屬。
7. 調貨商品。
8. 毛利試算。
9. 客戶常用採購清單。

不負責：

1. 直接替代酒/肉事業的專業營運後台。
2. AI 自動成立正式訂單。
3. 客戶可見成本與毛利。
4. 無權限讀取其他客戶報價與訂單。

## 7. 餐瓷 / 器皿邊界

初期：

| 項目 | 決策 |
| --- | --- |
| 模組 | B2B 採購商品分類 |
| 管理 | `/procurement-admin` |
| 客戶入口 | `/b2b` |
| 獨立入口 | 不建立 |

未來升級 `/tableware-admin` 條件：

1. 有獨立供應商與採購流程。
2. 有獨立售後、庫存、調貨或展示需求。
3. 有獨立角色與權限。
4. 不再只是 B2B 採購平台中的商品分類。

## 8. Procurement Domain Boundary Review

本節補充 Procurement Canonical Contracts Phase 的 domain review。它只定義邊界，不授權 DB migration、production logic、Readdy implementation、API route generation 或 Edge Function implementation。

### 8.1 Procurement vs Sake Admin Boundaries

| Topic | Procurement owns | Sake Admin owns |
| --- | --- | --- |
| Customer B2B buying flow | `/b2b` inquiry, quote, order draft, customer procurement list | Sake-specific merchant CRM and sake operational customer views |
| Product catalog | Cross-category procurement catalog and customer-visible procurement assortment | Sake-specific wine/liquor product operations and machine product configuration |
| Pricing | Customer price rules, price books, quote pricing, margin guardrails | Sake operational price display only when sourced from approved procurement/catalog contracts |
| Orders | Procurement-originated B2B order drafts and confirmed orders | Sake merchant/order workflows that remain specific to sake operations |
| Inventory | Allocation request and fulfillment need signal | Sake stock, batches, machine-backed positions, sake inventory movements |
| AI | Cross-entry draft/search/recommendation orchestration | Sake-specific summaries within approved AI-safe data scope |

Rules:

1. Procurement may reference sake products and variants, but should not mutate sake inventory directly.
2. Sake Admin may display procurement-derived quote/order references only through approved contracts.
3. Sake-specific operational workflows must not bypass procurement pricing guardrails when used for B2B customer quotes.
4. `/sake-admin` should not become the owner of `/b2b` customer account hierarchy.

### 8.2 Procurement vs Meat Admin Boundaries

| Topic | Procurement owns | Meat Admin owns |
| --- | --- | --- |
| Customer request | B2B inquiry, quote draft, customer confirmation | Meat-specific production, aging, food-safety context |
| Product sellability | Customer-visible meat products and procurement offers | Meat batch, cut, grade, aging profile, traceability, safety |
| Pricing | Quote price, customer-specific price, volatility review | Batch/grade/weight inputs that influence cost and availability |
| Supplier/sourcing | External supplier quote and procurement-required workflow | Meat producer/factory operational source data where applicable |
| Inventory/fulfillment signal | Demand and allocation request | Meat batch readiness and food-safety eligibility |
| AI | Drafts and recommendation with guardrails | Meat-specific analysis only through approved safe context |

Rules:

1. Procurement may sell aged meat only when Meat Admin or approved meat catalog data marks it available.
2. Meat Admin owns food-safety and traceability truth; Procurement must not override it.
3. Aged meat pricing volatility requires category owner or procurement review when weight, grade, batch, or aging status changes materially.
4. Customer-facing meat offers must not reveal internal yield loss, supplier cost, or margin.

### 8.3 Shared Inventory Strategy

Procurement is a demand and commitment layer; inventory remains a physical truth layer.

| Capability | Owner | Rule |
| --- | --- | --- |
| Demand signal | Procurement | Quote/order drafts may express desired quantity |
| Inventory truth | Sake/Meat/Inventory domain | Physical stock, batches, positions, and movements stay with inventory owner |
| Allocation suggestion | AI / Procurement | AI may suggest; no automatic reservation/deduction |
| Reservation/allocation | Inventory or fulfillment policy | Requires approved system/human workflow |
| Deduction/movement | Inventory domain | Procurement and AI do not directly mutate inventory |

Future shared inventory must preserve:

1. Order, shipment, and inventory separation.
2. Batch/position truth in inventory domain.
3. Procurement order items as demand, not physical stock changes.
4. Audit from order to allocation to shipment.

### 8.4 Supplier Ownership Boundaries

Supplier ownership depends on supplier role.

| Supplier type | Owner | Notes |
| --- | --- | --- |
| Cross-category sourcing supplier | Procurement | Used for B2B sourcing, supplier quotes, lead time |
| Sake importer/distributor | Procurement + Sake steward | Cost/availability may feed quotes; sake-specific data remains governed |
| Meat producer/factory | Meat + Procurement | Meat safety/traceability stays with Meat; quote/cost workflow stays with Procurement |
| Tableware supplier | Procurement | Tableware remains procurement category until upgraded |

Rules:

1. Supplier costs are internal-only.
2. Supplier quotes may inform customer quotes but are not customer-facing records.
3. AI may summarize supplier risk internally, but cannot commit supplier procurement.
4. Supplier ownership must be explicit before implementation because it affects cost visibility and approval.

### 8.5 Pricing Ownership Boundaries

Pricing is governed by Procurement / Finance / Sales Ops, not by individual product admin screens.

| Pricing object | Owner | Boundary |
| --- | --- | --- |
| Market reference pricing | Procurement / Finance | Internal sanity check, not automatic quote |
| Price books | Procurement / Finance | Approved pricing layer |
| Customer price rules | Procurement / Sales Ops | Customer-specific and auditable |
| Supplier costs | Procurement | Internal-only |
| Margin thresholds | Finance / Procurement | Internal-only guardrails |
| Quote price | Sales + Procurement | Customer-facing only after approval rules |

Rules:

1. Sake Admin and Meat Admin should not independently create customer-specific B2B pricing.
2. AI cannot approve pricing or activate customer price rules.
3. High-risk pricing actions require human approval.
4. Expired quotes cannot be silently converted to orders.

### 8.6 AI Orchestration Boundaries

AI orchestration coordinates context, drafts, and recommendations across LINE, Procurement, Sales, Customer, and Order.

AI may:

1. Receive inquiry context.
2. Search product candidates.
3. Create quote/order drafts.
4. Flag pricing, supplier, identity, or inventory risk.
5. Recommend follow-up.

AI must not:

1. Confirm orders.
2. Approve or activate pricing.
3. Commit supplier procurement.
4. Allocate or deduct inventory.
5. Send sensitive margin/cost data to customers.
6. Use one customer's private context for another customer.

Canonical orchestration references:

| Topic | Source of truth |
| --- | --- |
| Customer context | `docs/platform/CUSTOMER_CONTEXT_GOVERNANCE.md` |
| AI commerce events | `docs/procurement/AI_COMMERCE_EVENT_CONTRACT.md` |
| Pricing guardrails | `docs/procurement/PRICING_GOVERNANCE_CONTRACT.md` |

## 9. AI Agent 邊界

AI Agent 負責：

1. 摘要資料。
2. 建議補貨或報價注意事項。
3. 建立草稿。
4. 產生 LINE / email 回覆草稿。
5. 偵測缺漏與風險。

AI Agent 不負責：

1. 最終商務決策。
2. 改價、改成本、改毛利。
3. 確認正式訂單。
4. 扣庫存、確認出貨。
5. 跨 org 或跨客戶推論。
6. 讀取 secrets 或 `.env`。

## 10. LINE Bot 邊界

LINE Bot 負責：

1. 客戶 LINE 詢問的需求解析。
2. 業務端 LINE 摘要與提醒。
3. 採購平台草稿建立。
4. 客戶確認與業務確認之間的資訊轉換。

LINE Bot 不負責：

1. 取代業務。
2. 直接成立正式訂單。
3. 自動報價或改價。
4. 自動扣庫存或安排出貨。
5. 顯示或轉送 secrets。

## 11. Shared Source Of Truth 建議

| 主題 | Source of truth |
| --- | --- |
| 平台入口與大皇居定位 | `docs/platform/DAIKOJU_PLATFORM_ARCHITECTURE.md` |
| 後台 route namespace | `docs/platform/BACKOFFICE_ENTRYPOINT_GOVERNANCE.md` |
| 模組邊界 | `docs/platform/DOMAIN_MODULE_BOUNDARY.md` |
| B2B 採購 roadmap | `docs/procurement/PROCUREMENT_PLATFORM_ROADMAP.md` |
| Procurement canonical data | `docs/procurement/PROCUREMENT_CANONICAL_DATA_CONTRACT.md` |
| Customer context | `docs/platform/CUSTOMER_CONTEXT_GOVERNANCE.md` |
| AI commerce events | `docs/procurement/AI_COMMERCE_EVENT_CONTRACT.md` |
| Pricing governance | `docs/procurement/PRICING_GOVERNANCE_CONTRACT.md` |
| AI LINE Bot 商務流程 | `docs/procurement/AI_LINE_BOT_COMMERCE_FLOW.md` |
| Procurement implementation phases | `docs/governance/PROCUREMENT_IMPLEMENTATION_PHASE_PLAN.md` |
| GitHub branch/docs 清理 | `docs/governance/GITHUB_BRANCH_AND_DOCS_CLEANUP_PLAN.md` |
| AI Agent 上位原則 | `decisions/core/ai_agent_operating_model_v1.md` |
| 多租戶與酒商平台核心原則 | `decisions/core/platform_operating_model_v1.md` |

## 12. Implementation Gate

任何跨模組實作前需確認：

1. 該功能屬於哪個 module owner。
2. 是否會讀寫共用資料。
3. 是否會暴露成本、毛利、客戶資料或跨事業資訊。
4. 是否需要 AI/human approval checkpoint。
5. 是否需要 migration proposal。
