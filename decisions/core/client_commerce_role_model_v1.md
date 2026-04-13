# Client Commerce Role Model v1

## Status
Accepted

## Context

現行系統中的 client_type（餐廳 / 酒吧 / 零售 / 通路）僅能描述「商業型態」，但無法描述：

- 一般消費者（散客）
- KOL / 合作對象
- 活動 / 專案客戶
- 長期經銷商 / 通路商

同一客戶同時可能具有多種身份（例如：餐廳 + KOL）。

若僅使用單一欄位（client_type），會導致：
- 無法支援不同定價策略
- 無法區分訂單流程（報價 / 贈品 / 合作）
- 無法支援未來 CRM / 行銷 / 分潤邏輯

---

## Decision

Client 模型拆分為三個維度：

### 1. client_type（商業型態）
描述客戶的「營業型態」

允許值（範例）：
- restaurant
- bar
- retail
- distributor

此欄位為「主要分類」，主要用於：
- 報表分析
- 商業結構分類

---

### 2. client_role（客戶角色）
描述客戶在交易中的「身份與關係」

允許多值（multi-tag）：

- individual（一般消費者）
- business（一般商業客戶）
- distributor（經銷）
- kol（KOL / influencer）
- partner（合作夥伴）
- event（活動 / 專案）

---

### 3. acquisition_channel（來源）
描述客戶來源

- line
- facebook
- website
- referral
- offline
- other

---

## Rules

1. 不得用 client_type 取代 client_role  
2. client_role 必須允許多選（multi-tag）  
3. UI 應區分：
   - 商業型態（單選）
   - 客戶角色（多選）  
4. 後端不得假設 client_type 可決定 pricing / flow  

---

## Impact

### Backend
- `public.clients` 未來需支援：
  - client_role（array 或 join table）
  - acquisition_channel

### Frontend
- 客戶建立 UI 需拆成：
  - 商業型態（dropdown）
  - 客戶角色（multi-select chips）

### Business Logic
- pricing / order / promotion 必須依 client_role 判斷  
- 不得再依單一 client_type 決策  

---

## Summary

client_type ≠ 客戶身份  
client_role 才是交易邏輯的核心依據
