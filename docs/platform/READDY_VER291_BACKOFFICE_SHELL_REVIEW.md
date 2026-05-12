# Readdy VER291 Backoffice Shell Review

Status: Reviewed
Date: 2026-05-12
Scope: Readdy VER291 downloaded package code review and runtime smoke guidance

Reviewed package:

- `/Users/chishenhsu/Downloads/皇上吉祥-Ver291`

This review is code and architecture audit only. It does not authorize database changes, migrations, secret handling, or production UI rollout.

## 1. Verdict

VER291 is materially improved over VER290 and addresses the main compile-risk and shell governance issues raised in the previous review:

- navigation config imports now use `./types`
- login success now routes to `/sake-admin`
- `orgContext` now bridges module state to legacy `window.currentMerchantOrgId` and `window.subscribeToOrgChange`
- ProductContextHeader has truncation/shrink guards
- Platform Launcher allows entering `/meat-admin` placeholder
- Project Governance nav items no longer point to missing child routes
- many hardcoded old `/admin/...` links were moved to `/sake-admin/...`

Recommendation: accept VER291 as a hotfix candidate after smoke testing, but do not call it fully complete until the remaining medium issues below are addressed or explicitly accepted as temporary compatibility behavior.

## 2. Critical Issues

No critical code issue was confirmed from static review.

Build/type-check were not executed successfully because the downloaded package does not include installed dependencies:

```text
npm run type-check -> sh: tsc: command not found
npm run build -> sh: vite: command not found
```

This means build verification remains pending until dependencies are installed in a safe local frontend workspace.

## 3. Medium Issues

### 3.1 `/admin/*` backward compatibility strategy is still ambiguous

`src/router/config.tsx` still mounts old `/admin/*` child routes directly under `OldAdminLayout`:

- `/admin/stores`
- `/admin/devices`
- `/admin/merchant/*`
- `/admin/inventory/*`
- `/admin/shipment`
- `/admin/agent-workspace`

At the same time, `src/pages/admin/migration-notice/page.tsx` contains a `PATH_MAP` intended to redirect old paths to new `/sake-admin/*` or `/agent-workspace`.

Because the router defines concrete children for the old paths, the migration notice only renders for `/admin` root. Old paths still open the legacy shell instead of redirecting. This may be acceptable as strict backward compatibility, but then the migration notice mapping is misleading and untested for those paths.

Recommendation:

Choose one strategy:

1. soft compatibility: keep old `/admin/*` pages live, and remove/rename redirect claims from migration notice
2. migration redirect: replace old child routes with redirect elements so `/admin/*` goes to the new namespaces

### 3.2 One remaining new-shell escape from shipment list

`src/pages/admin/shipment/page.tsx` still links shipment detail to old `/admin/shipment/:id`:

```tsx
to={`/admin/shipment/${s.id}`}
```

When rendered under `/sake-admin/shipment`, clicking a shipment number will move the user back into the old `/admin` shell.

Recommendation:

Change to:

```tsx
to={`/sake-admin/shipment/${s.id}`}
```

or introduce a route helper for Sake Admin links so reused legacy page components do not hardcode namespaces.

### 3.3 Project Governance sidebar has repeated route targets

VER291 changed Project Governance nav items to all target `/project-governance`, avoiding missing child routes. This prevents 404s, but all three sidebar items now resolve to the same page:

- Backoffice Entrypoint
- Sidebar Governance
- Project Metadata

Recommendation:

Accept for placeholder/demo only, or add section anchors / child routes later:

- `/project-governance/entrypoint`
- `/project-governance/sidebar`
- `/project-governance/metadata`

### 3.4 `orgContext` bridge is acceptable short-term but still not reactive state

`src/context/orgContext.ts` now updates:

- module variable `currentMerchantOrgId`
- `window.currentMerchantOrgId`
- `window.subscribeToOrgChange`
- listener Set

This is acceptable as a compatibility bridge. It still has future limitations:

- not React Context or Zustand, so components must manually subscribe
- no multi-tab `storage` event sync
- no source-of-truth object containing org metadata
- page code can still read a stale imported binding if it does not subscribe

Recommendation:

Keep for VER291 hotfix. Plan a later refactor to React Context or Zustand when the shell stabilizes.

## 4. Low Issues

1. `AdminShell` still uses the old `admin` / `store_owner` role vocabulary. This is acceptable for Sake Admin compatibility, but future Platform/Meat roles will need the contract role model.
2. `/admin/login` remains the shared login route. Acceptable for now, but future UX may prefer `/login` or `/platform/login`.
3. Meat Admin nav is correctly `comingSoon`, but direct typed routes like `/meat-admin/batches` will 404 because only the index placeholder exists. This is acceptable if sidebar click prevention is the only intended access path.
4. Some comments still mention old `/admin/...` routes. They are documentation noise, not runtime blockers.

