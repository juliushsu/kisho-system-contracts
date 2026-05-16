-- Procurement Phase 3B-1 fictional staging seed draft.
--
-- Scope:
-- - Fictional data only.
-- - Staging/disposable dry-run only.
-- - Do not run against production.
-- - Do not use real customers, real sales reps, real products, real liquor names,
--   real aged meat items, real supplier data, or real prices.
-- - This file is not executed in the package-preparation round.

begin;

-- ---------------------------------------------------------------------------
-- Fixed fictional UUIDs for repeatable dry-run review
-- ---------------------------------------------------------------------------

-- Organization:
-- 00000000-0000-4000-8000-000000000001
--
-- Customer users:
-- 00000000-0000-4000-8000-00000000c101
-- 00000000-0000-4000-8000-00000000c202
--
-- Sales reps:
-- 00000000-0000-4000-8000-000000005101
-- 00000000-0000-4000-8000-000000005202

insert into public.procurement_customers (
  id,
  organization_id,
  customer_code,
  display_name,
  status,
  identity_status
)
values
  (
    '00000000-0000-4000-8000-000000010001',
    '00000000-0000-4000-8000-000000000001',
    'FICT-CUST-ALPHA',
    'Fictional Customer Alpha Kitchen',
    'active',
    'active'
  ),
  (
    '00000000-0000-4000-8000-000000010002',
    '00000000-0000-4000-8000-000000000001',
    'FICT-CUST-BETA',
    'Fictional Customer Beta Table',
    'active',
    'active'
  );

insert into public.procurement_customer_locations (
  id,
  organization_id,
  customer_id,
  label,
  location_type,
  address_json,
  receiving_notes,
  status
)
values
  (
    '00000000-0000-4000-8000-000000020001',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000010001',
    'Fictional Alpha Main Location',
    'branch',
    '{"city":"Fictional City","line1":"Fictional Address 1"}'::jsonb,
    'Fictional receiving note only',
    'active'
  ),
  (
    '00000000-0000-4000-8000-000000020002',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000010002',
    'Fictional Beta Main Location',
    'branch',
    '{"city":"Fictional City","line1":"Fictional Address 2"}'::jsonb,
    'Fictional receiving note only',
    'active'
  );

insert into public.procurement_customer_users (
  id,
  organization_id,
  customer_id,
  user_id,
  display_name,
  role,
  scoped_location_ids,
  status
)
values
  (
    '00000000-0000-4000-8000-000000030001',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000010001',
    '00000000-0000-4000-8000-00000000c101',
    'Fictional Customer User Alpha',
    'buyer',
    array['00000000-0000-4000-8000-000000020001']::uuid[],
    'active'
  ),
  (
    '00000000-0000-4000-8000-000000030002',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000010002',
    '00000000-0000-4000-8000-00000000c202',
    'Fictional Customer User Beta',
    'buyer',
    array['00000000-0000-4000-8000-000000020002']::uuid[],
    'active'
  );

insert into public.procurement_sales_assignments (
  id,
  organization_id,
  customer_id,
  customer_location_id,
  sales_rep_user_id,
  assignment_scope,
  effective_from,
  effective_to,
  status
)
values
  (
    '00000000-0000-4000-8000-000000040001',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000010001',
    '00000000-0000-4000-8000-000000020001',
    '00000000-0000-4000-8000-000000005101',
    'customer',
    '2026-01-01 00:00:00+00',
    null,
    'active'
  ),
  (
    '00000000-0000-4000-8000-000000040002',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000010002',
    '00000000-0000-4000-8000-000000020002',
    '00000000-0000-4000-8000-000000005202',
    'customer',
    '2026-01-01 00:00:00+00',
    '2026-02-01 00:00:00+00',
    'active'
  );

insert into public.procurement_products (
  id,
  organization_id,
  product_code,
  name,
  category,
  source_domain,
  status,
  is_customer_visible
)
values
  (
    '00000000-0000-4000-8000-000000050001',
    '00000000-0000-4000-8000-000000000001',
    'FICT-PROD-SAKE-001',
    'Fictional Product Sake Category Sample',
    'sake',
    'procurement',
    'active',
    true
  ),
  (
    '00000000-0000-4000-8000-000000050002',
    '00000000-0000-4000-8000-000000000001',
    'FICT-PROD-TABLE-001',
    'Fictional Product Tableware Category Sample',
    'tableware',
    'procurement',
    'active',
    true
  ),
  (
    '00000000-0000-4000-8000-000000050003',
    '00000000-0000-4000-8000-000000000001',
    'FICT-PROD-MEAT-001',
    'Fictional Product Meat Category Sample',
    'meat',
    'procurement',
    'active',
    true
  );

