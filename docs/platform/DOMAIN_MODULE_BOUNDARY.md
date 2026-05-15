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

## 8. AI Agent 邊界

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

## 9. LINE Bot 邊界

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

## 10. Shared Source Of Truth 建議

| 主題 | Source of truth |
| --- | --- |
| 平台入口與大皇居定位 | `docs/platform/DAIKOJU_PLATFORM_ARCHITECTURE.md` |
| 後台 route namespace | `docs/platform/BACKOFFICE_ENTRYPOINT_GOVERNANCE.md` |
| 模組邊界 | `docs/platform/DOMAIN_MODULE_BOUNDARY.md` |
| B2B 採購 roadmap | `docs/procurement/PROCUREMENT_PLATFORM_ROADMAP.md` |
| AI LINE Bot 商務流程 | `docs/procurement/AI_LINE_BOT_COMMERCE_FLOW.md` |
| GitHub branch/docs 清理 | `docs/governance/GITHUB_BRANCH_AND_DOCS_CLEANUP_PLAN.md` |
| AI Agent 上位原則 | `decisions/core/ai_agent_operating_model_v1.md` |
| 多租戶與酒商平台核心原則 | `decisions/core/platform_operating_model_v1.md` |

## 11. Implementation Gate

任何跨模組實作前需確認：

1. 該功能屬於哪個 module owner。
2. 是否會讀寫共用資料。
3. 是否會暴露成本、毛利、客戶資料或跨事業資訊。
4. 是否需要 AI/human approval checkpoint。
5. 是否需要 migration proposal。
