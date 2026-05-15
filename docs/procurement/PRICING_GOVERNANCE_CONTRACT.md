# Pricing Governance Contract

Status: Proposed
Date: 2026-05-15
Scope: Documentation / governance / architecture only

本輪為 canonical contracts phase only。

本文件不涉及 production code、不涉及 DB migration、不涉及 secrets / env、不涉及 Readdy UI 修改、不產生 API route、不實作 Edge Function。後續需由 CTO review 後才可進入 implementation phase。

## 1. Purpose

This document defines pricing governance for the 大皇居 B2B procurement platform.

Pricing must support customer-specific commerce while protecting margin, supplier confidentiality, and human approval authority.

## 2. Pricing Layers

Canonical pricing layers:

| Layer | Purpose | Visibility |
| --- | --- | --- |
| Market reference pricing | External or internal reference price used for sanity checks | Internal only unless explicitly published |
| List price | Default customer-facing price before customer rules | Customer-visible when applicable |
| Customer-specific pricing | Negotiated price or discount for a customer | Customer-visible only to that customer |
| Campaign pricing | Temporary price for campaign or promotion | Customer-visible by eligibility |
| Supplier cost | Supplier quote, landed cost, procurement cost | Internal only |
| Margin guardrail | Minimum margin or minimum price protection | Internal only |
| Manual override | Human-approved exception | Internal audit and customer-facing price only |

## 3. Market Reference Pricing

Market reference pricing is a comparison signal, not an automatic quote.

Use cases:

1. Compare list price against expected market range.
2. Detect stale pricing.
3. Flag imported liquor volatility.
4. Flag aged meat grade/cut/weight volatility.
5. Support AI pricing assistant explanations.

Rules:

1. Market reference data must show source type and freshness if used.
2. AI may summarize reference pricing but may not turn it into a customer quote without approved price book or human review.
3. Market reference should not expose supplier cost or internal margin.

## 4. Customer-Specific Pricing

Customer-specific pricing may include:

| Type | Description |
| --- | --- |
| Fixed SKU price | Specific price for customer and variant |
| Category discount | Discount applied to a category |
| Volume tier | Quantity-dependent price |
| Location-specific price | Price scoped to branch/location |
| Quote-only price | Price valid only for one quote version |
| Campaign eligibility | Customer included in temporary campaign |

Rules:

1. Every customer-specific rule has effective dates.
2. Rules must be scoped to customer, category, product, or variant.
3. Rules used in quotes must be preserved by reference or snapshot.
4. AI may suggest rule candidates but cannot approve or activate them.

## 5. Margin Protection

Margin protection prevents accidental underpricing.

Recommended margin guardrails:

| Guardrail | Meaning |
| --- | --- |
| Minimum gross margin | Lowest allowed margin by category/product |
| Minimum unit price | Lowest allowed customer-facing unit price |
| Cost freshness | Supplier cost older than allowed period requires review |
| Volatility flag | Category or supplier marked volatile requires review |
| Override reason | Required for exceptions |

Margin-sensitive data is internal only. Customer users must never see internal cost, margin, guardrail thresholds, or supplier quote internals.

## 6. Minimum Allowed Pricing

Minimum allowed pricing is the lowest price the system may recommend without escalation.

Minimum price may derive from:

1. Supplier cost.
2. Landed cost.
3. Category margin rule.
4. Customer contract.
5. Campaign floor.
6. Finance override.

Rules:

1. AI cannot quote below minimum allowed pricing.
2. Sales users cannot bypass minimum allowed pricing without approval workflow.
3. Minimum pricing must be versioned or snapshotted when used in quotes.
4. If supplier cost is unknown or stale, quote draft should be `review_required`.

## 7. Approval-Required Thresholds

Pricing approval is required when:

| Trigger | Required reviewer |
| --- | --- |
| Price below minimum allowed price | Sales manager / Finance |
| Margin below category threshold | Sales manager / Finance |
| Supplier quote expired | Procurement |
| Customer-specific rule newly created | Sales Ops / Finance |
| Temporary campaign outside approved window | Campaign owner / Finance |
| Imported liquor volatility flag active | Procurement / Sales |
| Aged meat volatility flag active | Meat category owner / Procurement |
| AI confidence low on product match | Sales |

