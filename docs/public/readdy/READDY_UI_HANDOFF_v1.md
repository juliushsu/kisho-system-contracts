# Readdy UI Handoff v1

Status: `PUBLIC UI IMPLEMENTATION CONTRACT`  
Target: responsive SaaS backoffice and read-only presentation surfaces

## Product outcome

Create a coherent website UI for a multi-tenant sake platform. The website helps platform staff and merchant teams understand organizations, physical Stores, catalog products, supplier offers, merchant adoption, machine placement and operational read status without exposing infrastructure or machine-control internals.

## Navigation

| Section | Primary pages | Audience |
|---|---|---|
| Overview | portfolio KPIs, attention queue, freshness/status cards | platform and merchant management |
| Organizations | organization list/detail, Store membership | platform admin; scoped merchant viewer |
| Stores | Store list/detail, branding, topology, read status | scoped merchant team |
| Catalog | brewery/brand/product/variant browse and detail | catalog/editor roles |
| Supplier offers | listing comparison, price/availability freshness | authorized procurement roles |
| Merchant products | adoption status, local display/price, publication readiness | merchant management |
| Machines | read-only fleet/Store status, assignment and freshness | scoped operations |
| Miss Sake | venue read-plane preview, publication/freshness badge | authorized read-plane operators |
| Governance | audit/event timeline, review queue, contract status | platform reviewers |

Do not add a raw MCU console, register editor, arbitrary API runner, credential viewer or unrestricted file browser.

## Global shell

- Desktop: persistent left navigation, organization/Store context selector and utility header.
- Tablet: collapsible rail; critical status and actions remain visible without hover.
- Mobile: drawer navigation and stacked cards; tables provide compact card alternatives.
- Context selector must visibly distinguish Merchant Organization from Store.
- Environment/origin badges use generic values such as `DEMO`, `STAGING`, `LIVE`; never disguise fixture or stale state.

## Core component rules

- Status chips use text plus color; never color alone.
- Destructive or privileged actions show target, old/new diff, reason and confirmation.
- Empty state explains why no data exists and the permitted next action.
- Permission denial never leaks hidden resource details.
- Stale/offline data remains visible only with explicit freshness and source labels.
- Customer-facing views use display labels; internal identifiers stay in authenticated technical details.

## Data boundary

Use the provided synthetic fixture for layout and state coverage. Treat all mutations as mocked UI callbacks until a separately approved API contract exists. Readdy must not invent table names, RPCs, machine commands or authorization rules.

## Delivery checklist

- Responsive pages for the navigation above.
- Component/state coverage for loading, empty, stale, denied and error.
- WCAG-aware keyboard navigation, focus visibility, contrast and accessible labels.
- Consistent domain labels and no Merchant Org/Store conflation.
- No secrets, private URLs, network addresses, production IDs or hardware protocol content.
