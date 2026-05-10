# Readdy VER289 Frontend Alignment Contract v1

## Source

- Source package: Readdy `皇上吉祥-VER289`
- Reviewed on: 2026-05-10
- Scope: frontend routes, service-layer contracts, Supabase table/RPC surfaces, Edge Function boundaries, and public documentation safety

## Security Handling

The source package includes a `.env` file. This contract intentionally records only variable names and required boundaries.

Never publish:

- actual `.env` values
- Supabase anon key values
- Supabase service role key values
- JWTs, bearer tokens, passwords, private keys, or copied auth headers

Allowed public references:

- environment variable names
- route names
- table/view/RPC/function names
- role names
- behavior and boundary rules

## Stack

- React 19
- Vite 7
- TypeScript 5.8
- React Router 7
- Supabase JS 2.57
- Tailwind CSS
- i18next
- Chart.js / Recharts

## Required Environment Variables

Frontend build/runtime may reference these variable names:

- `VITE_PUBLIC_SUPABASE_URL`
- `VITE_PUBLIC_SUPABASE_ANON_KEY`
- `VITE_FF_INTERNAL_DEBUG`
- `VITE_SITE_URL`

Rules:

1. Public docs may mention the names above, not their values.
2. `VITE_PUBLIC_SUPABASE_ANON_KEY` is client-side publishable by design, but still must not be copied into public contracts.
3. `SUPABASE_SERVICE_ROLE_KEY` is allowed only inside Supabase Edge Function runtime. It must never appear in frontend code or public docs.
4. Debug endpoints must be guarded by `VITE_FF_INTERNAL_DEBUG` and normal Supabase session authorization.

## Route Surface

### Public Marketing Routes

- `/`
- `/about`
- `/products`
- `/contact`

### Public Storefront Routes

- `/store/:slug`
- `/store/:slug/catalog`
- `/store/:slug/p/:variant_id`

Storefront read path:

- `merchant_storefronts`
- `merchant_org_variants`
- `v_variant_catalog`

### Admin Base Routes

- `/admin/login`
- `/admin/stores`
- `/admin/stores/:id/hourly`
- `/admin/devices`
- `/admin/devices/:id`
- `/admin/sake-products`
- `/admin/reports`
- `/admin/top10`
- `/admin/machine-monitor`

### Merchant Routes

- `/admin/merchant/catalog`
- `/admin/merchant/brands`
- `/admin/merchant/products`
- `/admin/merchant/clients`
- `/admin/merchant/orders`
- `/admin/merchant/reports`
- `/admin/merchant/storefront`
- `/admin/merchant/machine-config`

### Operations Routes

- `/admin/catalog/import-review`
- `/admin/agent-workspace`
- `/admin/shipment`
- `/admin/shipment/:id`
- `/admin/inventory`
- `/admin/inventory/receipts`
- `/admin/inventory/receipts/:id`
- `/admin/inventory/batches`
- `/admin/inventory/movements`

## Auth And Org Scope

### Roles

VER289 recognizes:

- `admin`
- `store_owner`

Role source:

- `user_roles.role`

Org membership source:

- `merchant_org_users`
- `merchant_orgs`

Rules:

1. Authenticated users without a role must be redirected to `/admin/login`.
2. `admin` may switch merchant org context.
3. `store_owner` must resolve to its own org context.
4. Merchant routes must be disabled when a non-admin user has no active org.
5. Cross-org reads/writes are forbidden unless explicitly part of admin governance.

### Temporary Org Identity Alignment

VER289 continues to use a temporary alignment where operational `orgId` may equal `stores.id` in selected inventory/shipment flows.

Rules:

1. Keep this alignment documented as temporary.
2. Do not silently mix `merchant_orgs.org_id`, `stores.id`, and `merchant_id`.
3. Service functions must state which identity they accept.

## Service Layer Rule

Page components should call service-layer functions for merchant domains.

Rules:

1. Pages must not introduce new ad hoc Supabase RPC or table access for merchant domains when a service exists.
2. Canonical read RPC/view contracts should be wrapped by service files.
3. Transitional direct writes must be documented and replaced by RPCs when backend contracts are ready.

Primary service files in VER289:

- `catalogService.ts`
- `brandsService.ts`
- `productsService.ts`
- `clientsService.ts`
- `ordersService.ts`
- `storefrontService.ts`
- `machineAssignmentService.ts`
- `machineInventoryService.ts`
- `inventoryService.ts`
- `shipmentService.ts`
- `importReviewService.ts`
- `agentWorkspaceService.ts`
- `orgResolver.ts`

## Catalog And Product Contract

