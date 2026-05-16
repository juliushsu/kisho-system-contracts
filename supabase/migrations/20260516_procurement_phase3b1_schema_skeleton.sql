-- Procurement Phase 3B-1 staging schema skeleton.
--
-- Scope:
-- - Staging-only migration draft implementation.
-- - Do not apply to production.
-- - Do not run this migration unless explicitly approved by CTO.
-- - No LINE integration, AI pricing automation, Readdy UI changes, production API routes,
--   formal order creation, or inventory mutation are included.
-- - No secrets, env values, or real customer seed data are included.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------------------
-- Shared timestamp helper
-- ---------------------------------------------------------------------------

create or replace function public.procurement_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Core customer identity tables
-- ---------------------------------------------------------------------------

create table if not exists public.procurement_customers (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  customer_code text,
  display_name text not null,
  segment text,
  status text not null default 'active'
    check (status in ('prospect', 'active', 'inactive', 'archived')),
  identity_status text not null default 'active'
    check (identity_status in ('active', 'review_required', 'duplicate_candidate', 'archived')),
  merge_candidate_of uuid,
  archived_at timestamptz,
  archived_reason text,
  tags jsonb not null default '[]'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint procurement_customers_org_id_unique unique (organization_id, id),
  constraint procurement_customers_merge_candidate_fk
    foreign key (organization_id, merge_candidate_of)
    references public.procurement_customers (organization_id, id)
    on delete set null
);

comment on table public.procurement_customers is
  'Phase 3B-1 staging-only procurement customer skeleton. Merge/dedup is not automated; merge_candidate_of is advisory only.';

create unique index if not exists procurement_customers_org_code_uidx
  on public.procurement_customers (organization_id, lower(customer_code))
  where customer_code is not null and archived_at is null;

create index if not exists procurement_customers_org_status_idx
  on public.procurement_customers (organization_id, status);

create index if not exists procurement_customers_org_display_name_idx
  on public.procurement_customers (organization_id, lower(display_name));

create index if not exists procurement_customers_merge_candidate_idx
  on public.procurement_customers (merge_candidate_of);

create trigger procurement_customers_set_updated_at
before update on public.procurement_customers
for each row execute function public.procurement_set_updated_at();

create table if not exists public.procurement_customer_locations (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  customer_id uuid not null,
  label text not null,
  location_type text not null default 'branch'
    check (location_type in ('headquarters', 'branch', 'billing', 'delivery', 'warehouse', 'other')),
  address_json jsonb not null default '{}'::jsonb,
  receiving_notes text,
  status text not null default 'active'
    check (status in ('active', 'inactive', 'archived')),
  archived_at timestamptz,
  archived_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint procurement_customer_locations_org_id_unique unique (organization_id, id),
  constraint procurement_customer_locations_org_customer_id_unique unique (organization_id, customer_id, id),
  constraint procurement_customer_locations_customer_fk
    foreign key (organization_id, customer_id)
    references public.procurement_customers (organization_id, id)
    on delete restrict
);

create index if not exists procurement_customer_locations_org_customer_idx
  on public.procurement_customer_locations (organization_id, customer_id);

create index if not exists procurement_customer_locations_customer_status_idx
  on public.procurement_customer_locations (customer_id, status);

create trigger procurement_customer_locations_set_updated_at
before update on public.procurement_customer_locations
for each row execute function public.procurement_set_updated_at();

create table if not exists public.procurement_customer_users (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  customer_id uuid not null,
  user_id uuid not null,
  display_name text,
  role text not null default 'buyer'
    check (role in ('owner', 'buyer', 'viewer', 'accounting')),
  scoped_location_ids uuid[] not null default '{}'::uuid[],
  status text not null default 'active'
    check (status in ('invited', 'active', 'suspended', 'archived')),
  archived_at timestamptz,
  archived_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint procurement_customer_users_org_id_unique unique (organization_id, id),
  constraint procurement_customer_users_customer_fk
    foreign key (organization_id, customer_id)
    references public.procurement_customers (organization_id, id)
    on delete restrict
);

