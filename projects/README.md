# Project Metadata Registry

Status: Proposed
Date: 2026-05-12

This directory contains the contracts-driven project metadata registry for Kisho Project Governance.

The registry is public-safe metadata only. It is designed for:

- Project Governance Dashboard
- local Project Command Center
- Codex review workflows
- Readdy dashboard skeletons

It must not contain secrets or live credentials.

## File Layout

```text
projects/
  README.md
  schema/
    project-metadata.schema.json
  *.project.json
```

## Naming Rules

Each project file should be named:

```text
<project_key>.project.json
```

Examples:

- `kisho-platform.project.json`
- `kisho-sake.project.json`
- `kisho-meat.project.json`
- `kisho-contracts.project.json`

The `project_key` field inside the file should match the file name prefix.

Use lowercase kebab-case for new project keys unless a legacy project key already exists.

## Metadata Purpose

Each project JSON describes:

- project identity
- product line
- lifecycle status
- governance status
- repository and branch hints
- docs, migration, frontend, and backend paths
- Supabase and Railway aliases
- environment names and public-safe statuses
- owner and maintainers
- last verified date
- non-secret notes

Unknown values should be `null` or an empty string. Do not invent fake URLs, service names, project refs, or repository paths.

## Security Rules

Allowed values:

- public repository URLs
- repo-relative paths
- lifecycle labels
- governance labels
- environment names
- public-safe aliases
- non-secret notes

Forbidden values:

- API keys
- tokens
- passwords
- Supabase service role keys
- Supabase anon keys copied from `.env`
- JWTs
- private keys
- database URLs
- connection strings
- webhook secrets
- signed URLs
- copied `.env` values
- Railway tokens
- cloud provider credentials

Use aliases instead of real operational identifiers when there is any doubt. If an alias is not clearly public-safe, use `null`.

## Validation

Validate project files against:

```text
projects/schema/project-metadata.schema.json
```

Consumers should fail closed if a file contains unknown fields, invalid enum values, or values that look like credentials.
