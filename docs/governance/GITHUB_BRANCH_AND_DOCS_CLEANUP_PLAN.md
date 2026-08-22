# GitHub Branch And Docs Cleanup Plan

Status: Proposed
Date: 2026-05-15
Scope: Documentation / governance only

本輪為 documentation/governance only。

本文件不涉及 production code、不涉及 DB migration、不涉及 secrets、不涉及 Readdy UI 修改。後續需由 CTO review 後才可進入 implementation phase。

## 1. 本輪盤點範圍

本輪只讀盤點與文件整理涵蓋目前本機 workspace 中的 Git 狀態：

| 路徑 | Git 狀態 | 判斷 |
| --- | --- | --- |
| workspace root `友藏8號清酒機AIot_SaaS` | 有 `.git`，但目前顯示 no commits yet，且 `kisho-system-contracts/`、`kisho_gateway/`、`stm32g474_firmware/` 為未追蹤項目 | 不建議作為本輪文件提交位置 |
| `kisho-system-contracts` | 獨立 Git repo，remote 為 `https://github.com/juliushsu/kisho-system-contracts.git` | 本輪治理文件應提交於此 |
| `kisho_gateway` | 本輪未發現獨立 `.git`，含實作與 Supabase 文件 | 不在本輪修改範圍 |
| `stm32g474_firmware` | 本輪未發現獨立 `.git` | 不在本輪修改範圍 |
| `[local Readdy artifact: 皇上吉祥-Ver293]` | Readdy Ver293 artifact，非本輪 Git repo | 只讀盤點 route/navigation；內含 `.env` 但本輪未讀取 |

## 2. Branch 盤點

`kisho-system-contracts` 目前觀察到：

| Branch | 狀態 | 建議 |
| --- | --- | --- |
| `main` | remote default branch，HEAD 指向 `origin/main` | 保留，作為已接受 contracts / decisions 的主要線 |
| `codex/readdy-ver289-contract-update` | 本輪開始時所在 branch，已追蹤 `origin/codex/readdy-ver289-contract-update` | 保留，作為 Readdy VER289/治理橋接相關工作線 |
| `codex/daikoju-platform-governance` | 本輪新增 branch | 作為大皇居平台治理文件包 review branch |

治理建議：

1. 不在 `main` 直接提交規劃文件。
2. Readdy 版本對齊文件與大皇居平台治理文件可分 branch review。
3. 合併前由 CTO review source-of-truth 文件是否互相衝突。
4. 若 `codex/readdy-ver289-contract-update` 已完成，可在 merge 後封存 branch；若仍有 Readdy 對齊任務，保留。

## 3. Docs 結構盤點

目前 `kisho-system-contracts` 的文件主要分為：

| 目錄 | 用途 | 狀態 |
| --- | --- | --- |
| `contracts/` | API、資料、Readdy alignment 等 contract 文件 | 保留 |
| `decisions/core/` | 核心架構、資料邊界、AI、庫存、訂單、平台 operating model | 保留，屬高優先 source of truth |
| `decisions/log/` 與 `decisions/logs/` | 歷史決策 log | 保留但建議整理命名 |
| `docs/platform/` | Readdy、Project Governance、Backoffice shell、平台 metadata 文件 | 保留，需補上大皇居 source-of-truth |
| `docs/meat/` | 熟成肉 placeholder | 保留但需後續補完整 meat admin governance |
| `docs/procurement/` | 本輪新增 | B2B 採購與 AI LINE Bot source-of-truth |
| `docs/governance/` | 本輪新增 | branch/docs 清理與施工依據 |
| `projects/` | Project metadata registry | 保留，可供 `/platform/project-governance` 與 local command center 使用 |

## 4. 有效文件

下列文件目前仍有效，建議保留並作為後續實作依據：

| 文件 | 用途 |
| --- | --- |
| `docs/platform/DAIKOJU_PLATFORM_ARCHITECTURE.md` | 大皇居作為集團級平台總入口的上位架構 |
| `docs/platform/BACKOFFICE_ENTRYPOINT_GOVERNANCE.md` | `/platform`、`/sake-admin`、`/meat-admin`、`/procurement-admin`、`/b2b` route namespace source of truth |
| `docs/platform/DOMAIN_MODULE_BOUNDARY.md` | 酒/酒機、熟成肉、B2B 採購、餐瓷/器皿、AI Agent、LINE Bot 的模組邊界 |
| `docs/platform/READDY_VER293_GOVERNANCE_READOUT.md` | Readdy Ver293 route/navigation 只讀盤點與缺口清單 |
| `docs/procurement/PROCUREMENT_PLATFORM_ROADMAP.md` | B2B 採購平台 roadmap |
| `docs/procurement/AI_LINE_BOT_COMMERCE_FLOW.md` | AI LINE Bot 商務流程與人工確認門檻 |
| `docs/platform/PROJECT_GOVERNANCE_METADATA_BRIDGE.md` | Project Governance metadata bridge |
| `docs/platform/PROJECT_COMMAND_CENTER_METADATA_CONTRACT.md` | Local command center metadata contract |
| `docs/platform/BACKOFFICE_ENTRYPOINT_AND_SIDEBAR_GOVERNANCE.md` | 舊 `/admin` 與 Readdy sidebar route 盤點，可作 migration reference |
| `decisions/core/platform_operating_model_v1.md` | 酒商多租戶平台核心原則 |
| `decisions/core/ai_agent_operating_model_v1.md` | AI Agent 上位操作原則 |
| `decisions/core/data_boundary_rules_v1.md` | 資料邊界原則 |
| `decisions/core/client_commerce_role_model_v1.md` | 客戶商務角色模型 |
| `decisions/core/merchant_orders_domain_boundary_v1.md` | 酒商訂單 domain boundary |
| `decisions/core/inventory_layer_architecture.md` | 庫存層架構 |

