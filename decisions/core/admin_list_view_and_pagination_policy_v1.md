A. 所有大型資料頁支援雙視圖

適用：
	•	clients
	•	products
	•	orders
	•	之後的 shipments / payments / reports 明細

B. 所有大型資料頁必須支援 pagination

不能預設一次抓全部。

C. 視圖切換不改資料來源

只能切換呈現方式，不得切換 query truth。

⸻

我建議的第一版規則

可以先定得很實用：

預設值
	•	clients：卡片預設，清單可切
	•	products：卡片預設，清單可切
	•	orders：清單預設，卡片可切

分頁
	•	卡片：12 / page
	•	清單：20 / page

排序

至少支援：
	•	最近更新
	•	名稱
	•	狀態

記憶偏好

同一使用者切換成清單後，下次回來保留上次視圖。
