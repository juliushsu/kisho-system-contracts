# Project Command Center Metadata Contract

Status: Proposed
Date: 2026-05-12
Scope: Non-secret project metadata for local Project Command Center integration

This contract defines metadata that can be read by a local Project Command Center to show project status, repository links, deployment aliases, documentation paths, migration paths, and governance status across 皇上吉祥 product lines.

This is a public metadata contract. It must never contain tokens, API keys, database passwords, Supabase service role keys, private keys, copied `.env` values, or credentials.

## 1. Design Goals

1. Provide a consistent project inventory across platform, sake, meat, agent, and contracts work.
2. Keep all values non-secret and safe to commit.
3. Use aliases for external services when a real identifier is sensitive or operationally risky.
4. Make governance status visible without granting operational access.
5. Support demo, staging, and production environments without leaking credentials.

## 2. Required Fields

| Field | Type | Required | Description |
| --- | --- | --- | --- |
| `project_key` | string | yes | Stable unique key, e.g. `kisho-sake-admin`. |
| `product_line` | enum | yes | One of `platform`, `sake`, `meat`, `agent`, `contracts`. |
| `github_repo_url` | string | yes | Public or private GitHub repo URL. URL only; no token. |
| `default_branch` | string | yes | Default branch, e.g. `main`. |
| `supabase_project_ref` | string | no | Alias only, not a credential. Prefer `supabase_project_alias` if the real ref should not be public. |
| `railway_service_alias` | string | no | Human-readable alias only. |
| `environment` | enum | yes | One of `demo`, `staging`, `production`. |
| `docs_path` | string | no | Repo-relative documentation path. |
| `migration_path` | string | no | Repo-relative migration path, if applicable. |
| `owner` | string | yes | Team, person, or role owner. |
| `governance_status` | enum | yes | One of `draft`, `proposed`, `accepted`, `needs_review`, `deprecated`, `blocked`. |
| `last_verified_at` | string | yes | ISO 8601 timestamp or date when metadata was last checked. |

## 3. Optional Fields

| Field | Type | Description |
| --- | --- | --- |
| `display_name` | string | Human-readable project name. |
| `description` | string | Short non-secret summary. |
| `local_path_hint` | string | Optional local path hint. Must not assume every machine has the same path. |
| `contract_docs` | string[] | Repo-relative paths to important contract docs. |
| `healthcheck_url` | string | Public or internal non-secret health URL. Do not include signed URLs. |
| `runbook_path` | string | Repo-relative operational runbook path. |
| `readdy_status` | string | Freeform UI handoff status. |
| `risk_level` | enum | `low`, `medium`, `high`. |
| `notes` | string | Non-secret notes. |

## 4. Product Line Enum

```json
["platform", "sake", "meat", "agent", "contracts"]
```

## 5. Environment Enum

```json
["demo", "staging", "production"]
```

## 6. Governance Status Enum

```json
["draft", "proposed", "accepted", "needs_review", "deprecated", "blocked"]
```

## 7. Example Metadata

```json
{
  "project_key": "kisho-system-contracts",
  "display_name": "Kisho System Contracts",
  "product_line": "contracts",
  "github_repo_url": "https://github.com/juliushsu/kisho-system-contracts",
  "default_branch": "main",
  "supabase_project_ref": "none",
  "railway_service_alias": "none",
  "environment": "production",
  "docs_path": "docs",
  "migration_path": "none",
  "owner": "platform_owner",
  "governance_status": "proposed",
  "last_verified_at": "2026-05-12",
  "contract_docs": [
    "docs/platform/BACKOFFICE_ENTRYPOINT_AND_SIDEBAR_GOVERNANCE.md",
    "docs/platform/PROJECT_COMMAND_CENTER_METADATA_CONTRACT.md",
    "docs/meat/MEAT_ADMIN_ARCHITECTURE_PLACEHOLDER.md"
  ]
}
```

## 8. JSON Schema Draft

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/juliushsu/kisho-system-contracts/docs/platform/project-command-center-metadata.schema.json",
  "title": "Project Command Center Metadata",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "project_key",
    "product_line",
    "github_repo_url",
    "default_branch",
    "environment",
    "docs_path",
    "owner",
    "governance_status",
    "last_verified_at"
  ],
  "properties": {
    "project_key": {
      "type": "string",
      "pattern": "^[a-z0-9][a-z0-9-_.]*$"
    },
    "display_name": {
      "type": "string"
    },
    "description": {
      "type": "string"
    },
    "product_line": {
      "type": "string",
      "enum": ["platform", "sake", "meat", "agent", "contracts"]
    },
    "github_repo_url": {
      "type": "string",
      "format": "uri"
    },
    "default_branch": {
      "type": "string"
    },
    "supabase_project_ref": {
      "type": "string",
      "description": "Alias only. Must not be a service role key, JWT, password, or connection string."
    },
    "railway_service_alias": {
      "type": "string",
      "description": "Alias only. Must not be a Railway token or environment value."
    },
    "environment": {
      "type": "string",
      "enum": ["demo", "staging", "production"]
    },
    "docs_path": {
      "type": "string"
    },
    "migration_path": {
      "type": "string"
    },
    "owner": {
      "type": "string"
    },
    "governance_status": {
      "type": "string",
      "enum": ["draft", "proposed", "accepted", "needs_review", "deprecated", "blocked"]
    },
    "last_verified_at": {
      "type": "string",
      "description": "ISO 8601 date or timestamp."
    },
    "local_path_hint": {
      "type": "string"
    },
    "contract_docs": {
      "type": "array",
      "items": {
        "type": "string"
      }
    },
    "healthcheck_url": {
      "type": "string",
      "format": "uri"
    },
    "runbook_path": {
      "type": "string"
    },
    "readdy_status": {
      "type": "string"
    },
    "risk_level": {
      "type": "string",
      "enum": ["low", "medium", "high"]
    },
    "notes": {
      "type": "string"
    }
  }
}
```

## 9. Secret Handling Rules

Never store:

- tokens
- API keys
- database passwords
- Supabase service role keys
- JWTs
- private keys
- copied `.env` values
- signed URLs
- connection strings containing credentials

Allowed:

- GitHub repository URLs
- branch names
- documentation paths
- migration paths
- service aliases
- Supabase aliases
- environment labels
- non-secret owner names or role names
- governance state

## 10. Validation Guidance

Project Command Center should reject metadata if:

1. any field value looks like a token, password, private key, JWT, or connection string with credentials
2. `github_repo_url` contains embedded credentials
3. `supabase_project_ref` contains a service role key or JWT-like value
4. `railway_service_alias` contains a Railway token
5. `environment` is not one of the approved enum values
6. `product_line` is not one of the approved enum values

The UI may display warning badges for `needs_review`, `deprecated`, and `blocked`, but it must not expose operational credentials or secret-derived status.