create unique index if not exists procurement_customer_users_customer_user_uidx
  on public.procurement_customer_users (organization_id, customer_id, user_id)
  where archived_at is null;

create index if not exists procurement_customer_users_user_idx
  on public.procurement_customer_users (user_id);

create index if not exists procurement_customer_users_org_customer_idx
  on public.procurement_customer_users (organization_id, customer_id);

create trigger procurement_customer_users_set_updated_at
before update on public.procurement_customer_users
for each row execute function public.procurement_set_updated_at();

create table if not exists public.procurement_sales_assignments (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  customer_id uuid not null,
  customer_location_id uuid,
  sales_rep_user_id uuid not null,
  assignment_scope text not null default 'customer'
    check (assignment_scope in ('customer', 'location', 'coverage', 'product_line')),
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  status text not null default 'active'
    check (status in ('active', 'inactive', 'archived')),
  archived_at timestamptz,
  archived_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint procurement_sales_assignments_org_id_unique unique (organization_id, id),
  constraint procurement_sales_assignments_effective_window_chk
    check (effective_to is null or effective_to > effective_from),
  constraint procurement_sales_assignments_customer_fk
    foreign key (organization_id, customer_id)
    references public.procurement_customers (organization_id, id)
    on delete restrict,
  constraint procurement_sales_assignments_location_fk
    foreign key (organization_id, customer_id, customer_location_id)
    references public.procurement_customer_locations (organization_id, customer_id, id)
    on delete restrict
);

create index if not exists procurement_sales_assignments_org_sales_idx
  on public.procurement_sales_assignments (organization_id, sales_rep_user_id);

create index if not exists procurement_sales_assignments_customer_status_idx
  on public.procurement_sales_assignments (customer_id, status);

create index if not exists procurement_sales_assignments_effective_window_idx
  on public.procurement_sales_assignments (effective_from, effective_to);

create trigger procurement_sales_assignments_set_updated_at
before update on public.procurement_sales_assignments
for each row execute function public.procurement_set_updated_at();

-- ---------------------------------------------------------------------------
-- Product catalog skeleton
-- ---------------------------------------------------------------------------

create table if not exists public.procurement_products (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  product_code text,
  name text not null,
  category text not null
    check (category in ('sake', 'tableware', 'meat', 'seafood', 'other')),
  source_domain text not null default 'procurement'
    check (source_domain in ('procurement', 'sake', 'meat', 'external')),
  status text not null default 'active'
    check (status in ('active', 'inactive', 'archived')),
  is_customer_visible boolean not null default false,
  archived_at timestamptz,
  archived_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint procurement_products_org_id_unique unique (organization_id, id)
);

create unique index if not exists procurement_products_org_code_uidx
  on public.procurement_products (organization_id, lower(product_code))
  where product_code is not null and archived_at is null;

create index if not exists procurement_products_org_category_idx
  on public.procurement_products (organization_id, category);

create index if not exists procurement_products_org_status_idx
  on public.procurement_products (organization_id, status);

create trigger procurement_products_set_updated_at
before update on public.procurement_products
for each row execute function public.procurement_set_updated_at();

create table if not exists public.procurement_product_variants (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  product_id uuid not null,
  variant_code text,
  name text not null,
  unit text not null,
  pack_size text,
  supply_type text not null default 'supplier_sourced'
    check (supply_type in ('fixed_stock', 'supplier_sourced')),
  status text not null default 'active'
    check (status in ('active', 'inactive', 'archived')),
  is_customer_visible boolean not null default false,
  archived_at timestamptz,
  archived_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint procurement_product_variants_org_id_unique unique (organization_id, id),
  constraint procurement_product_variants_product_fk
    foreign key (organization_id, product_id)
    references public.procurement_products (organization_id, id)
    on delete restrict
);

create unique index if not exists procurement_product_variants_org_code_uidx
  on public.procurement_product_variants (organization_id, lower(variant_code))
  where variant_code is not null and archived_at is null;

create index if not exists procurement_product_variants_org_product_idx
  on public.procurement_product_variants (organization_id, product_id);

create index if not exists procurement_product_variants_supply_status_idx
  on public.procurement_product_variants (supply_type, status);

