# Public Platform UI Boundary v1

## Visible hierarchy

```text
Merchant Organization
└── Store (one or many)
    ├── Store branding and spatial topology
    ├── Gateway summary (opaque status only)
    └── Machines
        ├── Merchant Product assignment
        └── Read-only operational status
```

The UI must never imply that an Organization and Store share an ID or are the same record.

## Product hierarchy

```text
Canonical Product / Variant
├── Supplier Listing (external commercial offer)
├── Merchant Product (tenant adoption and local commercial display)
└── Machine Assignment (physical configuration reference)
```

Supplier cost, distributor price, sellable inventory, MOQ and lead time belong to Supplier Listing/commercial views, not Canonical Variant.

## Authority presentation

| Operation type | UI behavior |
|---|---|
| Low-risk tenant read/edit | authenticated, scoped to current Organization/Store |
| Review/publish/provision/merge | send a typed request to an approved server workflow; show pending/result state |
| Machine control | outside public website scope |
| Miss Sake | read-only venue projection with source/freshness |

Role labels shown by the browser are presentation hints, not proof of authority. The server decides authorization.

## State truthfulness

Use `fresh → stale/LKG → unknown/safe unavailable`. Never infer online, inventory, assignment or availability from an animation, cached image, array order or elapsed time.