Approval record should include actor, timestamp, reason, affected quote/rule, and expiration if temporary.

## 8. Temporary Campaign Pricing

Temporary campaign pricing is time-bound and eligibility-bound.

Required concepts:

| Concept | Meaning |
| --- | --- |
| Campaign name | Human-readable label |
| Eligibility | Customer, segment, category, product, variant |
| Effective period | Start and end |
| Price or discount | Governed customer-facing change |
| Margin floor | Internal minimum |
| Approval owner | Person/team accountable |
| Expiration behavior | Revert to default pricing |

Rules:

1. Expired campaigns cannot silently continue.
2. Quotes issued during campaigns preserve terms until quote expiration.
3. Extending campaign price beyond expiration requires approval.
4. AI may mention campaign eligibility only if the customer is eligible.

## 9. Supplier Fluctuation Handling

Supplier fluctuation affects cost, availability, MOQ, lead time, and customer quote validity.

Rules:

1. Supplier quote expiration must be tracked.
2. Supplier price changes do not automatically change issued customer quotes unless terms allow.
3. Draft quotes should flag stale supplier costs.
4. Supplier terms should remain internal unless intentionally converted to customer-facing terms.
5. AI may summarize fluctuation risk to internal users.

## 10. Imported Liquor Volatility

Imported liquor pricing may change due to:

1. Exchange rate.
2. Import duties or taxes.
3. Shipping cost.
4. Vintage availability.
5. Distributor allocation.
6. Limited supply.

Governance:

1. Volatile imported liquor variants may require shorter quotation expiration.
2. AI should flag imported liquor volatility before quote issuance.
3. Customer-facing messages should avoid exposing supplier or cost details.
4. Sales/procurement must approve substitutions or allocation-sensitive offers.

## 11. Aged Meat Pricing Volatility

Aged meat pricing may change due to:

1. Cut and grade availability.
2. Weight variance.
3. Aging duration.
4. Yield loss.
5. Cold-chain cost.
6. Supplier batch fluctuation.

Governance:

1. Aged meat quotes may need weight tolerance and validity windows.
2. Final order confirmation may require actual weight or batch confirmation.
3. AI may suggest questions to clarify grade, cut, and weight, but cannot finalize pricing.
4. Meat category owner review may be required for unusual cuts or premium grades.

## 12. Quotation Expiration Rules

Quote expiration protects both customer clarity and internal risk.

Recommended expiration policy:

| Quote type | Default validity |
| --- | --- |
| Standard stocked product | 7 to 14 days |
| Imported liquor volatile item | 1 to 7 days |
| Aged meat variable weight item | 1 to 7 days or batch-dependent |
| Supplier-sourced item | No later than supplier quote expiration |
| Campaign price | No later than campaign end unless approved |
| Manual exception | Explicit expiration required |

Rules:

1. Expired quotes cannot be converted to orders without review.
2. Customer confirmation after expiration creates `sales_review_required`.
3. AI can remind sales/customer of expiration but cannot extend quotes.
4. Quote extensions are pricing actions and must be audited.

## 13. AI Pricing Assistant Guardrails

AI pricing assistant may:

1. Identify applicable price book or customer price rule.
2. Flag missing or stale supplier quote.
3. Flag margin risk.
4. Draft internal pricing review notes.
5. Suggest clarifying questions.
6. Explain why human review is required.

AI pricing assistant must not:

1. Create active customer-specific pricing rules.
2. Approve discounts.
3. Quote below minimum allowed pricing.
4. Reveal internal margin, supplier cost, or guardrail thresholds to customers.
5. Infer one customer's price from another customer's history.
6. Extend expired quote validity.
7. Commit supplier procurement or order confirmation.

Required output posture:

```text
AI may say: "review required because supplier quote is expired"
AI must not say to customer: "our supplier cost is X and margin is Y"
```

## 14. Implementation Gate

Before implementation:

1. Define approved price book hierarchy.
2. Define minimum price and margin thresholds by category.
3. Define approval workflow owners.
4. Define quote expiration defaults.
5. Define customer-visible vs internal pricing fields.
6. Define AI-safe pricing views.
