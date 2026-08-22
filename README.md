# kisho-system-contracts

Public, de-identified KISSHO product and UI contracts for Readdy implementation and external review.

## Start here

- Readdy entry point: [Public Readdy UI Context](docs/public/readdy/README.md)
- Implementation handoff: [Readdy UI Handoff v1](docs/public/readdy/READDY_UI_HANDOFF_v1.md)
- Generic sample data: [readdy_ui_context.example.json](examples/readdy/readdy_ui_context.example.json)
- Publication boundary: [Public Document Classification Policy](docs/governance/PUBLIC_DOCUMENT_CLASSIFICATION_POLICY_v1.md)

Only files explicitly indexed under `docs/public/readdy/` are current Readdy input. Older contracts elsewhere in this repository remain historical or review-pending unless a current public index names them.

## Historical frontend version records

These links preserve prior Readdy version evidence. They are not the current cross-version UI authority; use `docs/public/readdy/` for new work.

- [Readdy VER289 Frontend Alignment Contract](contracts/readdy_ver289_frontend_alignment_v1.md)
- [Backoffice Entrypoint And Sidebar Governance](docs/platform/BACKOFFICE_ENTRYPOINT_AND_SIDEBAR_GOVERNANCE.md)
- [Readdy VER291 Backoffice Shell Review](docs/platform/READDY_VER291_BACKOFFICE_SHELL_REVIEW.md)
- [Readdy VER292 Baseline Acceptance](docs/platform/READDY_VER292_BASELINE_ACCEPTANCE.md)
- [Project Command Center Metadata Contract](docs/platform/PROJECT_COMMAND_CENTER_METADATA_CONTRACT.md)
- [Project Governance Metadata Bridge](docs/platform/PROJECT_GOVERNANCE_METADATA_BRIDGE.md)
- [Project Metadata Registry](projects/README.md)
- [Meat Admin Architecture Placeholder](docs/meat/MEAT_ADMIN_ARCHITECTURE_PLACEHOLDER.md)

## Security Rule

Public contract documents may list required environment variable names and API surfaces, but must never publish passwords, tokens, service-role keys, private keys, or copied `.env` values.

This repository must also exclude customer/person identifiers, production project IDs, device serials, local/network addresses, Wi-Fi details, signed URLs, proprietary PCB/firmware/HMI sources, raw partner payloads and reverse-engineering evidence. Those belong in the private Agent Canonical workspace.

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
