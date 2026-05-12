# Project Governance Metadata Bridge

Status: Proposed
Date: 2026-05-12
Scope: Public-safe contracts-driven project metadata registry for Project Governance Dashboard and local Project Command Center

This contract defines the first bridge between the Project Governance Dashboard and the local Project Command Center. It is metadata-only and public-safe. It does not authorize database changes, migrations, production API calls, secret handling, or live infrastructure discovery.

## 1. Purpose

The Project Governance Metadata Bridge provides a shared project registry that can be read by:

- Project Governance Dashboard in the Readdy frontend
- local Project Command Center tools
- Codex and CTO review workflows
- future governance checks that need project status, ownership, paths, and environment aliases

The registry is intended to answer basic governance questions without requiring privileged access:

- Which product line does this project belong to?
- What lifecycle state is it in?
- Who owns it?
- Where are its docs and code paths?
- Which environments exist by alias?
- Is governance currently green, yellow, red, or unknown?

## 2. Why Version 1 Uses Contracts-Driven JSON Instead Of DB

Version 1 intentionally uses committed JSON files instead of a database.

Reasons:

1. Governance metadata must be reviewable in pull requests before any runtime system trusts it.
2. The first version must not require Supabase, Railway, or production credentials.
3. Project metadata is low-frequency configuration, not transactional application data.
4. A file registry gives Readdy, Codex, and local tools the same source of truth without network access.
5. Public-safe JSON is easier to audit for accidental secrets than ad hoc dashboard code or live API responses.
6. The registry can later be imported into a DB after field semantics stabilize.

The contract-first approach keeps Phase 1 safe: no DB schema, no migration, no external API connection, and no secret exposure.

## 3. Metadata Registry Location

Registry files live under:

```text
projects/
```

Schema:

```text
projects/schema/project-metadata.schema.json
```

Project metadata files:

```text
projects/*.project.json
```

Current Phase 1 registry files:

- `projects/kisho-platform.project.json`
- `projects/kisho-sake.project.json`
- `projects/kisho-meat.project.json`
- `projects/kisho-contracts.project.json`

## 4. Schema Field Summary

Each project metadata file follows `projects/schema/project-metadata.schema.json`.

| Field | Type | Description |
| --- | --- | --- |
| `project_key` | string | Stable lowercase key for the project. File names should match this key. |
| `display_name` | string | Human-readable project name. |
| `product_line` | enum | One of `platform`, `sake`, `meat`, `agent`, `contracts`, `lensbank`, `other`. |
| `lifecycle_status` | enum | One of `planning`, `pilot`, `staging`, `production`, `archived`. |
| `governance_status` | enum | One of `green`, `yellow`, `red`, `unknown`. |
| `github_repo_url` | string or null | GitHub repository URL only. No token, credential, or embedded auth. |
| `default_branch` | string or null | Default branch if known. |
| `docs_path` | string or null | Repo-relative or registry-relative documentation path. |
| `migration_path` | string or null | Repo-relative migration path if applicable. Must not imply migrations are authorized. |
| `frontend_path` | string or null | Repo-relative frontend path if applicable. |
| `backend_path` | string or null | Repo-relative backend path if applicable. |
| `supabase_project_alias` | string or null | Human-readable alias only. Never a service role key, JWT, password, or connection string. |
| `railway_service_alias` | string or null | Human-readable alias only. Never a Railway token or secret value. |
| `environments` | array | Public-safe environment metadata for `demo`, `staging`, `production`, or `local`. |
| `owner` | string or null | Owning person, role, or team. |
| `maintainers` | string[] | Public-safe maintainer names, handles, or role labels. |
| `last_verified_at` | string or null | ISO 8601 date or timestamp when metadata was last checked. |
| `notes` | string | Non-secret notes for human readers. |
| `prohibited_secret_fields` | string[] | Explicit reminder of secret field names that must never appear in registry values. |

Environment objects contain:

| Field | Type | Description |
| --- | --- | --- |
| `name` | enum | One of `demo`, `staging`, `production`, `local`. |
| `frontend_url` | string or null | Public or internal non-secret URL. Do not use signed URLs. |
| `backend_url` | string or null | Public or internal non-secret URL. Do not use signed URLs. |
| `supabase_alias` | string or null | Alias only. |
| `railway_alias` | string or null | Alias only. |
| `status` | enum | One of `planned`, `available`, `degraded`, `disabled`, `unknown`. |

Unknown fields should be represented as `null` or an empty string. Do not invent placeholder production URLs, project refs, service names, or repository paths.

## 5. Security Rules

The project registry is public-safe metadata only.

Allowed:

- public GitHub repository URLs
- repo-relative file paths
- product line labels
- lifecycle and governance statuses
- environment names
- human-readable aliases
- non-secret notes

Forbidden:

- API keys
- tokens
- passwords
- Supabase service role keys
- Supabase anon keys if copied from `.env`
- JWTs
- private keys
- database URLs
- connection strings
- webhook secrets
- signed URLs
- copied `.env` values
- Railway tokens
- cloud provider credentials

If a value is operationally sensitive, store an alias such as `kisho-sake-staging` instead of the real value. If even the alias is not approved for public docs, use `null`.

## 6. Project Command Center Read Model

The local Project Command Center should read the registry from disk:

1. Load `projects/schema/project-metadata.schema.json`.
2. Discover `projects/*.project.json`.
3. Validate each JSON file against the schema.
4. Render project cards from static metadata only.
5. Treat `supabase_project_alias` and `railway_service_alias` as display aliases, not credentials.
6. Never resolve aliases to live infrastructure unless a separate local-only connector is explicitly configured outside this public contract repository.

Recommended local display fields:

- display name
- product line
- lifecycle status
- governance status
- owner
- maintainers
- docs path
- frontend/backend path hints
- environment status by name
- last verified date

## 7. Readdy Dashboard Usage

The Readdy Project Governance Dashboard should use the registry as a static metadata source in the first dashboard skeleton.

Recommended behavior:

- read or bundle the project JSON files as static assets during development
- show one card per project
- group cards by `product_line`
- show lifecycle and governance badges
- list environment names and statuses
- show docs and path hints as plain text or links when safe
- show `null` or empty values as "Unknown" in the UI

The dashboard must not:

- call Supabase or Railway live APIs for Phase 1
- display secret fields
- ask users to paste tokens
- infer production readiness from a URL existing
- turn aliases into live API calls

## 8. Staging And Production Secret Rules

Staging and production metadata must never store secrets.

Allowed staging/production values:

- `name`: `staging` or `production`
- public frontend URL if approved
- public backend URL if approved
- service alias if approved
- status label

Forbidden staging/production values:

- service role keys
- auth tokens
- project passwords
- direct database connection strings
- copied `.env` entries
- deploy hooks
- private dashboard URLs with embedded credentials

For staging and production, prefer aliases and nulls until a value is explicitly approved as public-safe.

## 9. Future Migration Path

If the registry later moves into a DB, this JSON registry remains the source contract for field names and semantics.

Future DB-backed versions should:

- import from reviewed JSON
- preserve secret-free semantics
- keep aliases separate from credentials
- require a migration proposal before adding database tables
- preserve local Project Command Center read support
