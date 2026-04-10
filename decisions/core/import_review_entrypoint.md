# Import Review as Catalog Entry Point

## Decision

Import Review is the only controlled entry point for writing into the canonical catalog.

No direct writes to canonical tables are allowed outside this flow.

---

## Flow

External Data
↓
external_products_raw
↓
import_review_queue
↓ (human decision)
apply_import_merge_action_v1 (RPC)
↓
canonical catalog

---

## Rationale

External data is noisy, inconsistent, and untrusted.

Human review is required to:
- normalize data
- prevent duplication
- ensure semantic correctness

---

## Execution Model

All actions are explicit:

- create_product
- create_brand
- create_brewery
- merge_to_existing
- skip

Execution only happens when a reviewer confirms the action.

---

## Constraints

- staged data must exist before execution
- merge_to_existing requires explicit target_id
- bulk execution must respect all guards

---

## Implications

- Catalog quality is controlled
- No accidental or automatic writes
- All changes are traceable via merge_actions

---

## Non-goals

- Fully automated ingestion
- Direct ingestion into canonical tables

---

## Summary

Import Review is a human-in-the-loop pipeline that protects catalog integrity.
