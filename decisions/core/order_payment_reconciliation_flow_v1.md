# Order Payment Reconciliation Flow v1

## Status
Accepted

## Context

現行系統已明確區分：

- order（訂單）
- payment（付款）
- write-off / allocation（沖帳 / 分配）

但實務營運上，付款方式存在兩種本質不同的流程：

### 1. 自動確認型付款
例如：
- 信用卡付款連結
- LINE Pay
- 其他可由系統直接收到成功回執的支付方式

這類付款可由系統自動確認 payment success，並直接進入後續 reconciliation / allocation。

### 2. 人工對帳型付款
例如：
- 匯款
- 現金
- 其他需人工核對入帳的方式

這類付款不能因為「客戶聲稱已付款」或「上傳截圖」就直接視為已收款，必須經：
- 會計
- 業務
- 授權人員

進行人工對帳確認後，才可視為 confirmed payment。

若未明確定義這條流程，系統將容易混淆：

- order_status
- payment_status
- reconciliation_status
- shipment readiness

進而造成：
- 未付款即出貨
- 已付款但未沖帳
- 匯款誤認為已完成
- bot 催款 / 提醒邏輯錯亂

---

## Decision

系統採用 **Order / Payment / Reconciliation 三層分離模型**

### Layer 1：Order
描述商務交易本身

例如：
- draft
- confirmed
- shipped
- completed
- canceled

### Layer 2：Payment
描述付款事件本身

例如：
- pending
- paid_auto
- pending_verification
- confirmed_manual
- failed

### Layer 3：Reconciliation / Allocation
描述該筆付款是否已被正式核對並分配到訂單

例如：
- unallocated
- partially_allocated
- fully_allocated
- rejected
- disputed

---

## Core Rules

### Rule 1
`order_status` 不等於 `payment_status`

- 訂單成立 ≠ 已付款
- 訂單完成 ≠ 已付款
- 已出貨 ≠ 已付款

---

### Rule 2
`payment_status` 不等於 `reconciliation_status`

- 付款成功 ≠ 已對帳
- 匯款截圖 ≠ 已入帳
- 第三方支付成功 ≠ 已完成 allocation

---

### Rule 3
只有 reconciliation / allocation truth 可以用來判定 outstanding

真正的欠款 / 未結清金額，只能由：

- order total
- minus allocated payments

計算得出。

不得用以下條件推論欠款：
- 訂單很久以前建立
- 客戶未回覆
- payment link 尚未點擊
- 訂單仍為 draft / confirmed

---

## Payment Method Classes

### A. Auto-confirm payment methods
以下付款方式可由系統直接收到支付成功訊號：

- credit_card_link
- line_pay
- supported_online_gateway

這類支付成功後：
- `payment_status = paid_auto`
- 可直接建立 payment record
- 可進入 allocation flow
- 仍需保留 event / callback audit

---

### B. Manual-verification payment methods
以下付款方式需人工確認：

- bank_transfer
- cash
- other manual methods

這類付款流程：

1. 客戶提供付款資訊（匯款、截圖、說明）
2. 系統建立 payment record
   - `payment_status = pending_verification`
3. 由人工對帳
4. 對帳成功後改為：
   - `payment_status = confirmed_manual`
5. 再進入 allocation

---

## Recommended Payment Status Model

### payment_status
建議至少支持：

- `pending`
- `pending_verification`
- `paid_auto`
- `confirmed_manual`
- `failed`
- `rejected`

---

## Recommended Reconciliation / Allocation Model

### reconciliation_status（可在 payment 或 allocation summary 層表達）
建議至少支持：

- `unallocated`
- `partially_allocated`
- `fully_allocated`
- `disputed`
- `rejected`

---

## Canonical Flow

### Flow A：線上支付自動確認
1. 建立訂單
2. 建立 payment intent / payment link
3. 客戶完成付款
4. gateway callback 成功
5. 建立 payment
6. `payment_status = paid_auto`
7. 執行 allocation
8. outstanding 更新
9. 若 fulfillment policy 允許，可進入出貨流程

---

### Flow B：匯款人工對帳
1. 建立訂單
2. 客戶匯款
3. 客戶提供匯款資訊 / 截圖
4. 系統建立 payment
   - `payment_status = pending_verification`
5. 會計 / 業務人工確認
6. 確認成功後：
   - `payment_status = confirmed_manual`
7. 執行 allocation
8. outstanding 更新
9. 若 fulfillment policy 允許，可進入出貨流程

---

## Shipment / Fulfillment Rule

出貨 readiness 不得僅由 order_status 判定。

至少應考慮：
- payment 是否已成立
- reconciliation / allocation 是否完成
- outstanding 是否符合允許出貨的商業規則

系統可以允許不同商業政策，例如：
- 先款後貨
- 部分款可出
- 長期通路可賒帳

但這些應由明確商業規則決定，不得隱性推論。

---

## Bot / Reminder Rules

Bot 可以做：

- 發送付款連結
- 提醒客戶完成付款
- 提醒客戶提供匯款資訊
- 提醒內部人員有待對帳 payment
- 提醒 outstanding 仍存在

Bot 不可做：

- 僅憑 order age 判定欠款
- 僅憑未出貨判定未付款
- 僅憑 pending payment 就宣稱逾期
- 未經 reconciliation 就認定客戶欠款成立

---

## UI / UX Guidance

### 後台應顯示三種不同狀態
1. 訂單狀態
2. 付款狀態
3. 對帳 / 沖帳狀態

不得用單一 badge 取代三層狀態。

---

### 匯款型付款
應明確顯示：
- 等待對帳
- 已人工確認
- 已沖帳 / 未沖帳

---

### 自動支付型付款
應明確顯示：
- 已付款
- 已沖帳 / 未沖帳

---

## Non-Goals

本 decision 不處理：

- 發票邏輯
- 稅務邏輯
- 多幣別匯率結算
- 退款 / chargeback 全模型
- 完整會計分錄

這些可於後續 version 補充。

---

## Impact

### Backend
- payment write path 必須區分 auto-confirm vs manual-confirm
- allocation / reconciliation state 必須可查
- outstanding 必須由 allocation 計算

### Frontend
- order detail 頁面需呈現三層狀態
- 匯款型流程需有待對帳 UI
- 自動支付流程需有 callback result UI

### Operations
- 會計 / 業務需有人工確認入口
- bot / reminder 必須遵守 reconciliation boundary

 ### order_source_type（建議）
- manual_quote
- line_conversation
- facebook_message
- internal_created

---

## Summary

系統不是「下單 = 付款 = 出貨」。

正確模型是：

order ≠ payment ≠ reconciliation

只有在付款事實成立、且經過正確對帳 / allocation 後，
系統才能可靠地判斷 outstanding、付款完成與出貨 readiness。