-- Product variants are required for quote draft item FK references.
insert into public.procurement_product_variants (
  id,
  organization_id,
  product_id,
  variant_code,
  name,
  unit,
  pack_size,
  supply_type,
  status,
  is_customer_visible
)
values
  (
    '00000000-0000-4000-8000-000000060001',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000050001',
    'FICT-VAR-SAKE-001',
    'Fictional Variant Sake Sample',
    'case',
    'fictional pack',
    'supplier_sourced',
    'active',
    true
  ),
  (
    '00000000-0000-4000-8000-000000060002',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000050002',
    'FICT-VAR-TABLE-001',
    'Fictional Variant Tableware Sample',
    'set',
    'fictional pack',
    'supplier_sourced',
    'active',
    true
  ),
  (
    '00000000-0000-4000-8000-000000060003',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000050003',
    'FICT-VAR-MEAT-001',
    'Fictional Variant Meat Sample',
    'box',
    'fictional pack',
    'supplier_sourced',
    'active',
    true
  );

insert into public.procurement_quote_requests (
  id,
  organization_id,
  customer_id,
  customer_location_id,
  source_channel,
  status,
  requested_summary,
  requested_items,
  risk_flags,
  assigned_sales_rep_id,
  received_at
)
values
  (
    '00000000-0000-4000-8000-000000070001',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000010001',
    '00000000-0000-4000-8000-000000020001',
    'manual',
    'drafting',
    'Fictional Alpha request for sample procurement items',
    '[{"item":"fictional sample item A"},{"item":"fictional sample item B"}]'::jsonb,
    '[]'::jsonb,
    '00000000-0000-4000-8000-000000005101',
    '2026-05-16 00:00:00+00'
  ),
  (
    '00000000-0000-4000-8000-000000070002',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000010002',
    '00000000-0000-4000-8000-000000020002',
    'manual',
    'received',
    'Fictional Beta request for sample procurement items',
    '[{"item":"fictional sample item C"}]'::jsonb,
    '[]'::jsonb,
    null,
    '2026-05-16 00:00:00+00'
  );

insert into public.procurement_quote_drafts (
  id,
  organization_id,
  quote_request_id,
  customer_id,
  status,
  approval_status,
  created_by_user_id,
  created_by_role,
  assigned_sales_rep_id,
  draft_total_amount,
  currency,
  risk_flags,
  internal_notes
)
values (
  '00000000-0000-4000-8000-000000080001',
  '00000000-0000-4000-8000-000000000001',
  '00000000-0000-4000-8000-000000070001',
  '00000000-0000-4000-8000-000000010001',
  'draft',
  'not_submitted',
  '00000000-0000-4000-8000-000000005101',
  'user',
  '00000000-0000-4000-8000-000000005101',
  null,
  'TWD',
  '[]'::jsonb,
  'Fictional internal note for dry-run only'
);

insert into public.procurement_quote_draft_items (
  id,
  organization_id,
  quote_draft_id,
  variant_id,
  item_text,
  quantity,
  unit,
  draft_unit_price,
  currency,
  pricing_basis,
  margin_flag,
  notes,
  sort_order
)
values
  (
    '00000000-0000-4000-8000-000000090001',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000080001',
    '00000000-0000-4000-8000-000000060001',
    'Fictional quote draft item A',
    2,
    'case',
    null,
    'TWD',
    'fictional placeholder',
    'none',
    'No real price',
    1
  ),
  (
    '00000000-0000-4000-8000-000000090002',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000080001',
    '00000000-0000-4000-8000-000000060002',
    'Fictional quote draft item B',
    1,
    'set',
    null,
    'TWD',
    'fictional placeholder',
    'none',
    'No real price',
    2
  );

insert into public.procurement_audit_events (
  id,
  organization_id,
  actor_user_id,
  actor_role,
  event_type,
  target_table,
  target_id,
  customer_id,
  before_snapshot,
  after_snapshot,
  approval_ref,
  idempotency_key,
  metadata
)
values
  (
    '00000000-0000-4000-8000-0000000a0001',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000005101',
    'fictional_sales_rep',
    'fictional_quote_request_created',
    'procurement_quote_requests',
    '00000000-0000-4000-8000-000000070001',
    '00000000-0000-4000-8000-000000010001',
    null,
    '{"status":"drafting"}'::jsonb,
    null,
    'fictional-seed-audit-001',
    '{"fictional":true}'::jsonb
  ),
  (
    '00000000-0000-4000-8000-0000000a0002',
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000005101',
    'fictional_sales_rep',
    'fictional_quote_draft_created',
    'procurement_quote_drafts',
    '00000000-0000-4000-8000-000000080001',
    '00000000-0000-4000-8000-000000010001',
    null,
    '{"status":"draft","approval_status":"not_submitted"}'::jsonb,
    null,
    'fictional-seed-audit-002',
    '{"fictional":true}'::jsonb
  ),
  (
    '00000000-0000-4000-8000-0000000a0003',
    '00000000-0000-4000-8000-000000000001',
    null,
    'fictional_system',
    'fictional_seed_loaded',
    'procurement_audit_events',
    '00000000-0000-4000-8000-0000000a0003',
    null,
    null,
    '{"seed":"fictional_phase3b1"}'::jsonb,
    null,
    'fictional-seed-audit-003',
    '{"fictional":true}'::jsonb
  );

commit;