create trigger procurement_product_variants_set_updated_at
before update on public.procurement_product_variants
for each row execute function public.procurement_set_updated_at();

-- ---------------------------------------------------------------------------
-- Quote request and quote draft lifecycle
-- ---------------------------------------------------------------------------

create table if not exists public.procurement_quote_requests (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  customer_id uuid not null,
  customer_location_id uuid,
  source_channel text not null default 'manual'
    check (source_channel in ('manual', 'sales', 'platform', 'line')),
  status text not null default 'received'
    check (status in ('received', 'triage', 'drafting', 'quoted', 'cancelled', 'archived')),
  requested_summary text,
  requested_items jsonb not null default '[]'::jsonb,
  risk_flags jsonb not null default '[]'::jsonb,
  assigned_sales_rep_id uuid,
  received_at timestamptz not null default now(),
  archived_at timestamptz,
  archived_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint procurement_quote_requests_org_id_unique unique (organization_id, id),
  constraint procurement_quote_requests_org_customer_id_unique unique (organization_id, customer_id, id),
  constraint procurement_quote_requests_customer_fk
    foreign key (organization_id, customer_id)
    references public.procurement_customers (organization_id, id)
    on delete restrict,
  constraint procurement_quote_requests_location_fk
    foreign key (organization_id, customer_id, customer_location_id)
    references public.procurement_customer_locations (organization_id, customer_id, id)
    on delete restrict
);

comment on column public.procurement_quote_requests.source_channel is
  'line is a reserved future/mock channel only. This migration does not connect LINE.';

create index if not exists procurement_quote_requests_org_status_idx
  on public.procurement_quote_requests (organization_id, status);

create index if not exists procurement_quote_requests_customer_idx
  on public.procurement_quote_requests (customer_id);

create index if not exists procurement_quote_requests_assigned_sales_idx
  on public.procurement_quote_requests (assigned_sales_rep_id);

create index if not exists procurement_quote_requests_source_received_idx
  on public.procurement_quote_requests (source_channel, received_at);

create trigger procurement_quote_requests_set_updated_at
before update on public.procurement_quote_requests
for each row execute function public.procurement_set_updated_at();

create table if not exists public.procurement_quote_drafts (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  quote_request_id uuid not null,
  customer_id uuid not null,
  status text not null default 'draft'
    check (status in ('draft', 'submitted_for_approval', 'approved_for_quote', 'rejected', 'cancelled', 'archived')),
  approval_status text not null default 'not_submitted'
    check (approval_status in ('not_submitted', 'pending', 'approved', 'rejected')),
  created_by_user_id uuid,
  created_by_role text not null default 'user'
    check (created_by_role in ('user', 'system', 'ai_assisted')),
  assigned_sales_rep_id uuid,
  draft_total_amount numeric(14,2),
  currency char(3) not null default 'TWD',
  expires_at timestamptz,
  risk_flags jsonb not null default '[]'::jsonb,
  internal_notes text,
  archived_at timestamptz,
  archived_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint procurement_quote_drafts_org_id_unique unique (organization_id, id),
  constraint procurement_quote_drafts_request_fk
    foreign key (organization_id, customer_id, quote_request_id)
    references public.procurement_quote_requests (organization_id, customer_id, id)
    on delete restrict,
  constraint procurement_quote_drafts_customer_fk
    foreign key (organization_id, customer_id)
    references public.procurement_customers (organization_id, id)
    on delete restrict
);

comment on table public.procurement_quote_drafts is
  'Internal draft only. A quote draft is not a formal customer quote, not an order, and does not reserve inventory.';

create index if not exists procurement_quote_drafts_org_approval_idx
  on public.procurement_quote_drafts (organization_id, approval_status);

create index if not exists procurement_quote_drafts_customer_idx
  on public.procurement_quote_drafts (customer_id);

create index if not exists procurement_quote_drafts_request_idx
  on public.procurement_quote_drafts (quote_request_id);

create index if not exists procurement_quote_drafts_assigned_sales_idx
  on public.procurement_quote_drafts (assigned_sales_rep_id);

