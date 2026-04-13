Merchant Read Contract Policy v1

Status

Accepted

⸻

Purpose

This document defines the read-contract policy for the Merchant Zone (yellow zone).

Its purpose is to ensure that merchant-facing pages:
	•	use stable org-scoped read contracts
	•	do not mix canonical / bridge / legacy paths
	•	do not display misleading placeholder business values
	•	do not query base tables directly from page components

⸻

Core Principle

Merchant Zone pages must read from explicit contracts,
not from ad hoc joins, bridge views, or legacy tables.

⸻

Page-Level Rule

Each merchant-facing page must have one clearly defined primary read contract.

Examples:
	•	catalog
	•	my brands
	•	my products
	•	clients
	•	orders
	•	storefront
	•	machine config

A page must not mix:
	•	canonical RPC/view
	•	bridge view
	•	legacy table
	•	page-level direct joins

as equal primary sources.

⸻

Allowed Read Sources

Preferred order:
	1.	Canonical RPC
	2.	Canonical view
	3.	Transitional service wrapper (temporary only, explicitly marked)
	4.	Base table direct query only when no canonical contract exists and only inside service layer

⸻

Forbidden for New UI

The following must be treated as forbidden-for-new-UI primary sources:
	•	v_variant_catalog
	•	v_variant_catalog_bridge_v1
	•	merchant_org_variants
	•	core_variants
	•	direct sake_products reads
	•	debug snapshot / ad hoc debug adapters
	•	page-level direct joins across merchant_products, merchant_product_overrides, product_master, brands

These may remain temporarily for backward compatibility, but must not become the primary source for new or refactored merchant UI.

⸻

Service Layer Rule

Merchant pages must not directly call Supabase from page components when a service layer is appropriate.

Required:
	•	page.tsx handles UI only
	•	service files handle data access
	•	org scope resolution is centralized

⸻

Org Scope Rule

All merchant read contracts must be org-scoped.

Frontend may pass:
	•	org_id
or
	•	merchant_id

But business-entity/location derivation must be handled inside backend contract or service layer, not scattered across pages.

⸻

No Fake Business Values Rule

Merchant UI must not display fabricated business values such as:
	•	fixed $0
	•	fixed 0
	•	fake badge
	•	fake stock quantity

when the real value is unknown.

If value is unavailable:
	•	show —
	•	or hide the field
	•	or explicitly mark as unavailable

Never show misleading defaults that look like real business data.

⸻

Contract Decisions

Catalog

Use canonical catalog contract (get_catalog_for_org(...) / approved canonical merchant catalog path).

My Products

Freeze to the approved formal contract used by current implementation.
Do not reintroduce merchant_org_variants as primary UI source.

Clients

Must move toward a minimal canonical clients read contract.
Before that is complete, all reads must still go through a dedicated service layer.

Orders

Must not be fully refactored on the frontend before canonical orders read contract is defined.

⸻

Transitional Policy

A transitional path is allowed only if:
	•	it is explicitly marked transitional
	•	it is wrapped in service layer
	•	it is not used as long-term canonical truth
	•	there is a declared plan to retire it

⸻

Merchant Fix Priority

Wave 1
	•	stabilize My Products read path
	•	remove fake values from UI
	•	move Clients page to service layer

Wave 2
	•	define canonical clients read model
	•	define canonical orders read model
	•	migrate Orders page away from legacy/bridge paths

⸻

Anti-Patterns

Forbidden patterns include:
	•	page.tsx directly querying multiple tables
	•	mixing old catalog views with new merchant product paths
	•	using bridge tables as canonical truth
	•	letting UI infer data semantics not defined by backend contract
	•	displaying placeholder numbers as if they were real business values

⸻

Summary

Merchant Zone pages must be built on clear, stable, org-scoped read contracts.

The system should prefer:
	•	canonical RPC/view
	•	service-layer encapsulation
	•	explicit transitional labeling

And avoid:
	•	page-level direct DB queries
	•	mixed-generation read paths
	•	fake business values
	•	legacy/bridge dependence for new UI
:::
