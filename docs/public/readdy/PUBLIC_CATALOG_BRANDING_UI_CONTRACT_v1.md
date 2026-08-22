# Public Catalog & Branding UI Contract v1

## Catalog surfaces

Catalog browse/detail should visually separate:

- Brewery and Brand.
- Product Master: stable beverage concept and intrinsic attributes.
- Product Variant: volume/package/SKU/label asset.
- Supplier Listing: external SKU, commercial terms and observed supply.
- Merchant Product: Store/tenant adoption, local price/copy/publication.
- Machine Assignment: placement/configuration reference only.

Use opaque demo codes. Do not invent production code syntax or infer identity from filenames.

## Catalog states

| State | UI treatment |
|---|---|
| canonical/reviewed | normal detail with provenance/status |
| candidate/unreviewed | review badge and disabled publication action |
| conflict | comparison panel and reviewer decision required |
| retired | retained for history, excluded from new selection |
| missing asset | safe placeholder; identity remains visible |

## Branding editor

Required flow: upload candidate → validate → preview supported breakpoints → save draft → review diff → publish/rollback through server workflow.

Show:

- logo preview with contain scaling and safe padding;
- Store display name preview and deterministic wrapping/truncation;
- desktop/tablet/mobile safe-area preview;
- draft/published/version/source status;
- upload validation errors without exposing storage paths or signed URLs.

Do not render customer-supplied script, arbitrary HTML, executable font or remote embed. A failed candidate keeps the last validated branding or approved default.

