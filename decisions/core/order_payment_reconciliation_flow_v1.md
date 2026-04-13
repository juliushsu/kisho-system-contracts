定義付款與對帳流程。

要寫清楚：
	•	線上刷卡 / Line Pay 成功 → 可自動確認付款
	•	匯款 / 現金 → 必須人工對帳
	•	order_status 不等於 payment_status
	•	payment_status 不等於 reconciliation_status
	•	出貨判定應依付款事實與人工確認規則

也要寫：
	•	催款 bot 不可只憑 order age 判定欠款
	•	催款必須建立在 accounting truth 上
