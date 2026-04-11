A. 模型核心

本系統採用 multi-merchant + shared inventory + controlled distribution rights 架構：
	1.	每個酒商為獨立 org（multi-tenant）
	2.	商品為平台級共享（product_master / variant）
	3.	銷售權由 org 層授權（distribution rights）
	4.	庫存為共享池（inventory layer），由 allocation 控制使用

⸻

B. 商品授權模型

商品銷售權透過 distribution layer 控制：
	•	exclusive distributor（獨家）
	•	reseller（可銷售）
	•	platform（平台自營）

平台可在無代理商時直接銷售，代理建立後依授權調整。

⸻

C. 庫存模型

庫存不隸屬單一 org，而是平台共享資源：
	•	使用 inventory_positions 管理位置
	•	使用 allocation / reservation 控制出貨
	•	shipment layer 作為 outbound bridge

⸻

D. AI 使用策略

每個 org 配置：
	•	每月基本 AI quota
	•	超額付費
	•	使用範圍：
	•	銷售
	•	庫存
	•	採購（供應鏈）

平台保留監控與優化建議權限。

⸻

E. 平台角色

平台（母組織）：
	•	可觀察所有 org
	•	不得未授權寫入 org 資料
	•	可作為商品 owner / distributor
