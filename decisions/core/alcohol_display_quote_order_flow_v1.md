# Alcohol Display Quote Order Flow v1

## Status
Accepted

## Context

台灣法規限制：
- 酒類不得直接透過網路販售（完成交易）

但實務營運需求：
- 前台需展示商品（酒款）
- 客戶透過 LINE / Facebook / 其他通訊工具聯繫
- 業務 / 小編進行報價與確認
- 再透過付款連結完成交易

因此系統不能採用「純電商 checkout flow」，而需支援：

👉 展示 → 聯繫 → 報價 → 確認 → 付款 → 出貨

---

## Decision

系統採用 **Display + Quote-based Commerce Model**

---

## Flow Definition

### Step 1：商品展示（Display）
- 前台可公開展示酒款資訊
- 包含：
  - 品牌 / 酒廠
  - 酒款名稱
  - 圖片
  - 規格
- 不構成直接交易行為

---

### Step 2：客戶聯繫（Contact）
客戶透過：
- LINE
- Facebook Messenger
- 電話
- 其他方式

與商家聯繫

---

### Step 3：人工報價（Quote）
由：
- 業務
- 小編

進行：
- 價格確認
- 庫存確認
- 交易條件確認

---

### Step 4：建立訂單（Order Creation）
後台建立訂單：

- 指定 client
- 加入商品（merchant_products）
- 設定價格（unit_price）

---

### Step 5：付款（Payment）
兩種模式：

#### (A) 線上付款
- LINE Pay / 信用卡連結
- 可自動更新 payment_status = paid

#### (B) 匯款 / 現金
- 需人工對帳
- payment_status = pending → confirmed（人工）

---

### Step 6：出貨（Fulfillment）
依付款狀態與對帳結果進行出貨

---

## Rules

1. 前台不得直接形成酒類交易（no direct checkout）  
2. 所有訂單必須有 client（不可匿名結帳）  
3. 訂單建立可由人工觸發  
4. 系統必須允許「報價 → 再建立訂單」  
5. payment_status 與 order_status 必須分離  

---

## Non-Goals

本系統不做：
- 即時電商 checkout（酒類）
- 未經人工確認的自動成交
- 無 client 的訂單流程

---

## Impact

### Backend
- 必須支援：
  - 手動建立訂單
  - 可覆寫價格
  - payment 與 reconciliation 分離

### Frontend
- 前台：
  - 顯示商品
  - 提供聯繫入口（LINE / FB）
- 後台：
  - 強化訂單建立 UX
  - 支援人工流程

---

## Summary

這不是電商系統  
這是「展示 + 報價 + 人工確認」的交易系統
