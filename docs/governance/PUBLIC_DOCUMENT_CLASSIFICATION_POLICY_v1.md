# Public Document Classification Policy v1

Status: `ACTIVE PUBLICATION GATE`  
Purpose: keep this public repository useful to Readdy without exposing engineering, customer or operational secrets.

## Classification

| Class | Destination | Examples |
|---|---|---|
| `PUBLIC_UI` | this repository, indexed under `docs/public/readdy/` | page structure, components, UI states, generic role names, de-identified examples |
| `PUBLIC_DOMAIN` | this repository after review | stable domain distinctions and read-only display semantics |
| `PRIVATE_AGENT` | private Agent Canonical workspace | architecture conflicts, security/RLS findings, internal identity mapping, staging evidence |
| `RESTRICTED_ENGINEERING` | private hardware/firmware workspace | PCB, ESP, firmware, register/address maps, protocol traces, HMI source/reverse engineering |
| `RESTRICTED_BUSINESS` | private business/partner workspace | prices, contracts, PII, partner payloads, credentials and commercial terms |

## Mandatory public scrub

Before publication, replace or remove:

- Personal/customer/vendor names not required for the product UI.
- Emails, phone numbers, addresses, tax IDs and free-text PII.
- Production tenant/project IDs, database UUIDs and device serials.
- IP/MAC/Wi-Fi/VPN/network topology values.
- Tokens, keys, secrets, cookies, auth headers, signed URLs and secret names that reveal deployment structure.
- Private API base URLs, internal table/RPC/function names and security findings.
- PCB/schematic/Gerber/BOM/firmware/HMI binaries, register maps and raw protocol traces.
- Raw screenshots or payloads containing customer, venue, machine or account identifiers.

Use generic fixtures such as `ORG-DEMO-001`, `STORE-DEMO-001`, `MACHINE-DEMO-01` and `PRODUCT-DEMO-001`. A de-identified ID must never preserve the original value through hashing or partial masking when linkage remains possible.

## Readdy contract rule

Readdy receives only what is necessary to render and navigate the website:

1. page and route purpose;
2. display fields and generic example values;
3. loading/empty/error/stale/permission states;
4. allowed user action and confirmation UX;
5. responsive/accessibility behavior;
6. explicit non-goals and backend-owned decisions.

Do not publish implementation credentials, machine-control details or enough infrastructure information to reconstruct private systems.

## Review gate

Every new public file must pass:

- secret-pattern scan;
- PII and customer-identity review;
- network/device identifier review;
- proprietary hardware/protocol review;
- source/provenance and status review;
- confirmation that examples are synthetic.

Uncertain material defaults to `PRIVATE_AGENT` until reviewed.

