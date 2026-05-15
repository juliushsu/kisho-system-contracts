# 大皇居平台架構治理

Status: Proposed
Date: 2026-05-15
Scope: Documentation / governance only

本輪為 documentation/governance only。

本文件不涉及 production code、不涉及 DB migration、不涉及 secrets、不涉及 Readdy UI 修改。後續需由 CTO review 後才可進入 implementation phase。

## 1. 平台定位

「大皇居」是皇上吉祥集團級平台總入口，不是單一商品線後台，也不是任一事業的營運頁面延伸。

大皇居負責建立跨事業的共同治理層，讓酒商酒機、熟成肉、B2B 採購平台、餐瓷/器皿、AI Agent、LINE Bot 都能在同一套權限、客戶、專案治理與資料邊界下協作。

平台定位：

| 層級 | 名稱 | 職責 |
| --- | --- | --- |
| 集團入口 | 大皇居 / `/platform` | 跨事業入口、使用者、角色、客戶主檔、AI Agent、LINE Bot、專案治理 |
| 事業後台 | 酒與酒機 / `/sake-admin` | 酒商、酒款、酒機、酒機商品、庫存、出貨、酒類客戶與訂單 |
| 事業後台 | 熟成肉 / `/meat-admin` | 肉品品牌、工廠、熟成批次、標籤、防偽、食安與召回 |
| 採購後台 | B2B 採購管理 / `/procurement-admin` | 商品型錄、供應商、客戶價格、報價、訂單草稿、業務歸屬 |
| 客戶入口 | B2B 採購入口 / `/b2b` | 客戶採購、常用清單、報價確認、訂單確認 |
| 對話層 | AI LINE Bot | 客戶 LINE、業務 LINE、採購草稿、確認流程的資訊轉換層 |

## 2. 大皇居負責的共用能力

大皇居作為平台總入口，應優先承接下列共用能力。

| 能力 | 說明 | 不應放在單一事業後台的原因 |
| --- | --- | --- |
| 跨事業 Launcher | 依權限顯示 `/sake-admin`、`/meat-admin`、`/procurement-admin`、`/b2b`、AI workspace 等入口 | 避免所有事業塞進舊 `/admin` |
| 使用者與角色 | 平台 owner、平台 admin、業務、事業 admin、客戶帳號、外部協作者 | 權限是跨事業共用治理，不屬於酒或肉任一產品 |
| 客戶主檔 | 客戶公司、聯絡人、地址、統編、業務歸屬、可見事業線 | 同一客戶可能同時買酒、熟成肉、餐瓷與調貨商品 |
| AI Agent Registry | Agent 名稱、能力、可讀資料範圍、批准門檻、費用/額度 | AI 不能被單一事業線私有化而繞過治理 |
| LINE Bot Governance | Bot 身分、對話歸屬、客戶識別、業務確認、正式訂單交接 | LINE 是跨入口資訊轉換層，不是單一訂單系統 |
| 專案治理 | GitHub repo、branch、docs source of truth、Readdy 施工依據、Codex 任務邊界 | 確保後續實作依 review 過的文件施工 |

## 3. 與現有文件的關係

本文件建立大皇居的集團級平台視角，並承接既有 contracts repo 的核心治理文件。

| 既有文件 | 狀態 | 關係 |
| --- | --- | --- |
| `decisions/core/platform_operating_model_v1.md` | 有效 | 酒商多租戶、商品、庫存、AI 使用原則仍有效；本文件將其提升到集團平台入口層 |
| `decisions/core/ai_agent_operating_model_v1.md` | 有效 | AI assists / Humans decide / System enforces 仍為所有 Agent 與 LINE Bot 的上位原則 |
| `docs/platform/BACKOFFICE_ENTRYPOINT_AND_SIDEBAR_GOVERNANCE.md` | 有效但偏 Readdy/舊後台路由盤點 | 本文件採納其 `/platform`、`/sake-admin`、`/meat-admin` 分層方向，並加入 procurement、B2B 與 LINE Bot |
| `docs/platform/READDY_VER293_GOVERNANCE_READOUT.md` | 有效作為 Ver293 現況盤點 | Ver293 已有 platform/sake/meat/agent/project-governance shell；尚缺 procurement、B2B、LINE Bot governance |
| `docs/platform/PROJECT_GOVERNANCE_METADATA_BRIDGE.md` | 有效 | 可作為大皇居 Project Governance 的 metadata registry 基礎 |
| `docs/platform/PROJECT_COMMAND_CENTER_METADATA_CONTRACT.md` | 有效 | 可作為 Codex/local command center 與大皇居治理資料的銜接 |

## 4. 大皇居的資訊架構

建議 `/platform` 初期不做成重型 ERP，而是做成治理型 Command Center。

建議分區：

| 分區 | 功能 |
| --- | --- |
| Dashboard | 集團級事業入口、治理狀態、待審核事項 |
| Organizations | 公司、事業單位、供應商、客戶公司、門市/工廠 |
| Users & Roles | 使用者、角色、邀請、權限範圍、客戶帳號 |
| Customers | 共用客戶主檔、聯絡人、地址、業務歸屬、可購分類 |
| Product Lines | 酒/酒機、熟成肉、B2B 採購、餐瓷/器皿分類的啟用狀態 |
| AI Agents | Agent registry、可讀資料範圍、可建立草稿類型、人工確認門檻 |
| LINE Bot | LINE 身分綁定、對話歸屬、客戶識別、業務端確認流程 |
| Project Governance | GitHub docs、source of truth、branch 狀態、Readdy/Codex 施工依據 |
| Audit | 權限、草稿、確認、訂單轉正式、AI 建議與人工批准紀錄 |

## 5. 大皇居不負責的事項

為避免平台總入口變成巨型單體，本階段明確排除：

| 不負責事項 | 應歸屬 |
| --- | --- |
| 酒機即時營運細節 | `/sake-admin` |
| 熟成肉批次作業與食安流程 | `/meat-admin` |
| 採購商品維護、報價版本、毛利試算 | `/procurement-admin` |
| 客戶下單與報價確認 | `/b2b` |
| AI 直接確認訂單、改價、扣庫存 | 不允許；需人類批准與系統執行 |
| secrets、token、service role key、DB connection string | 不得進入 GitHub 文件 |

## 6. 權限與資料邊界原則

大皇居應遵守下列不可違反原則：

1. 平台可治理跨事業入口，但不得讓一般事業使用者跨事業讀取資料。
2. 客戶主檔可共用，但交易資料、報價、成本、毛利必須依角色與事業邊界控管。
3. AI Agent 可讀 AI-safe view、可建立草稿、可摘要對話，但不可直接成為資料 source of truth。
4. LINE Bot 是資訊轉換層，不是繞過業務確認的自動下單機器。
5. 所有從 LINE、B2B、業務端產生的訂單都必須保留草稿、確認、正式化的 audit trail。
6. Readdy/Codex 實作前，必須先對照本文件包與 CTO review 結論。

## 7. Implementation Gate

本文件僅建立治理基準，不授權任何 implementation。

進入 implementation phase 前，至少需要：

1. CTO review 本文件與 `DOMAIN_MODULE_BOUNDARY.md`。
2. 確認 `/platform`、`/sake-admin`、`/meat-admin`、`/procurement-admin`、`/b2b` route namespace。
3. 確認 B2B 採購平台 Phase 1 scope。
4. 確認 AI LINE Bot 僅能建立草稿與摘要，不可直接成立正式訂單。
5. 建立 migration proposal 後，才可討論 DB schema 或資料搬遷。
