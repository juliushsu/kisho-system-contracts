# client_prerequisite_for_order_v1

## Status
Accepted

## Context

在 merchant orders write path (`create_merchant_order_v1`) 的設計中：

- `merchant_orders.client_id` 為 **required field**
- 但在部分 staging / 新組織環境中：
  - 尚未建立任何 client domain base
  - 或尚未有任何 merchant-scoped client row

導致：

- orders write verify 無法通過
- 無法建立合法訂單
- 系統出現「有訂單功能，但無法使用」的錯誤體驗

同時：

- `merchant_clients_v1` / `merchant_client_detail_v1` 已建立為 canonical read contract
- 但 read contract ≠ domain base（不可用於 write）

因此需要明確定義：

> **client 是 order domain 的前置條件（prerequisite），而非可選關聯**

---

## Decision

### 1. Order 必須依附 client

- `merchant_orders.client_id` 為 mandatory
- 不允許：
  - null client
  - anonymous order
  - fallback dummy client
  - UI 自動補預設 client

---

### 2. Client domain 是 Order write 的前置條件

系統必須保證：

```text
Before create_merchant_order_v1:
  at least 1 valid client exists in merchant scope

否則：
	•	write path 應 fail fast
	•	verify 不應被繞過
	•	不允許用 SQL fixture 偽造不存在的 domain

⸻

3. 新組織（onboarding）流程要求

對於新 merchant / org：

必須在 onboarding flow 中建立：
	•	至少一筆 client（manual 或匯入）

推薦最小 onboarding checklist：
	1.	建立組織 / 店面
	2.	建立至少一筆 client
	3.	建立商品 / 價格
	4.	才允許建立訂單

⸻

4. UI / UX Guard 要求

在 orders UI：

Create Order 前置檢查
若：

merchant_clients_v1(...) returns 0 rows

則：
	•	禁止進入建立訂單流程
	•	顯示提示：

「建立訂單前，請先建立客戶」

	•	必須提供 CTA：
	•	前往「客戶管理頁」

⸻

5. Verify 行為規則

orders write verify（如 038）：
	•	若無 client base：
	•	必須 fail
	•	不得：
	•	跳過檢查
	•	mock client
	•	假造 fixture（除非有真實 base table）

⸻

6. 禁止錯誤實作

以下為 forbidden：
	•	將 client_id 改為 nullable
	•	自動建立 hidden default client
	•	使用 fake client_id 進行測試
	•	用 read model (merchant_clients_v1) 當 write base
	•	用 debug SQL 直接繞過 domain

⸻

Implications

正向影響
	•	order domain 與 client domain 邊界清晰
	•	避免 orphan orders
	•	CRM / accounting / collection 流程可成立
	•	write path 行為 deterministic

負向影響
	•	onboarding 流程增加一個必要步驟
	•	staging 測試需先建立 client base
	•	verify 不再能「空資料通過」

⸻

Related Decisions
	•	merchant_read_contract_policy_v1
	•	data_boundary_rules_v1
	•	rpc_write_policy_v1
	•	merchant_orders_domain_boundary_v1
	•	order_payment_writeoff_boundary_v1

⸻

Summary（給工程快速理解）

No client → No order

client domain is a hard prerequisite of order write path
