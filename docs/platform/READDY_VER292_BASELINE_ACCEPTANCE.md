# Readdy VER292 Baseline Acceptance

Status: Accepted Baseline
Date: 2026-05-12
Scope: Platform multi-vertical shell baseline acceptance for Readdy VER292

Reviewed package:

- `[local Readdy artifact: 皇上吉祥-Ver292]`

This document records acceptance of VER292 as a frontend shell baseline only. It does not authorize database changes, migrations, API changes, production data edits, or secret handling.

## 1. Verdict

VER292 is accepted as the Platform Multi-Vertical Shell Baseline.

This baseline confirms the multi-entry backoffice direction:

- `/platform` is the platform launcher and governance entrypoint.
- `/sake-admin` is the canonical Sake Admin route namespace.
- `/meat-admin` remains placeholder only.
- `/agent-workspace` remains a separate agent workspace entrypoint.
- `/project-governance` remains a placeholder page for governance contracts.

## 2. Verification Result

`vite build` passed for the VER292 downloaded package after installing local dependencies.

The package build script is:

```text
npm run build -> vite build
```

Observed result:

```text
npm run build -> passed
```

`npm run type-check` was also run as an additional diagnostic. It failed only because of pre-existing TypeScript debt outside the VER292 hotfix files, mainly in merchant, home, and services areas.

The type-check failures are not attributed to the VER292 baseline hotfix files:

- `src/pages/admin/shipment/page.tsx`
- `src/pages/admin/migration-notice/page.tsx`
- `src/config/navigation/projectGovernanceNavConfig.ts`
- `src/pages/project-governance/page.tsx`

## 3. Accepted Route Governance

### 3.1 `/sake-admin` canonical route

`/sake-admin` is accepted as the canonical route namespace for Sake Admin.

New UI links inside Sake Admin must route to `/sake-admin/*`, not `/admin/*`.

The shipment list escape found in VER291 has been resolved:

```text
/admin/shipment/${s.id} -> /sake-admin/shipment/${s.id}
```

### 3.2 `/admin` backward compatibility

The `/admin` backward compatibility strategy is accepted for this baseline.

Accepted behavior:

- `/admin` root shows the migration notice page.
- `/admin/*` child paths may remain temporarily available through the old shell so legacy entrypoints do not break.
- `/admin/*` is temporary compatibility only.
- New UI must not introduce links back into `/admin/*`.
- A later phase may replace `/admin/*` child routes with redirects and remove the old shell.

### 3.3 `/meat-admin` placeholder

`/meat-admin` remains placeholder only in VER292.

This baseline does not authorize real Meat Admin data flows, real Meat routes, shared Sake inventory reuse, or database-backed Meat features.

### 3.4 Project Governance placeholder

Project Governance remains a placeholder page in VER292.

The following sidebar items intentionally share `/project-governance` for now:

- Backoffice Entrypoint
- Sidebar Governance
- Project Metadata

Dedicated child pages may be introduced later:

- `/project-governance/entrypoint`
- `/project-governance/sidebar`
- `/project-governance/metadata`

## 4. Non-Changes Confirmed

VER292 acceptance does not include:

- DB schema changes
- Supabase migrations
- API or Edge Function changes
- secrets or `.env` value changes
- Meat Admin real data activation

## 5. Next Phase

Next phase: Project Governance Metadata Bridge.

The next phase should connect the Project Governance placeholder to the Project Command Center metadata contract without changing database schema, migrations, or secrets.