Canonical shared catalog remains platform-owned.

Frontend read/write surfaces include:

- `get_catalog_for_org`
- `get_merchant_products`
- `get_merchant_brands`
- `get_merchant_brand_variants`
- `v_variant_catalog`
- `merchant_org_variants`
- `merchant_org_brands`
- `merchant_products`
- `merchant_product_overrides`
- `product_master`
- `product_variants`
- `core_breweries`
- `core_brands`
- `core_products`
- `core_variants`

Rules:

1. Catalog identity is global/platform-owned.
2. Merchant adoption/listing is org-scoped.
3. Product picker for merchant orders must use `v_merchant_product_sale_canonical_v1`, not legacy catalog views.
4. Price fields named `*_minor` are minor currency units and must be divided for display only.

## Storefront Contract

Storefront management uses:

- `merchant_storefronts`
- `merchant_storefront_product_listings`
- storage bucket `storefront-assets`

Rules:

1. `storefrontId` means `merchant_storefronts.id`.
2. Public storefront pages must read active storefront/listing data only.
3. Storage upload policies for `storefront-assets` must be reviewed before public launch.
4. Storefront settings must not expose private merchant configuration beyond intended public fields.

## Client Contract

Canonical client reads:

- `merchant_clients_v1`
- `merchant_client_detail_v1`

Canonical client create:

- `create_client_v1`

Transitional direct tables still present:

- `merchant_clients`
- `merchant_client_shop_links`
- `stores`
- `devices`

Rules:

1. `client_role` is single-value in v1.
2. Client list/detail reads must prefer RPCs.
3. `updateClient` and active toggle paths that still write `merchant_clients` are transitional.
4. Shop links remain a supplemental read until `merchant_client_detail_v1` includes the needed fields.

## Order Contract

Canonical reads:

- `merchant_orders_v1`
- `merchant_order_detail_v1`
- `client_financial_dashboard_v1`
- `v_merchant_product_sale_canonical_v1`

Transitional direct writes detected in VER289:

- `merchant_orders`
- `merchant_order_items`

Rules:

1. Order list and detail must read through canonical RPCs.
2. Order product picker must read `v_merchant_product_sale_canonical_v1`.
3. Frontend direct insert/update of `merchant_orders` and `merchant_order_items` remains a forbidden transitional pattern.
4. Backend should provide create/update order RPCs before the direct write path is considered stable.

## Shipment Contract

VER289 service status:

- `SHIPMENT_BACKEND_READY = true`
- `shipments`, `shipment_lines`, and `shipment_allocations` are treated as available by `shipmentService.ts`

Read surfaces:

- `shipments`
- `shipment_lines`
- `shipment_allocations`
- `inventory_batches`
- `inventory_positions`
- `v_inventory_stock_by_batch_v1`
- `business_entities`
- `suppliers`
- `core_variants`

Write RPCs:

- `create_shipment_v1`
- `mark_shipment_ready_v1`
- `dispatch_shipment_v1`

Status values:

- `draft`
- `confirmed`
- `allocated`
- `ready_to_ship`
- `dispatched`
- `delivered`
- `cancelled`

Shipment methods:

- `sales_direct`
- `courier`
- `pickup`

Rules:

1. Shipment is not Order.
2. Shipment is not Inventory Movement.
3. Dispatch confirmation must not be treated as frontend inventory deduction.
4. Shipment writes must use RPCs.
5. `src/types/shipment.ts` still contains stale comments describing shipment as a stub; code comments should be cleaned to match the VER289 service state.

## Inventory Contract

Read surfaces:

- `v_inventory_stock_by_variant_v1`
- `v_inventory_stock_by_location_v1`
- `v_inventory_stock_by_batch_v1`
- `v_inventory_movement_history_by_batch_v1`
- `inventory_receipts`
- `inventory_receipt_lines`
- `inventory_batches`
- `inventory_positions`
- `inventory_movements`
- `inventory_containers`
- `locations`
- `suppliers`

Movement semantics:

- `inbound`
- `shelf`
- `transfer`
- `load_machine`
- `dispense`
- `adjust`

Position states:

- location-backed: `location_id IS NOT NULL`
- machine-backed: `machine_id IS NOT NULL`
- unshelved: `location_id IS NULL AND machine_id IS NULL`

Rules:

1. Inventory remains the physical source of truth.
2. Shipment allocation may reference inventory batches/positions.
3. Dispatch must not mutate inventory from frontend code.
4. Inventory read views are preferred for dashboards and summaries.

## Machine Configuration Contract

Read surfaces:

- `machine_configurations`
- `machine_configuration_lines`
- `v_machine_assignment_canonical_v1`
- `v_machine_active_configuration_bridge_v1`
- `machine_assignment_history`
- `devices`
- `merchant_products`
- `product_variants`
- `product_master`

Write RPCs:

- `create_machine_configuration_draft_v1`
- `upsert_machine_configuration_line_v1`
- `publish_machine_configuration_v1`
- `deactivate_machine_assignment_v1`

Rules:

1. Active assignment changes must be atomic RPC writes.
2. Frontend must not manually multi-step insert/deactivate machine assignments.
3. `publish_machine_configuration_v1` is the canonical publish boundary.
4. `deactivate_machine_assignment_v1` is the canonical deactivate boundary.

## Import Review Contract

VER289 reads/writes:

- `external_sources`
- `external_import_runs`
- `external_products_raw`
- `staged_products`
- `staged_product_variants`
- `import_review_queue`
- `import_merge_actions`
- `create_external_import_run_v1`
- `stage_external_raw_product_v1`
- `apply_import_merge_action_v1`
- `finalize_external_import_run_v1`

Rules:

1. External product data must go through review before canonical catalog writes.
2. Original raw payload must remain auditable.
3. Cross-subject merge remains forbidden.
4. Existing contract docs mention `apply_live_import_review_action_v1`; VER289 code calls `apply_import_merge_action_v1`. The RPC name must be reconciled by backend/CTO before further implementation.

## AI Agent Workspace Contract

Read surfaces:

- `v_ai_org_inventory_summary`
- `merchant_org_variants`
- `core_variants`
- `core_products`
- `ai_tasks`
- `suppliers`
- `purchase_orders`
- `purchase_invoices`
- `purchase_payments`
- `shipments`
- `shipment_lines`
- `shipment_allocations`

Task action RPCs:

- `approve_ai_task_v1`
- `return_ai_task_to_draft_v1`
- `resolve_ai_task_v1`

Task states observed in VER289:

- `draft`
- `awaiting_human_review`
- `approved`
- `sent`
- `supplier_replied`
- `resolved`

Rules:

1. AI may suggest, summarize, and prepare actions.
2. Human review is required for action state transitions.
3. AI must not become source of truth for inventory, shipment, order, or payment data.
4. Procurement suggestions derived from stock levels are advisory, not automatic purchase orders.

## Admin Debug Contract

Debug drawer references:

- `/functions/v1/admin-debug/snapshot`
- `/functions/v1/admin-debug/product-flow`

Rules:

1. Debug drawer must stay behind `VITE_FF_INTERNAL_DEBUG`.
2. Debug requests must use the current Supabase session access token.
3. Logs may print token presence/length/prefix for local debugging only; public docs must never include token values.
4. Debug endpoints are operational observability tools, not user-facing product API.

## Edge Function Contract

VER289 includes:

- `create-store-user`

Runtime-only environment:

- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`

Behavior:

1. Accepts email, password, and store id.
2. Creates a Supabase auth user.
3. Writes `user_roles` with role `store_owner`.
4. Links the user to `stores.assigned_user_id`.
5. Rolls back created auth user if role/store assignment fails.

Rules:

1. Service role key must remain server-side only.
2. Frontend may call the Edge Function but must not hold service credentials.
3. Public docs must not include endpoint project URLs or key values copied from `.env`.

## External Public Form

The contact page posts to a Readdy public form endpoint.

Rules:

1. Treat this as an external integration.
2. Do not document hidden credentials because none are required by the frontend call.
3. If the contact workflow moves into platform backend, define a new owned API contract first.

## Open Reconciliation Items

1. Clean stale shipment stub comments in `src/types/shipment.ts`.
2. Reconcile import review RPC naming: `apply_live_import_review_action_v1` vs `apply_import_merge_action_v1`.
3. Replace merchant order direct write paths with create/update RPCs.
4. Clarify long-term identity boundary between `merchant_orgs.org_id`, `stores.id`, and merchant/storefront ids.
5. Confirm `storefront-assets` storage policy before public storefront rollout.
6. Verify whether legacy `sake_products` / `gateways` / `device_product_periods` pages remain canonical or are compatibility screens.
7. VER289 contains frontend and one Edge Function, but no DB migration/schema files; backend schema truth must be confirmed from the DB repository or Supabase migrations.

## Forbidden

- Publishing `.env` values
- Publishing service role keys
- Publishing JWTs or auth headers
- Adding frontend service-role usage
- Adding cross-org fallback reads
- Treating dispatch as inventory deduction
- Treating AI output as committed operational data
- Adding new direct page-level merchant DB access when a service boundary exists

## Version

v1.0 (2026-05-10)