create trigger procurement_quote_drafts_set_updated_at
before update on public.procurement_quote_drafts
for each row execute function public.procurement_set_updated_at();

create table if not exists public.procurement_quote_draft_items (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  quote_draft_id uuid not null,
  variant_id uuid,
  item_text text not null,
  quantity numeric(14,3) not null default 1,
  unit text,
  draft_unit_price numeric(14,2),
  currency char(3) not null default 'TWD',
  pricing_basis text,
  margin_flag text check (margin_flag in ('none', 'review', 'low_margin', 'blocked')),
  notes text,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint procurement_quote_draft_items_org_id_unique unique (organization_id, id),
  constraint procurement_quote_draft_items_quantity_chk check (quantity > 0),
  constraint procurement_quote_draft_items_draft_fk
    foreign key (organization_id, quote_draft_id)
    references public.procurement_quote_drafts (organization_id, id)
    on delete restrict,
  constraint procurement_quote_draft_items_variant_fk
    foreign key (organization_id, variant_id)
    references public.procurement_product_variants (organization_id, id)
    on delete restrict
);

comment on table public.procurement_quote_draft_items is
  'Draft line items only. Supplier cost, internal margin, pricing guardrails, and order fulfillment are out of Phase 3B-1 scope.';

create index if not exists procurement_quote_draft_items_draft_idx
  on public.procurement_quote_draft_items (quote_draft_id);

create index if not exists procurement_quote_draft_items_variant_idx
  on public.procurement_quote_draft_items (variant_id);

create trigger procurement_quote_draft_items_set_updated_at
before update on public.procurement_quote_draft_items
for each row execute function public.procurement_set_updated_at();

-- ---------------------------------------------------------------------------
-- Audit skeleton
-- ---------------------------------------------------------------------------

