# kisho-system-contracts

Public, de-identified KISSHO product and UI contracts for Readdy implementation and external review.

## Start here

- Readdy entry point: [Public Readdy UI Context](docs/public/readdy/README.md)
- Implementation handoff: [Readdy UI Handoff v1](docs/public/readdy/READDY_UI_HANDOFF_v1.md)
- Generic sample data: [readdy_ui_context.example.json](examples/readdy/readdy_ui_context.example.json)
- Publication boundary: [Public Document Classification Policy](docs/governance/PUBLIC_DOCUMENT_CLASSIFICATION_POLICY_v1.md)

Only files explicitly indexed under `docs/public/readdy/` are current Readdy input. Older contracts elsewhere in this repository remain historical or review-pending unless the public index explicitly names them.

## Security rule

This public repository must never contain passwords, tokens, service-role keys, private keys, copied `.env` values, customer/person identifiers, production project IDs, device serials, local/network addresses, Wi-Fi details, signed URLs, proprietary PCB/firmware/HMI sources, raw partner payloads or reverse-engineering evidence.

## Scope boundary

Public here:

- Page information architecture, UI state and interaction contracts.
- De-identified example records and display copy.
- Accessibility, responsive layout and error/empty/loading behavior.
- Product-domain distinctions needed to avoid misleading UI.

Private elsewhere:

- ESP/PCB/firmware development and fabrication evidence.
- Miss Sake unreleased media, credentials and staging/runtime evidence.
- PAD/HMI/MCU protocols, register maps and reverse-engineering sources.
- Infrastructure identifiers, tenant records, security findings and partner-confidential data.

Public documentation is a presentation contract, not authorization for database migration, machine control, partner writes or production deployment.
