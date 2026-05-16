-- Procurement Phase 3B-1 staging-only rollback draft.
--
-- Scope:
-- - Rollback companion for 20260516_procurement_phase3b1_schema_skeleton.sql.
-- - Staging-only. Do not run against production.
-- - Do not run unless CTO explicitly approves the rollback execution.
-- - Only procurement_* policies, triggers, tables, and helper functions are touched.
-- - This file does not drop extensions, roles, auth objects, storage objects, secrets,
--   API routes, Edge Functions, LINE integration, AI automation, or Readdy UI objects.

begin;

-- ---------------------------------------------------------------------------
-- Drop RLS policies first
-- ---------------------------------------------------------------------------

drop policy if exists procurement_quote_draft_items_assigned_sales_select
  on public.procurement_quote_draft_items;

drop policy if exists procurement_quote_drafts_assigned_sales_select
  on public.procurement_quote_drafts;

drop policy if exists procurement_quote_requests_customer_or_sales_select
  on public.procurement_quote_requests;

drop policy if exists procurement_product_variants_org_visible_select
  on public.procurement_product_variants;

drop policy if exists procurement_products_org_visible_select
  on public.procurement_products;

drop policy if exists procurement_sales_assignments_self_or_customer_select
  on public.procurement_sales_assignments;

drop policy if exists procurement_customer_users_own_or_assigned_sales_select
  on public.procurement_customer_users;

drop policy if exists procurement_customer_locations_customer_or_sales_select
  on public.procurement_customer_locations;

drop policy if exists procurement_customers_customer_or_sales_select
  on public.procurement_customers;

-- Phase 3B-1 intentionally has no audit_events SELECT policy.

-- ---------------------------------------------------------------------------
-- Drop triggers before tables/functions
-- ---------------------------------------------------------------------------

drop trigger if exists procurement_quote_draft_items_set_updated_at
  on public.procurement_quote_draft_items;

drop trigger if exists procurement_quote_drafts_set_updated_at
  on public.procurement_quote_drafts;

drop trigger if exists procurement_quote_requests_set_updated_at
  on public.procurement_quote_requests;

drop trigger if exists procurement_product_variants_set_updated_at
  on public.procurement_product_variants;

drop trigger if exists procurement_products_set_updated_at
  on public.procurement_products;

drop trigger if exists procurement_sales_assignments_set_updated_at
  on public.procurement_sales_assignments;

drop trigger if exists procurement_customer_users_set_updated_at
  on public.procurement_customer_users;

drop trigger if exists procurement_customer_locations_set_updated_at
  on public.procurement_customer_locations;

drop trigger if exists procurement_customers_set_updated_at
  on public.procurement_customers;

-- ---------------------------------------------------------------------------
-- Drop helper functions after dependent policies/triggers are gone
-- ---------------------------------------------------------------------------

drop function if exists public.procurement_can_read_quote_draft(uuid, uuid);
drop function if exists public.procurement_user_has_org_read_access(uuid, uuid);
drop function if exists public.procurement_is_sales_rep_for_customer_at(uuid, uuid, timestamptz);
drop function if exists public.procurement_is_customer_user_for_customer(uuid, uuid);
drop function if exists public.procurement_current_user_id();
drop function if exists public.procurement_set_updated_at();

-- ---------------------------------------------------------------------------
-- Drop tables in reverse dependency order
-- ---------------------------------------------------------------------------

drop table if exists public.procurement_quote_draft_items;
drop table if exists public.procurement_quote_drafts;
drop table if exists public.procurement_quote_requests;
drop table if exists public.procurement_product_variants;
drop table if exists public.procurement_products;
drop table if exists public.procurement_sales_assignments;
drop table if exists public.procurement_customer_users;
drop table if exists public.procurement_customer_locations;
drop table if exists public.procurement_customers;
drop table if exists public.procurement_audit_events;

commit;
