# Public PAD Sync Status UI Contract v1

This is a monitoring/configuration UX contract. It does not specify private endpoints, storage paths, credentials or device-control logic.

## Status model

| Status | Meaning shown to user | Allowed presentation |
|---|---|---|
| `FRESH` | latest validated catalog/assets active | normal |
| `STALE` | validated cache retained; refresh pending | visible stale badge |
| `VERY_STALE` | catalog may render but operational freshness is not implied | warning and restricted claims |
| `SYNCING` | candidate downloading/verifying | progress; active version remains unchanged |
| `CONFLICT` | same version/content integrity conflict | reject candidate; reviewer attention |
| `NO_VALID_CACHE` | no validated candidate or prior cache | safe default/configuration state |
| `ERROR` | sync failed | error class, retry eligibility and last success |

## UI requirements

- Show current active version, last successful activation, candidate status and item counts.
- Separate catalog/asset freshness from machine/availability freshness.
- Never flash partially downloaded/unverified content.
- Manual refresh is a fixed scoped action, not an arbitrary URL or file operation.
- Diagnostics redact query strings, credentials, local paths and infrastructure identifiers.
- Active payment/operation surfaces defer disruptive visual refresh to a safe boundary.

