-- Procurement Phase 3B-1 RLS denial test draft.
--
-- Scope:
-- - Documentation / dry-run package only.
-- - Not executed in this round.
-- - Use only in a disposable Supabase-compatible environment or approved staging.
-- - Requires schema skeleton and fictional seed to be applied first.
-- - Do not run against production.
-- - No secrets, env values, real customers, LINE, AI pricing, API routes, or Readdy UI.

-- ---------------------------------------------------------------------------
-- Fictional actor IDs from procurement_phase3b1_fictional_seed.sql
-- ---------------------------------------------------------------------------

-- customer_user_alpha: 00000000-0000-4000-8000-00000000c101
-- customer_user_beta:  00000000-0000-4000-8000-00000000c202
-- sales_rep_alpha:     00000000-0000-4000-8000-000000005101
-- sales_rep_expired:   00000000-0000-4000-8000-000000005202

-- ---------------------------------------------------------------------------
-- Harness notes
-- ---------------------------------------------------------------------------

-- These examples are written as SQL snippets for a reviewer/tester to adapt.
-- In Supabase/PostgREST-style RLS tests, auth.uid() is usually driven by:
--
--   select set_config('request.jwt.claim.sub', '<actor uuid>', true);
--   set local role authenticated;
--
-- Expected PASS often means count = 0, or permission denied for tables that
-- have no authenticated grant. Run each scenario in its own transaction so an
-- expected permission-denied result does not abort the rest of the test file.

-- ---------------------------------------------------------------------------
-- Test 1: customer user cannot read another customer
-- ---------------------------------------------------------------------------

-- begin;
-- set local role authenticated;
-- select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-00000000c101', true);
-- select count(*) as should_be_zero
-- from public.procurement_customers
-- where id = '00000000-0000-4000-8000-000000010002';
-- rollback;

-- Expected: 0 rows visible.

-- ---------------------------------------------------------------------------
-- Test 2: customer user cannot read sales_assignments base table
-- ---------------------------------------------------------------------------

-- begin;
-- set local role authenticated;
-- select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-00000000c101', true);
-- select count(*) as should_be_zero
-- from public.procurement_sales_assignments;
-- rollback;

-- Expected: 0 rows visible.

-- ---------------------------------------------------------------------------
-- Test 3: customer user cannot read quote_requests base table
-- ---------------------------------------------------------------------------

-- begin;
-- set local role authenticated;
-- select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-00000000c101', true);
-- select count(*) as should_be_zero
-- from public.procurement_quote_requests;
-- rollback;

-- Expected: 0 rows visible. Future customer-facing request status should use
-- a safe read model/view, not the base table.

-- ---------------------------------------------------------------------------
-- Test 4: customer user cannot read quote_drafts
-- ---------------------------------------------------------------------------

-- begin;
-- set local role authenticated;
-- select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-00000000c101', true);
-- select count(*) as should_be_zero
-- from public.procurement_quote_drafts;
-- rollback;

-- Expected: 0 rows visible.

-- ---------------------------------------------------------------------------
-- Test 5: sales rep can read assigned customer inside effective window
-- ---------------------------------------------------------------------------

-- begin;
-- set local role authenticated;
-- select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000005101', true);
-- select count(*) as should_be_one
-- from public.procurement_customers
-- where id = '00000000-0000-4000-8000-000000010001';
-- rollback;

-- Expected: 1 row visible.

-- ---------------------------------------------------------------------------
-- Test 6: sales rep cannot read unassigned customer
-- ---------------------------------------------------------------------------

-- begin;
-- set local role authenticated;
-- select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000005101', true);
-- select count(*) as should_be_zero
-- from public.procurement_customers
-- where id = '00000000-0000-4000-8000-000000010002';
-- rollback;

-- Expected: 0 rows visible.

-- ---------------------------------------------------------------------------
-- Test 7: expired sales assignment does not grant customer access
-- ---------------------------------------------------------------------------

-- begin;
-- set local role authenticated;
-- select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000005202', true);
-- select count(*) as should_be_zero
-- from public.procurement_customers
-- where id = '00000000-0000-4000-8000-000000010002';
-- rollback;

-- Expected: 0 rows visible because effective_to is in the past.

-- ---------------------------------------------------------------------------
-- Test 8: authenticated cannot read audit_events
-- ---------------------------------------------------------------------------

-- begin;
-- set local role authenticated;
-- select set_config('request.jwt.claim.sub', '00000000-0000-4000-8000-000000005101', true);
-- select count(*)
-- from public.procurement_audit_events;
-- rollback;

-- Expected: permission denied, or 0 visible if a test harness wraps errors.
-- The Phase 3B-1 skeleton grants no authenticated SELECT on audit_events.

-- ---------------------------------------------------------------------------
-- Test 9: anon cannot read any procurement table
-- ---------------------------------------------------------------------------

-- begin;
-- set local role anon;
-- select count(*) from public.procurement_customers;
-- select count(*) from public.procurement_customer_locations;
-- select count(*) from public.procurement_customer_users;
-- select count(*) from public.procurement_sales_assignments;
-- select count(*) from public.procurement_products;
-- select count(*) from public.procurement_product_variants;
-- select count(*) from public.procurement_quote_requests;
-- select count(*) from public.procurement_quote_drafts;
-- select count(*) from public.procurement_quote_draft_items;
-- select count(*) from public.procurement_audit_events;
-- rollback;

-- Expected: permission denied for every procurement table.