## 5. Positive Findings

### Router

- New namespaces exist:
  - `/platform`
  - `/sake-admin`
  - `/meat-admin`
  - `/agent-workspace`
  - `/project-governance`
- `/sake-admin` covers the major VER289 `/admin` feature set:
  - stores
  - devices
  - sake-products
  - reports
  - top10
  - machine-monitor
  - merchant catalog/brands/products/clients/orders/reports/storefront/machine-config
  - catalog import-review
  - inventory dashboard/receipts/batches/movements
  - shipment list/detail
- `/agent-workspace` exists as the new top-level route.
- `/meat-admin` only mounts placeholder content.

### AdminShell

- Auth guard still checks Supabase user and `user_roles`.
- Missing role signs out and redirects to `/admin/login`.
- Org switcher still sets active org, `currentMerchantOrgId`, localStorage, and notifies listeners.
- Logout signs out, clears org context/localStorage, and redirects to login.
- Sidebar config rendering supports `comingSoon` disabled items.
- Main content now has `md:ml-64` to reduce fixed-sidebar overlap risk.

### ProductContextHeader

- Product, org, env, and lifecycle badges are present.
- VER291 adds `truncate`, `min-w-0`, and `shrink-0` guards to reduce overflow.

### Centralized Nav

- Sake Admin nav paths match registered `/sake-admin` routes.
- Meat Admin nav items are all `comingSoon`.
- Agent Workspace nav points to `/agent-workspace`.
- Project Governance nav no longer points to unregistered child paths.

### Legacy imports

No direct import from `src/pages/admin/layout.tsx` was found for `subscribeToOrgChange` or `currentMerchantOrgId`.

## 6. Runtime Smoke Test Checklist

Run these after dependencies are installed and the app is pointed at a safe demo/staging environment:

1. Login with an authorized user; confirm success lands on `/sake-admin`, not `/admin/stores`.
2. Open `/platform`; confirm four launcher cards render and Sake/Meat/Agent/Governance can enter expected routes.
3. Open `/sake-admin/stores`; confirm list renders.
4. From a store card, open hourly/detail flow; confirm it stays in `/sake-admin/stores/:id/hourly`.
5. Open `/sake-admin/merchant/orders`; confirm orders load and "go to clients" CTAs stay in `/sake-admin`.
6. Switch org from sidebar; confirm merchant catalog/brands/products/clients/orders reload without refresh.
7. Open `/sake-admin/inventory`; click receipts, batches, movements; confirm namespace remains `/sake-admin`.
8. Open `/sake-admin/shipment`; click a shipment number. Expected after hotfix: `/sake-admin/shipment/:id`. Current VER291 risk: `/admin/shipment/:id`.
9. Open `/admin`; confirm migration notice appears.
10. Open `/admin/stores`; confirm the intended policy:
    - if soft compatibility: old shell opens
    - if redirect migration: it redirects to `/sake-admin/stores`
11. Open `/agent-workspace`; confirm Agent shell renders.
12. Open `/admin/agent-workspace`; confirm whether old-shell access is intentionally allowed or should redirect.
13. Open `/meat-admin`; confirm only placeholder content and disabled Coming Soon nav items are present.
14. Logout; confirm session ends, org localStorage clears, and login route is shown.

## 7. Suggested Readdy Hotfix Prompt

Please prepare VER291.1 hotfix:

1. Change the remaining shipment list detail link from `/admin/shipment/${id}` to `/sake-admin/shipment/${id}`.
2. Decide `/admin/*` compatibility policy:
   - either keep old child routes live and adjust migration notice copy
   - or replace old child routes with redirects to the new namespace
3. If Project Governance sidebar items are intended to be separate pages, add child routes or section anchors. If placeholder-only, mark repeated `/project-governance` hrefs as intentional.
4. Run `npm install`, `npm run type-check`, and `npm run build` in a non-secret local/staging workspace and report results.

## 8. Project Command Center Readiness

VER291 is close enough to start planning the Project Command Center metadata bridge, but implementation should wait until:

1. the shipment link escape is fixed or accepted
2. `/admin/*` compatibility policy is explicitly chosen
3. local type-check/build has passed

## 9. Non-Scope Confirmation

This review did not change:

- database schema
- migrations
- RLS policies
- secrets
- `.env` values
- production UI deployment

The downloaded `.env` file was not opened or copied into the public contracts repository.
