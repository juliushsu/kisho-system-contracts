# Catalog Governance

## Decision

Only authorized users can write to the canonical catalog.

Write access is controlled by organization-scoped roles.

---

## Roles

- viewer: read-only
- contributor: can propose changes
- curator: can execute changes

---

## Scope

Permissions are always evaluated within an organization scope.

A user's role in one organization does not grant catalog write access in another organization.

---

## Execution Rules

- Only curators can execute merge actions
- Contributors may prepare or propose changes, but cannot directly mutate canonical entities
- All actions must be tied to:
  - user_id
  - org_id

---

## Enforcement

All canonical write operations must be validated at the RPC / database level.

Client-side checks are not sufficient.

---

## Implications

- Prevents accidental catalog corruption
- Supports scalable multi-user collaboration
- Keeps canonical catalog globally consistent
- Preserves auditability and traceability

---

## Non-goals

- Direct client-side authorization only
- Organization-owned copies of canonical products

---

## Summary

Catalog writes are privileged operations and must be explicitly controlled by org-scoped roles.
