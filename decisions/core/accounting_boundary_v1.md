Order domain != Payment domain

- merchant_orders 不代表付款狀態
- payment / settlement 必須獨立建模
- outstanding / overdue 不可用 order_status 推論
- AI 不可直接推論 payment fact
