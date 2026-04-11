# Platform Operating Model v1
## 酒商多租戶營運平台核心憲法

---

## A. 系統定位

本系統為：

> Multi-tenant 酒類供應鏈營運平台（SaaS）

不是單一酒商 ERP，而是：

- 共享商品池（Shared Catalog）
- 多酒商營運（Multi-merchant）
- 統一庫存系統（Shared Inventory Layer）
- AI 驅動營運輔助（AI-assisted operations）

---

## B. 多租戶原則（Multi-Tenant Isolation）

1. 每個酒商為一個獨立 org
2. org 之間：
   - 不共享客戶資料
   - 不共享訂單資料
   - 不共享業務行為
3. 平台可觀察（read），不可未授權寫入（write）

---

## C. 商品模型（Shared Catalog）

1. 商品為平台級資產：
   - product_master
   - product_variants
2. 酒商不擁有商品本體
3. 商品由平台維護與治理

---

## D. 銷售授權模型（Distribution Rights）

所有商品銷售權透過授權層控制：

- exclusive distributor（獨家代理）
- reseller（可銷售）
- platform（平台自營）

授權控制：

- 是否可販售
- 是否可採購
- 是否可查看成本
- 是否為獨家

---

## E. 庫存模型（Inventory Layer）

1. 庫存為平台共享資源
2. 使用 batch + position 模型：
   - inventory_batches
   - inventory_positions
3. position 三態：
   - location-backed
   - machine-backed
   - unshelved

4. inventory 為唯一 source of truth：

不得由：
- 訂單
- UI
- AI

直接修改

---

## F. 出貨模型（Shipment Layer）

Shipment 為獨立業務層：

### 職責：
- 承接 Order
- 決定出貨內容
- 關聯 Inventory

### 不負責：
- 不直接修改庫存（phase 1）
- 不等於 inventory movement

---

## G. 三層分離原則（Critical）

### 1. Order（業務）
- 客戶要什麼

### 2. Shipment（履約）
- 實際出什麼

### 3. Inventory（物理）
- 庫存怎麼變

👉 三層不可混用

---

## H. AI 使用原則

AI 角色為：

> 輔助決策（Assist），非資料來源（Source of Truth）

AI 可：

- 建議補貨
- 建議訂單
- 生成文件
- 分析銷售

AI 不可：

- 直接寫入 inventory
- 自動確認出貨
- 修改核心資料

---

## I. 平台角色（Platform Governance）

平台（母組織）：

- 可建立商品
- 可設定授權
- 可觀察所有 org
- 不得未授權操作 org 資料

---

## J. 收費模型（AI Quota）

每個 org：

- 有每月 AI 使用額度
- 超額需付費
- 平台可監控使用效率

---

## K. 核心設計原則（不可違反）

1. 不允許跨 org 資料污染
2. 不允許跳過 Distribution Rights
3. 不允許 Shipment 直接操作 Inventory（phase 1）
4. 不允許 AI 成為資料主來源
5. 所有操作必須可追溯（audit trail）

---

## L. 本文件優先級

本文件優先於：

- UI 設計
- API 設計
- DB schema
- feature spec

若有衝突，以本文件為準。
