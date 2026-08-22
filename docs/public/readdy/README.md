# Readdy Public UI Context

Status: `PUBLIC / DE-IDENTIFIED / UI-ONLY`  
Version: `1.0`  
Updated: 2026-08-22

This folder is the only current Readdy entry point for the KISSHO website UI. It intentionally excludes credentials, infrastructure identifiers, private partner data, hardware protocols, firmware, PCB/HMI sources and reverse-engineering evidence.

## Read order

1. [Readdy UI Handoff](READDY_UI_HANDOFF_v1.md)
2. [Platform UI Boundary](PUBLIC_PLATFORM_UI_BOUNDARY_v1.md)
3. [Catalog & Branding UI](PUBLIC_CATALOG_BRANDING_UI_CONTRACT_v1.md)
4. [PAD Sync Status UI](PUBLIC_PAD_SYNC_STATUS_UI_CONTRACT_v1.md)
5. [Spatial Topology UI](PUBLIC_SPATIAL_TOPOLOGY_UI_CONTRACT_v1.md)
6. [Roles & Engineering UI Boundary](PUBLIC_ROLE_AND_ENGINEERING_UI_BOUNDARY_v1.md)
7. [Dual Display Responsibility](PUBLIC_DUAL_DISPLAY_RESPONSIBILITY_v1.md)
8. [Generic UI fixture](../../../examples/readdy/readdy_ui_context.example.json)

## Binding domain distinctions

- Merchant Organization = commercial tenant identity.
- Store = physical venue; one Merchant Organization may own multiple Stores.
- Canonical Variant ≠ Supplier Listing ≠ Merchant Product ≠ Machine Assignment.
- Miss Sake is a read-only Presentation Plane.
- Network, provisioning, firmware and machine-control decisions are backend/hardware-owned and are not inferred by UI.

## Required UI states

Every data-driven surface must define `loading`, `ready`, `empty`, `stale`, `permission_denied`, `error` and `safe_unavailable` where applicable. Do not turn unknown state into a guessed value.

## Prohibited Readdy assumptions

- Do not treat demo identifiers as production identifiers.
- Do not add direct database writes or service credentials.
- Do not derive machine control from screen position, buttons or animations.
- Do not create a second product, organization, Store or machine identity system.
- Do not expose internal IDs in customer-facing copy.