create table if not exists public.procurement_audit_events (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null,
  actor_user_id uuid,
  actor_role text,
  event_type text not null,
  target_table text not null,
  target_id uuid,
  customer_id uuid,
  before_snapshot jsonb,
  after_snapshot jsonb,
  approval_ref text,
  idempotency_key text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

comment on table public.procurement_audit_events is
  'Append-only audit skeleton. Future approval/order confirmation flows must write here before being allowed.';

create index if not exists procurement_audit_events_org_created_idx
  on public.procurement_audit_events (organization_id, created_at desc);

create index if not exists procurement_audit_events_target_idx
  on public.procurement_audit_events (target_table, target_id);

create index if not exists procurement_audit_events_customer_idx
  on public.procurement_audit_events (customer_id);

create index if not exists procurement_audit_events_event_type_idx
  on public.procurement_audit_events (event_type);

create unique index if not exists procurement_audit_events_idempotency_uidx
  on public.procurement_audit_events (organization_id, idempotency_key)
  where idempotency_key is not null;

-- ---------------------------------------------------------------------------
-- RLS helper draft
-- ---------------------------------------------------------------------------

create or replace function public.procurement_current_user_id()
returns uuid
language sql
stable
set search_path = public, auth
as $$
  select auth.uid();
$$;

create or replace function public.procurement_is_customer_user_for_customer(
  p_user_id uuid,
  p_customer_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select p_user_id is not null
    and exists (
      select 1
      from public.procurement_customer_users pcu
      where pcu.user_id = p_user_id
        and pcu.customer_id = p_customer_id
        and pcu.status = 'active'
        and pcu.archived_at is null
    );
$$;

create or replace function public.procurement_is_sales_rep_for_customer_at(
  p_user_id uuid,
  p_customer_id uuid,
  p_at timestamptz default now()
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select p_user_id is not null
    and exists (
      select 1
      from public.procurement_sales_assignments psa
      where psa.sales_rep_user_id = p_user_id
        and psa.customer_id = p_customer_id
        and psa.status = 'active'
        and psa.archived_at is null
        and p_at >= psa.effective_from
        and (psa.effective_to is null or p_at < psa.effective_to)
    );
$$;

create or replace function public.procurement_user_has_org_read_access(
  p_user_id uuid,
  p_organization_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select p_user_id is not null
    and (
      exists (
        select 1
        from public.procurement_customer_users pcu
        where pcu.user_id = p_user_id
          and pcu.organization_id = p_organization_id
          and pcu.status = 'active'
          and pcu.archived_at is null
      )
      or exists (
        select 1
        from public.procurement_sales_assignments psa
        where psa.sales_rep_user_id = p_user_id
          and psa.organization_id = p_organization_id
          and psa.status = 'active'
          and psa.archived_at is null
          and now() >= psa.effective_from
          and (psa.effective_to is null or now() < psa.effective_to)
      )
    );
$$;

create or replace function public.procurement_can_read_quote_draft(
  p_user_id uuid,
  p_quote_draft_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select p_user_id is not null
    and exists (
      select 1
      from public.procurement_quote_drafts pqd
      where pqd.id = p_quote_draft_id
        and pqd.archived_at is null
        and public.procurement_is_sales_rep_for_customer_at(
          p_user_id,
          pqd.customer_id,
          now()
        )
    );
$$;

comment on function public.procurement_user_has_org_read_access(uuid, uuid) is
  'Phase 3B-1 helper draft. Owner/admin role source is intentionally not implemented until the accepted role table/source is confirmed.';

-- TODO Phase 3B-2:
-- Add owner/admin helper only after the canonical role source is accepted.
-- Do not add a broad organization policy based on unverified user metadata.

-- ---------------------------------------------------------------------------
-- Conservative RLS posture
-- ---------------------------------------------------------------------------

alter table public.procurement_customers enable row level security;
alter table public.procurement_customer_locations enable row level security;
alter table public.procurement_customer_users enable row level security;
alter table public.procurement_sales_assignments enable row level security;
alter table public.procurement_products enable row level security;
alter table public.procurement_product_variants enable row level security;
alter table public.procurement_quote_requests enable row level security;
alter table public.procurement_quote_drafts enable row level security;
alter table public.procurement_quote_draft_items enable row level security;
alter table public.procurement_audit_events enable row level security;

alter table public.procurement_customers force row level security;
alter table public.procurement_customer_locations force row level security;
alter table public.procurement_customer_users force row level security;
alter table public.procurement_sales_assignments force row level security;
alter table public.procurement_products force row level security;
alter table public.procurement_product_variants force row level security;
alter table public.procurement_quote_requests force row level security;
alter table public.procurement_quote_drafts force row level security;
alter table public.procurement_quote_draft_items force row level security;
alter table public.procurement_audit_events force row level security;

revoke all on table public.procurement_customers from anon, authenticated;
revoke all on table public.procurement_customer_locations from anon, authenticated;
revoke all on table public.procurement_customer_users from anon, authenticated;
revoke all on table public.procurement_sales_assignments from anon, authenticated;
revoke all on table public.procurement_products from anon, authenticated;
revoke all on table public.procurement_product_variants from anon, authenticated;
revoke all on table public.procurement_quote_requests from anon, authenticated;
revoke all on table public.procurement_quote_drafts from anon, authenticated;
revoke all on table public.procurement_quote_draft_items from anon, authenticated;
revoke all on table public.procurement_audit_events from anon, authenticated;

grant select on table public.procurement_customers to authenticated;
grant select on table public.procurement_customer_locations to authenticated;
grant select on table public.procurement_customer_users to authenticated;
grant select on table public.procurement_sales_assignments to authenticated;
grant select on table public.procurement_products to authenticated;
grant select on table public.procurement_product_variants to authenticated;
grant select on table public.procurement_quote_requests to authenticated;
grant select on table public.procurement_quote_drafts to authenticated;
grant select on table public.procurement_quote_draft_items to authenticated;

revoke all on function public.procurement_current_user_id() from public;
revoke all on function public.procurement_is_customer_user_for_customer(uuid, uuid) from public;
revoke all on function public.procurement_is_sales_rep_for_customer_at(uuid, uuid, timestamptz) from public;
revoke all on function public.procurement_user_has_org_read_access(uuid, uuid) from public;
revoke all on function public.procurement_can_read_quote_draft(uuid, uuid) from public;

grant execute on function public.procurement_current_user_id() to authenticated;
grant execute on function public.procurement_is_customer_user_for_customer(uuid, uuid) to authenticated;
grant execute on function public.procurement_is_sales_rep_for_customer_at(uuid, uuid, timestamptz) to authenticated;
grant execute on function public.procurement_user_has_org_read_access(uuid, uuid) to authenticated;
grant execute on function public.procurement_can_read_quote_draft(uuid, uuid) to authenticated;

create policy procurement_customers_customer_or_sales_select
on public.procurement_customers
for select
to authenticated
using (
  archived_at is null
  and (
    public.procurement_is_customer_user_for_customer(auth.uid(), id)
    or public.procurement_is_sales_rep_for_customer_at(auth.uid(), id, now())
  )
);

create policy procurement_customer_locations_customer_or_sales_select
on public.procurement_customer_locations
for select
to authenticated
using (
  archived_at is null
  and (
    public.procurement_is_customer_user_for_customer(auth.uid(), customer_id)
    or public.procurement_is_sales_rep_for_customer_at(auth.uid(), customer_id, now())
  )
);

create policy procurement_customer_users_own_or_assigned_sales_select
on public.procurement_customer_users
for select
to authenticated
using (
  archived_at is null
  and (
    user_id = auth.uid()
    or public.procurement_is_sales_rep_for_customer_at(auth.uid(), customer_id, now())
  )
);

create policy procurement_sales_assignments_self_or_customer_select
on public.procurement_sales_assignments
for select
to authenticated
using (
  archived_at is null
  and (
    sales_rep_user_id = auth.uid()
    or public.procurement_is_customer_user_for_customer(auth.uid(), customer_id)
  )
);

create policy procurement_products_org_visible_select
on public.procurement_products
for select
to authenticated
using (
  archived_at is null
  and status = 'active'
  and is_customer_visible = true
  and public.procurement_user_has_org_read_access(auth.uid(), organization_id)
);

create policy procurement_product_variants_org_visible_select
on public.procurement_product_variants
for select
to authenticated
using (
  archived_at is null
  and status = 'active'
  and is_customer_visible = true
  and public.procurement_user_has_org_read_access(auth.uid(), organization_id)
  and exists (
    select 1
    from public.procurement_products pp
    where pp.id = public.procurement_product_variants.product_id
      and pp.organization_id = public.procurement_product_variants.organization_id
      and pp.archived_at is null
      and pp.status = 'active'
      and pp.is_customer_visible = true
  )
);

create policy procurement_quote_requests_customer_or_sales_select
on public.procurement_quote_requests
for select
to authenticated
using (
  archived_at is null
  and (
    public.procurement_is_customer_user_for_customer(auth.uid(), customer_id)
    or public.procurement_is_sales_rep_for_customer_at(auth.uid(), customer_id, now())
  )
);

create policy procurement_quote_drafts_assigned_sales_select
on public.procurement_quote_drafts
for select
to authenticated
using (
  archived_at is null
  and public.procurement_is_sales_rep_for_customer_at(auth.uid(), customer_id, now())
);

create policy procurement_quote_draft_items_assigned_sales_select
on public.procurement_quote_draft_items
for select
to authenticated
using (
  public.procurement_can_read_quote_draft(auth.uid(), quote_draft_id)
);

-- No authenticated insert/update/delete policies are added in Phase 3B-1.
-- No authenticated audit table SELECT policy is added in Phase 3B-1.
-- Future write APIs must use reviewed service boundaries and append audit events.

-- ---------------------------------------------------------------------------
-- Staging seed/test notes
-- ---------------------------------------------------------------------------

-- Do not insert real seed data in this migration.
-- Future staging seed should use fictional organizations/customers only and cover:
-- 1. Customer A cannot read Customer B.
-- 2. Customer user cannot read quote drafts.
-- 3. Sales rep cannot read unassigned customers.
-- 4. Expired sales assignment does not grant access.
-- 5. Products are hidden unless customer-visible and organization-scoped.
-- 6. Audit table has no customer/public read policy.
