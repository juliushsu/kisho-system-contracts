# AI LINE Bot 商務流程治理

Status: Proposed
Date: 2026-05-15
Scope: Documentation / governance only

本輪為 documentation/governance only。

本文件不涉及 production code、不涉及 DB migration、不涉及 secrets、不涉及 Readdy UI 修改。後續需由 CTO review 後才可進入 implementation phase。

## 1. 核心定位

AI LINE Bot 不是取代業務，也不是自動成交系統。

AI LINE Bot 是跨入口資訊轉換層，負責把客戶 LINE、業務 LINE、B2B 採購平台、訂單草稿與確認流程串起來。

核心原則沿用 `decisions/core/ai_agent_operating_model_v1.md`：

```text
AI assists.
Humans decide.
System enforces.
```

## 2. 參與角色

| 角色 | 說明 |
| --- | --- |
| 客戶 | 透過 LINE 或 `/b2b` 提出需求、確認報價、確認訂單 |
| 業務 | 負責客戶關係、報價確認、毛利判斷、訂單正式成立 |
| AI LINE Bot | 摘要、辨識商品需求、建立草稿、提醒缺漏、生成回覆草稿 |
| 採購平台 | 管理商品型錄、客戶價格、報價版本、訂單草稿 |
| 系統 | 執行權限檢查、保留 audit trail、建立正式訂單 |

## 3. 標準流程

```text
客戶 LINE 詢問
-> AI LINE Bot 辨識需求與缺漏
-> 建立 inquiry / order draft
-> 業務端 LINE 收到摘要與草稿
-> 業務補充價格、交期、毛利、調貨資訊
-> 客戶收到報價或確認問題
-> 客戶確認
-> 業務確認
-> 系統建立正式訂單
```

## 4. Flow Detail

| Step | 入口 | 負責者 | 產物 |
| --- | --- | --- | --- |
| 1. 客戶詢問 | 客戶 LINE | 客戶 | 原始訊息 |
| 2. 需求解析 | AI LINE Bot | AI | 商品、數量、規格、交期、缺漏欄位摘要 |
| 3. 建立草稿 | 採購平台 | AI 建議、系統保存 | `inquiry` 或 `order_draft` |
| 4. 業務通知 | 業務 LINE / `/procurement-admin` | AI | 摘要、風險、待確認項目 |
| 5. 業務確認 | 業務 LINE / `/procurement-admin` | 業務 | 報價版本、價格、交期、調貨狀態 |
| 6. 客戶確認 | 客戶 LINE / `/b2b` | 客戶 | 客戶確認紀錄 |
| 7. 業務最終確認 | `/procurement-admin` | 業務 | 正式化批准 |
| 8. 正式訂單 | 系統 | 系統 | `confirmed_order` 與 audit trail |

## 5. AI 可做與不可做

| 類型 | Allowed |
| --- | --- |
| 摘要 | 摘要客戶訊息、業務訊息、歷史需求 |
| 辨識 | 辨識商品名稱、規格、數量、交期、地址、常用採購模式 |
| 草稿 | 建立 inquiry、報價草稿、訂單草稿、LINE 回覆草稿 |
| 提醒 | 提醒缺少數量、地址、交期、價格確認、調貨條件 |
| 建議 | 建議常用採購清單、替代商品、補充問題 |

| 類型 | Not Allowed |
| --- | --- |
| 正式成交 | 不可自行建立 confirmed order |
| 價格決策 | 不可自行改客戶專屬價格、成本、毛利 |
| 出貨決策 | 不可自行確認出貨、扣庫存、安排不可逆物流 |
| 跨客戶推論 | 不可把其他客戶價格或採購行為拿來推論 |
| secrets | 不可讀取、顯示、轉送 token、service role key、DB URL、`.env` |

## 6. LINE 與 B2B 採購平台分工

| 能力 | LINE | `/b2b` | `/procurement-admin` |
| --- | --- | --- | --- |
| 快速詢問 | Yes | Yes | Internal support |
| 商品瀏覽 | Limited | Yes | Yes |
| 常用採購清單 | Quick reorder | Full customer view | Manage / analyze |
| 報價確認 | Yes, with trace | Yes | Manage versions |
| 毛利試算 | No | No | Yes |
| 調貨商品 | Inquiry only | Inquiry / quote view | Supplier, cost, delivery confirmation |
| 正式訂單 | Customer confirmation only | Customer confirmation only | Sales final confirmation |

## 7. 確認門檻

正式訂單成立前，至少需要兩層確認：

1. 客戶確認：確認商品、數量、價格、交期或接受仍需調貨的條件。
2. 業務確認：確認報價、毛利、供應、交期、客戶條件與風險。

AI LINE Bot 只能將流程推進到 `draft` 或 `awaiting_human_review`，不可跳過人工確認。

## 8. Audit Trail

AI LINE Bot 相關流程需保留：

| 記錄 | 說明 |
| --- | --- |
| 原始訊息引用 | 客戶或業務 LINE 訊息的安全引用或摘要 |
| AI 摘要版本 | AI 產生的需求解析與回覆草稿 |
| 草稿建立者 | AI/system/user |
| 業務修改 | 價格、交期、商品、數量、備註修改 |
| 客戶確認 | 確認時間、確認內容、入口 |
| 業務確認 | 確認者、時間、版本 |
| 正式訂單連結 | 從草稿轉正式訂單的 trace |

## 9. 風險控制

| 風險 | 控制 |
| --- | --- |
| 客戶用自然語言造成商品誤判 | 必須由業務確認，重要欄位缺漏需追問 |
| AI 亂報價 | AI 不可直接改價或成立報價，價格需來自採購平台與業務確認 |
| 客戶 LINE 被誤綁帳號 | 需有客戶帳號綁定與人工修正流程 |
| 業務被繞過 | 正式訂單需業務最終確認 |
| secrets 洩漏 | LINE Bot docs 與 logs 不得包含 secrets、tokens、`.env` |

## 10. Implementation Gate

進入 implementation phase 前需確認：

1. LINE 身分與客戶帳號綁定策略。
2. inquiry、quote、order draft、confirmed order 的狀態語義。
3. 業務 LINE 與 `/procurement-admin` 的確認責任分工。
4. AI-safe data access policy。
5. audit trail 與資料保留政策。
