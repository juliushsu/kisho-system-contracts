Client Domain Base Boundary v1

Status

Accepted

⸻

Purpose

This document defines the canonical boundary for the client domain base.

Its purpose is to ensure that:
	•	client write identity is backed by a real base table
	•	client read contracts are not confused with client base
	•	merchant orders can legally and structurally depend on client_id
	•	future CRM / payment / AR layers can extend from a stable client base

⸻

Core Principle

Read wrapper is not domain base.
Client identity used by order write must come from a real client base table.

⸻

Domain Definition

Client Domain Base

Canonical base table:
	•	public.clients

This table represents the merchant-scoped client identity base used for:
	•	order write path
	•	future CRM extension
	•	future AR / payment association
	•	future reminder / collection ownership

⸻

Read Wrapper Boundary

The following are read contracts, not client base:
	•	merchant_clients_v1(...)
	•	merchant_client_detail_v1(...)
	•	v_merchant_clients_canonical_v1

These may wrap, normalize, or project client data, but they are not valid substitutes for a real write base.

Rule

Order write path must not depend on a read wrapper as if it were a base table.

⸻

Order Dependency Rule

merchant_orders.client_id is a hard dependency on client domain base.

This means:
	•	client_id must reference a real client base row
	•	order creation must fail if no valid client exists
	•	no fallback, anonymous, hidden, or dummy client is allowed

This rule aligns with:
	•	client_prerequisite_for_order_v1
	•	merchant_orders_domain_boundary_v1

⸻

Minimal Base Schema

The minimal canonical client base should include:
	•	client_id uuid primary key
	•	merchant_id uuid not null references public.stores(id)
	•	business_entity_id uuid null references public.business_entities(id)
	•	location_id uuid null references public.locations(id)
	•	display_name text not null
	•	legal_name text null
	•	client_status text not null default 'active'
	•	client_type text null
	•	created_at timestamptz not null default now()
	•	updated_at timestamptz not null default now()

⸻

Minimal Constraint Principles

Required
	•	primary key on client_id
	•	index on merchant_id
	•	merchant-scoped ownership
	•	status check on client_status

Allowed Nullable Bridge Fields
	•	business_entity_id
	•	location_id

These are optional bridges, not initial blockers.

⸻

Merchant Scope Rule

Client base must be merchant-scoped.

The authoritative ownership anchor is:
	•	merchant_id

Any bridge to:
	•	business_entity_id
	•	location_id

must remain secondary and must not replace merchant-scoped ownership.

⸻

Allowed Uses of Client Base

The client base may be referenced by:
	•	merchant order write path
	•	merchant client read wrapper
	•	future client detail pages
	•	future CRM notes / ownership
	•	future payment / AR linkage
	•	future collection tasks

⸻

Forbidden Misuse

The following are forbidden:
	•	using merchant_clients_v1 as write base
	•	using canonical view as direct write source
	•	using debug fixtures as long-term client base
	•	creating orders without a real client row
	•	creating hidden default clients
	•	inferring client existence from orders
	•	treating business_entities alone as merchant client base without explicit client row

⸻

Relationship to Existing Tables

stores

Represents merchant scope / merchant owner side.

business_entities

Represents general legal/business identity layer.
It may support client linkage, but does not automatically become merchant client base.

locations

Represents location layer.
Useful for delivery/billing association, but not a substitute for client identity.

clients

Represents merchant-side client domain base.
This is the write anchor for client_id.

⸻

Read Contract Compatibility Rule

Client base must be introduced in a way that does not break existing read contracts.

Desired outcome:
	•	v_merchant_clients_canonical_v1 can read real rows from public.clients
	•	merchant_clients_v1(...) and merchant_client_detail_v1(...) remain contract-stable
	•	frontend service convergence can continue without DTO breakage

⸻

Migration Principle

Introducing public.clients should be done as:
	•	minimal domain-base migration
	•	no CRM over-expansion
	•	no AR/payment coupling in same migration
	•	no unnecessary schema redesign

This is a foundation migration, not a feature expansion migration.

⸻

Future Extensions

The client base is expected to support future domains such as:
	•	client onboarding
	•	order creation guard
	•	payment allocation
	•	receivables summary
	•	reminder tasks
	•	CRM ownership and segmentation

But those extensions must remain separate phases.

⸻

Summary

The merchant client domain requires a real base table.

The system must enforce:
	•	public.clients = canonical client base
	•	read wrappers remain wrappers
	•	client_id used by orders must reference real base rows
	•	merchant scope remains primary
	•	future CRM / AR / collection can extend safely from this base
:::
