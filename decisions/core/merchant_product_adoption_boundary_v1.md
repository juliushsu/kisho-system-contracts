這份用來釘死：
	•	catalog 商品
	•	merchant adopted 商品
	•	order 可選商品

三者不同。

要寫清楚：
	•	merchant_catalog_v1 = 可賣
	•	merchant_products = 已採納要賣
	•	ProductPicker 只能讀 merchant adopted products
	•	不可直接從 catalog 商品建 order
