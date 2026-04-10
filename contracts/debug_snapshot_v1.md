# Debug Snapshot API Contract v1

## RULES (CRITICAL)

- Frontend MUST NOT query Supabase tables directly
- Frontend MUST ONLY call:
  - /functions/v1/admin-debug/snapshot
  - /functions/v1/admin-debug/product-flow
- No data derivation on frontend
- No fallback logic
- Fail closed

---

## AUTH

Frontend must use:

Authorization: Bearer <USER_ACCESS_TOKEN>
apikey: <SUPABASE_ANON_KEY>

FORBIDDEN:
- Using anon key as Bearer token
- Hardcoding debug token in frontend

---

## REQUEST

### Snapshot

GET /functions/v1/admin-debug/snapshot

Query:
- orgId (required)
- workspace = merchant_ops | machine_ops | group_admin
- include = catalog,merchant_products,machines,assignments,inventory,events,users,demo_meta

---

## RESPONSE STRUCTURE

### meta

- generated_at
- environment
- workspace
- request_scope
- viewer_context
- data_flags
- provisional_flags

---

### summary

- catalog_product_count
- merchant_product_count
- machine_count
- active_assignment_count
- inventory_event_count
- machine_event_count

---

### integrity_checks (OBJECT, NOT ARRAY)

- orphan_merchant_products
- orphan_assignments
- machines_without_location
- assignments_without_product
- cross_org_leaks
- inactive_products_assigned
- duplicate_active_assignments

---

## FORBIDDEN FRONTEND BEHAVIOR

- DO NOT rename keys (snake_case must remain)
- DO NOT compute integrity checks
- DO NOT infer missing data
- DO NOT fallback to direct DB queries

---
## ORG SCOPE RULE

For admin-debug endpoints:

- orgId MUST use `stores.id`
- DO NOT use `merchant_orgs.org_id`
- orgSlug may only be used when it equals `stores.store_code`

If frontend sends merchant_orgs.org_id, resolver will return:
`org_scope_required_or_not_found`

---
## VERSION

v1.0 (2026-04-09)
