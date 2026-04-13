# Admin List View and Pagination Policy v1

## Status
Accepted

## Scope
Applies to all admin-side list pages that may scale to medium or large datasets, including but not limited to:

- `/admin/merchant/clients`
- `/admin/merchant/products`
- `/admin/merchant/orders`
- future modules: payments, shipments, reports, inventory

---

## A. Problem Statement

As system usage grows, datasets such as clients, products, and orders will increase significantly.

Without structured view and pagination policies:
- UI becomes cluttered and hard to scan
- Performance degrades due to large payloads
- Different user roles (new vs experienced) cannot efficiently operate

We must standardize:
1. Data presentation (card vs list)
2. Pagination behavior
3. Data loading strategy

---

## B. View Modes (Card vs List)

All applicable pages MUST support dual view modes:

### 1. Card View (Visual-first)
Used for:
- New users
- Sales / business roles
- Scenarios requiring visual recognition (e.g. product labels)

Characteristics:
- Rich layout (image, badges, metadata)
- Lower density
- Easier cognitive mapping

### 2. List View (Data-first)
Used for:
- Experienced users
- Operations / accounting
- Bulk scanning & fast lookup

Characteristics:
- Compact rows
- High density
- Faster navigation

---

## C. Default View Per Domain

| Domain   | Default View |
|----------|-------------|
| Clients  | Card        |
| Products | Card        |
| Orders   | List        |

---

## D. View Toggle Behavior

- A toggle control MUST be present on each page
  - e.g. `Card | List` switch
- User preference SHOULD be persisted (localStorage or profile-level)
- Switching view MUST NOT change data source or query logic
  - only presentation layer changes

---

## E. Pagination Policy

### 1. Mandatory Pagination

All list pages MUST implement pagination.
Loading full dataset in one request is prohibited.

---

### 2. Page Size

| View Type | Page Size |
|----------|----------|
| Card     | 12–24    |
| List     | 20–50    |

Exact values can be tuned per page but must remain bounded.

---

### 3. Pagination Mechanism

Preferred:
- `limit + offset`

Optional (future):
- cursor-based pagination

---

### 4. Query-Level Pagination (IMPORTANT)

Pagination MUST be applied at query level:
- Supabase RPC / SQL view must support:
  - `limit`
  - `offset`
- Frontend MUST NOT:
  - fetch all data then slice locally

---

## F. Sorting & Filtering

All list pages SHOULD support:

### Sorting
- created_at (default)
- updated_at
- name / display_name
- status

### Filtering
- domain-specific filters
  - clients: client_type, client_role
  - products: brand, category, listing_status
  - orders: status, date range

---

## G. Performance Constraints

- Each page load MUST stay within reasonable payload size
- Avoid:
  - large joins without limit
  - client-side full dataset operations
- Ensure compatibility with:
  - mobile devices
  - low-bandwidth environments

---

## H. Canonical Data Source Constraint

View mode MUST NOT affect data truth.

All views MUST read from the same canonical source:
- clients → `v_merchant_clients_canonical_v1`
- products → `v_merchant_product_sale_canonical_v1`
- orders → `merchant_orders_v1`

No alternate or fallback data paths allowed.

---

## I. Progressive Enhancement Strategy

Implementation SHOULD follow:

1. Introduce view toggle (UI only)
2. Add pagination at service layer
3. Refactor queries to support limit/offset
4. Optimize rendering for each view

---

## J. Non-Goals (v1)

This policy does NOT include:
- infinite scroll (may be introduced later)
- server-driven personalization
- advanced analytics layouts

---

## K. Future Extensions

Potential future enhancements:
- saved filters / presets
- role-based default views
- column customization (list view)
- bulk actions in list mode

---

## Conclusion

This policy ensures:
- scalable UI for growing datasets
- consistent UX across modules
- alignment with canonical data architecture

Card view supports human recognition.
List view supports operational efficiency.

Both are required.
