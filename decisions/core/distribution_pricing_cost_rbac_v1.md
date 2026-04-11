Distribution Pricing Cost RBAC v1

Status

Accepted

⸻

Purpose

This document defines the system model for:
	•	distribution rights
	•	market pricing
	•	organization-specific cost
	•	RBAC visibility and edit boundaries

Its purpose is to ensure that the platform can support:
	•	shared product catalog
	•	multi-merchant sales
	•	different org-specific cost structures
	•	unified market pricing discipline
	•	strict cost confidentiality between organizations

⸻

Core Principle

Product identity is shared.
Selling rights are controlled.
Market prices may be unified.
Cost is organization-specific.
Visibility is governed by RBAC.

⸻

Layer Model

The model is intentionally separated into four layers:
	1.	Catalog Layer
	2.	Distribution Rights Layer
	3.	Pricing Layer
	4.	Cost Layer

RBAC applies across all four.

⸻

1. Catalog Layer

Purpose

The catalog layer defines shared product identity.

Includes
	•	product_master
	•	product_variants
	•	brands
	•	breweries

Owns
	•	product identity
	•	product naming
	•	volume / specification
	•	barcode / JAN
	•	public descriptive attributes

Must Not Own
	•	organization-specific cost
	•	organization-specific selling rights
	•	org-specific pricing settings

Rule

A product exists independently of any specific merchant organization.

⸻

2. Distribution Rights Layer

Purpose

Defines which organization may sell, distribute, or operate a product.

Recommended Model
	•	distribution_rights

Suggested Fields
	•	id
	•	org_id
	•	product_variant_id
	•	role_type
	•	is_exclusive
	•	territory_scope
	•	valid_from
	•	valid_to
	•	status

Example role_type
	•	platform
	•	master_distributor
	•	distributor
	•	partner

Business Meaning

This layer answers:
	•	who can sell this product
	•	who is exclusive
	•	who is non-exclusive
	•	whether platform retains direct operating rights

Rule

Selling rights are controlled here, not inferred from price or cost.

⸻

3. Pricing Layer

Purpose

Defines market-facing prices that should remain stable and not disturb channel discipline.

Examples
	•	channel price
	•	restaurant price
	•	KOL / promo price
	•	retail / end-user price

Recommended Model
	•	price_books
	•	price_book_items

Suggested Fields
	•	product_variant_id
	•	channel_price
	•	restaurant_price
	•	kol_price
	•	retail_price
	•	effective_from
	•	effective_to
	•	controlled_by_org_id

Rule

These are market or channel prices, not org-specific cost.

Business Principle

These prices may be centrally governed to avoid price disorder in the market.

⸻

4. Cost Layer

Purpose

Defines the acquisition or supply cost for a specific organization.

This is the most important distinction:

cost is not a global product field
cost is organization-specific

Recommended Model
	•	org_variant_costs

Suggested Fields
	•	id
	•	org_id
	•	product_variant_id
	•	cost_value
	•	cost_source
	•	cost_tier
	•	effective_from
	•	effective_to
	•	status

cost_value

The actual cost value visible to the organization, subject to RBAC.

cost_source

Internal semantic source of the cost.

Suggested values:
	•	platform
	•	master_distributor
	•	distributor
	•	partner
	•	special

cost_tier

Internal machine-facing classification.

Suggested values:
	•	A
	•	B
	•	C
	•	D
	•	E

Important Rule

cost_tier is for internal system/admin use only.

It must not be exposed to ordinary organization users.

⸻

Why Cost Must Be Org-Specific

Different organizations may receive different costs because of:
	•	agency role
	•	exclusivity
	•	purchase volume
	•	special contract terms
	•	timing
	•	negotiated supply conditions

Therefore, the system must not model cost as a single shared field on the product itself.

⸻

Visibility Rule

Organization User

An organization may only see:
	•	its own cost value
	•	its own active sellable products
	•	its own price / pricing settings if permitted

It must not see:
	•	other org costs
	•	platform-level hidden cost basis
	•	internal cost tier labels

⸻

Internal Cost Tier Rule

Allowed

The system may internally classify org costs into:
	•	A
	•	B
	•	C
	•	D
	•	E

Not Allowed

The system must not expose:
	•	tier labels to org users
	•	other org tier positions
	•	any metadata that allows users to infer upstream cost hierarchy

Reason

Tier labels are internal semantic markers only.

They are not business-facing identities.

⸻

UI Naming Rule

For Organization-Facing UI

Do not use ambiguous wording that implies a single universal cost across the platform.

Preferred labels:
	•	本組織成本
	•	供貨成本

Avoid exposing:
	•	A/B/C/D/E
	•	platform cost
	•	other organizations’ cost context

Optional UI Hint

You may add a short tooltip such as:

此欄位為本組織目前的取得成本，可能因合作條件不同而異。

⸻

RBAC Rules

Recommended Capability Split

Cost Visibility
	•	can_view_cost
	•	can_edit_cost

Pricing Visibility
	•	can_view_price
	•	can_edit_price

Distribution Rights Visibility
	•	can_view_distribution_rights
	•	can_manage_distribution_rights

Platform-Only Visibility
	•	can_view_platform_cost_basis
	•	can_manage_cost_tiers

⸻

RBAC Enforcement

Platform Roles

May:
	•	view all org costs
	•	manage cost tiers
	•	manage distribution rights
	•	manage pricing strategy

Org Admin

May:
	•	view own org cost
	•	edit own org commercial settings if permitted

Sales / Warehouse / Ordinary Org User

Usually should not:
	•	see platform cost basis
	•	see other org cost
	•	see internal cost tier

⸻

Data Ownership Summary

Layer	Scope	Shared or Org-Specific
Catalog	product identity	Shared
Distribution Rights	selling permission	Org-specific
Pricing	market-facing prices	Usually shared / governed
Cost	acquisition / supply cost	Org-specific


⸻

Anti-Patterns (Forbidden)

1. Shared Product Cost

❌ storing a single universal cost_price on product_variants as the platform truth

2. Exposing Cost Tier to Orgs

❌ showing A/B/C/D/E in UI or API to organizations

3. Inferring Rights from Price

❌ assuming an org can sell a product just because it has a price row

4. Using Cost as Shared Market Signal

❌ allowing one org to infer another org’s upstream pricing structure

5. Mixing Catalog with Org Commercial Settings

❌ storing org-specific cost inside shared product identity layer

⸻

Recommended Future Extensions

Not required in v1, but compatible with this model:
	•	batch-level cost
	•	landed cost decomposition
	•	time-based cost history
	•	rebate / incentive layer
	•	AI margin analysis
	•	distribution-right-aware price recommendation

⸻

Relationship to Other Decisions

This document must be interpreted together with:
	•	platform_operating_model_v1.md
	•	data_boundary_rules_v1.md
	•	rpc_write_policy_v1.md
	•	api_contract_versioning_v1.md
	•	multi_merchant_inventory_and_distribution_model_v1.md

⸻

Summary

The system must distinguish clearly between:
	•	shared product identity
	•	who may sell
	•	what price the market sees
	•	what cost a given organization actually has

This model protects:
	•	market pricing discipline
	•	org-specific confidentiality
	•	correct multi-tenant behavior
	•	future AI recommendation quality
