# 後台入口治理

Status: Proposed
Date: 2026-05-15
Scope: Documentation / governance only

本輪為 documentation/governance only。

本文件不涉及 production code、不涉及 DB migration、不涉及 secrets、不涉及 Readdy UI 修改。後續需由 CTO review 後才可進入 implementation phase。

## 1. 目的

本文件定義皇上吉祥 / 大皇居平台的後台與客戶入口命名，避免所有新產品線繼續塞進舊 `/admin`，也避免 Readdy、Codex、OpenAI 後續施工時把不同事業的角色、資料與 UI 混在一起。

## 2. Source Of Truth

本文件是後續入口命名與 route namespace 的 source of truth。

既有 `docs/platform/BACKOFFICE_ENTRYPOINT_AND_SIDEBAR_GOVERNANCE.md` 仍保留為 Readdy VER289/VER291/VER292 相關盤點與舊路由遷移參考；若兩份文件對「最終入口命名」有差異，以本文件為準。

Readdy Ver293 的只讀盤點記錄於 `docs/platform/READDY_VER293_GOVERNANCE_READOUT.md`。Ver293 已具備 `/platform`、`/sake-admin`、`/meat-admin`、`/agent-workspace`、`/project-governance`，但尚未具備 `/procurement-admin` 與 `/b2b`。

## 3. 正式入口定義

| Route | 中文名稱 | 角色 | 說明 |
| --- | --- | --- | --- |
| `/platform` | 大皇居總入口 | 平台 owner、平台 admin、治理角色 | 集團級平台入口，負責跨事業 launcher、權限、客戶、AI Agent、LINE Bot、專案治理 |
| `/sake-admin` | 酒與酒機後台 | 酒商管理者、酒機營運、平台支援 | 酒商、酒款、酒機、酒機商品、庫存、出貨、酒類客戶與訂單 |
| `/meat-admin` | 熟成肉後台 | 肉品品牌、工廠、QA、平台支援 | 熟成肉品牌、工廠、熟成批次、標籤、防偽、食安、召回 |
| `/procurement-admin` | B2B 採購管理後台 | 平台採購管理者、業務、採購營運 | 商品型錄、供應商、客戶專屬價格、報價版本、訂單草稿、調貨商品、毛利試算 |
| `/b2b` | 客戶採購入口 | 客戶帳號、客戶採購人員 | 客戶登入後查看可購商品、專屬價格、常用採購清單、報價與訂單確認 |

## 3.1 Readdy Ver293 Current Alignment

| Route | Ver293 observed status | Governance decision |
| --- | --- | --- |
| `/platform` | Present | Keep and expand as 大皇居總入口 after CTO review |
| `/sake-admin` | Present | Keep as 酒與酒機後台 |
| `/meat-admin` | Present placeholder | Keep as 熟成肉後台 namespace; implementation still gated |
| `/agent-workspace` | Present beta | Keep as agent workbench; platform agent registry can remain under `/platform` later |
| `/project-governance` | Present beta | Keep as governance surface; bind content to reviewed contracts docs |
| `/admin` | Present backward compatibility | Do not add new product lines here |
| `/procurement-admin` | Not present | Add only in future implementation phase after CTO review |
| `/b2b` | Not present | Add only in future implementation phase after CTO review |

## 4. Tableware 治理

餐瓷 / 器皿在初期不建立獨立後台。

初期定位：

| 項目 | 決策 |
| --- | --- |
| 商品分類 | 歸入 procurement 商品分類 |
| 管理入口 | `/procurement-admin` |
| 客戶購買入口 | `/b2b` |
| 獨立後台 | 暫不建立 |
| 未來升級路線 | 成熟後可升級為 `/tableware-admin` |

升級 `/tableware-admin` 前需 CTO review：

1. 餐瓷/器皿是否有獨立營運流程。
2. 是否有獨立庫存、履約、報價、售後或供應商管理需求。
3. 是否需要獨立權限與 sidebar。
4. 是否與 B2B 採購平台形成明確資料邊界。

## 5. `/admin` 治理原則

舊 `/admin` 不應再作為新產品線入口。

| 舊狀態 | 治理決策 |
| --- | --- |
| `/admin` 承載酒機、酒商、庫存、出貨、AI、資料匯入等混合功能 | 停止擴充成跨事業後台 |
| 現有 `/admin/*` 文件與 Readdy route mapping | 保留作歷史盤點與遷移參考 |
| 新的熟成肉、B2B 採購、LINE Bot 管理 | 不放入 `/admin` |
| 未來 route migration | 需另外提出 implementation plan 與 CTO review |

## 6. Entrypoint 權限矩陣

| Role | `/platform` | `/sake-admin` | `/meat-admin` | `/procurement-admin` | `/b2b` |
| --- | --- | --- | --- | --- | --- |
| `platform_owner` | Full | Governed support | Governed support | Full | Support / impersonation only with audit |
| `platform_admin` | Admin | Governed support | Governed support | Admin | Support / impersonation only with audit |
| `sake_admin` | Launcher only | Full own scope | No | Optional, if assigned | Optional, if also customer |
| `sake_operator` | Launcher only | Operational own scope | No | No by default | No by default |
| `meat_admin` | Launcher only | No | Full own scope | Optional, if assigned | Optional, if also customer |
| `procurement_admin` | Launcher only | No by default | No by default | Full | Support view with audit |
| `sales_owner` | Launcher only | Assigned customer/order scope | Assigned customer/order scope if enabled | Assigned customer/order scope | No, except customer support with audit |
| `customer_buyer` | No | No | No | No | Own customer scope |

## 7. Navigation Contract

大皇居 `/platform` 應呈現子系統 launcher，而不是把各後台功能攤平成同一個 sidebar。

建議 launcher card：

| Card | Target |
| --- | --- |
| 大皇居治理 | `/platform` |
| 酒與酒機 | `/sake-admin` |
| 熟成肉 | `/meat-admin` |
| B2B 採購管理 | `/procurement-admin` |
| 客戶採購入口 | `/b2b` |
| AI Agent 管理 | `/platform/ai-agents` |
| LINE Bot 管理 | `/platform/line-bot` |
| Project Governance | `/platform/project-governance` |

## 8. Readdy / Codex 施工規則

Readdy、Codex、OpenAI 後續實作前應遵守：

1. 不新增新事業到舊 `/admin`。
2. 不把 `/b2b` 客戶入口做成內部 admin sidebar。
3. 不把 tableware 直接做成 `/tableware-admin`，除非 CTO review 升級。
4. 不把 AI LINE Bot 做成可繞過業務確認的正式訂單入口。
5. 不在 UI 或 docs 中展示 secrets、token、DB URL、service role key。
6. route migration、DB schema、production UI 修改需另開 implementation phase。
