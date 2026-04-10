# DebugDrawer Object-safe Rendering Decision

## Problem
React error #31 occurred because `meta.request_scope` was rendered directly as a React child.

Actual API response shape:
`meta.request_scope = { org_id, location_id, machine_id }`

Frontend had incorrectly assumed:
`request_scope: string | null`

## Decision
All DebugDrawer fields must be object-safe:
- primitive values may render directly
- object values must be explicitly stringified or rendered via structured rows
- no raw object may be passed into JSX children

## Scope
Applies to:
- meta.request_scope
- meta.viewer_context
- meta.data_flags
- meta.provisional_flags
- integrity_checks
- any future debug response fields