## 5. 重複或需降級為參考的文件

| 文件 | 狀態 | 建議 |
| --- | --- | --- |
| `docs/platform/BACKOFFICE_ENTRYPOINT_AND_SIDEBAR_GOVERNANCE.md` | 與本輪 `BACKOFFICE_ENTRYPOINT_GOVERNANCE.md` 有部分重疊 | 保留為 Readdy/舊路由 migration reference；最終 route 命名以本輪文件為準 |
| `docs/platform/READDY_VER291_BACKOFFICE_SHELL_REVIEW.md` | Readdy 版本檢視文件 | 保留為版本驗收紀錄，不作長期 architecture source of truth |
| `docs/platform/READDY_VER292_BASELINE_ACCEPTANCE.md` | Readdy baseline acceptance | 保留為驗收紀錄，不作入口命名 source of truth |
| `docs/platform/READDY_VER293_GOVERNANCE_READOUT.md` | Readdy Ver293 盤點 | 保留為 Ver293 對齊紀錄，不作最終 architecture source of truth |
| `contracts/readdy_ver289_frontend_alignment_v1.md` | Readdy VER289 frontend alignment | 保留為該版本 contract，不作大皇居最終 IA source of truth |
| `docs/meat/MEAT_ADMIN_ARCHITECTURE_PLACEHOLDER.md` | placeholder | 保留但標示為 placeholder；後續需補完整 meat admin architecture |

## 6. 建議封存或整理的項目

本輪不移動或刪除任何文件，只提出整理方案。

| 項目 | 問題 | 建議 |
| --- | --- | --- |
| `decisions/log/` 與 `decisions/logs/` 兩個相近目錄 | 命名重複，容易讓後續 agent 不知道寫入哪裡 | CTO review 後統一為一個 log 目錄，另一個移入 archive 或保留 redirect README |
| Readdy 版本驗收文件 | 多份文件可能被誤認為最新平台架構 | 在 README 或 governance index 標示為 version record |
| 舊 `/admin` route 文件 | 與新入口命名衝突風險 | 保留為 migration reference，禁止作為新增功能入口依據 |
| `kisho_gateway/supabase/*.md` | 許多 DB/SQL/runlist 文件位於實作 repo 旁 | 不在本輪整理；後續需分成 live runbook、schema proposal、historical verification |
| workspace root git | root repo no commits yet 且含多個子項目 | 需決定是否保留 monorepo root，或移除 root Git 管理，避免 nested repo 混亂 |

## 7. Source Of Truth 建議

後續 Readdy/Codex/OpenAI 應依下列文件施工：

| 主題 | Source of truth |
| --- | --- |
| 大皇居平台上位架構 | `docs/platform/DAIKOJU_PLATFORM_ARCHITECTURE.md` |
| 後台與客戶入口 route namespace | `docs/platform/BACKOFFICE_ENTRYPOINT_GOVERNANCE.md` |
| 模組資料與責任邊界 | `docs/platform/DOMAIN_MODULE_BOUNDARY.md` |
| B2B 採購平台 roadmap | `docs/procurement/PROCUREMENT_PLATFORM_ROADMAP.md` |
| AI LINE Bot 商務流程 | `docs/procurement/AI_LINE_BOT_COMMERCE_FLOW.md` |
| GitHub branch/docs 清理 | `docs/governance/GITHUB_BRANCH_AND_DOCS_CLEANUP_PLAN.md` |
| Readdy Ver293 現況與缺口 | `docs/platform/READDY_VER293_GOVERNANCE_READOUT.md` |
| AI Agent 行為原則 | `decisions/core/ai_agent_operating_model_v1.md` |
| 多租戶與平台核心原則 | `decisions/core/platform_operating_model_v1.md` |
| Readdy 舊路由 migration reference | `docs/platform/BACKOFFICE_ENTRYPOINT_AND_SIDEBAR_GOVERNANCE.md` |

## 8. 後續整理方案

建議後續分三步走：

1. CTO review 本輪文件包，確認 source-of-truth 表格。
2. 新增 `docs/README.md` 或 `docs/INDEX.md`，把有效文件、版本紀錄、歷史參考分區。
3. 再決定是否移動歷史 Readdy 文件與 decisions logs 到 archive；移動前需避免破壞既有連結。

## 9. Readdy / Codex 工作規則

在 CTO review 前：

1. Readdy 不應修改 production UI。
2. Codex 不應改 production code。
3. 不執行 DB migration。
4. 不讀寫 `.env`、token、service role key、DB URL。
5. 不把 tableware 做成獨立 admin。
6. 不讓 AI LINE Bot 跳過業務確認。
7. 所有 implementation 必須等 CTO review 後另開 phase。
