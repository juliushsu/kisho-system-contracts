# Meat Admin Architecture Placeholder

Status: Proposed placeholder
Date: 2026-05-12
Scope: Future 熟成肉後台 architecture only

This document reserves the Meat Admin architecture boundary. It does not create database tables, migrations, API endpoints, production UI, or secrets.

## 1. Product Boundary

Meat Admin is a separate vertical SaaS surface from Sake Admin.

It must have:

- independent entrypoint: `/meat-admin`
- independent organization context: meat brand and/or meat factory
- independent roles
- independent sidebar config
- independent data contracts
- independent API contracts
- independent reporting and food-safety audit model

It must not be mixed into the current `/admin` or future `/sake-admin` sidebar.

## 2. Primary Actors

| Actor | Description |
| --- | --- |
| Meat brand | Brand owner or commercial owner of meat products. |
| Meat factory | Facility that performs bagging, aging, scanning, and operational work. |
| Meat operator | Worker who scans tags, updates sessions, and writes diary entries. |
| Meat viewer | Read-only QA, reporting, or stakeholder user. |
| Consumer app user | End consumer using future app flows; not a backoffice user. |

## 3. Proposed Route Namespace

All future backoffice routes should live under `/meat-admin`.

| Future route | Purpose |
| --- | --- |
| `/meat-admin` | Meat Admin dashboard. |
| `/meat-admin/brands` | 肉品廠商管理. |
| `/meat-admin/factories` | Factory management, if separated from brands. |
| `/meat-admin/tag-registry` | QR / NFC / RFID Tag Registry. |
| `/meat-admin/vacuum-bag-batches` | 真空熟成袋批次管理. |
| `/meat-admin/meat-batches` | 肉品批次 `meat_batch`. |
| `/meat-admin/aging-profiles` | 熟成參數 `aging_profile`. |
| `/meat-admin/aging-sessions` | 熟成任務 `aging_session`. |
| `/meat-admin/aging-diaries` | 熟成日記 `aging_diary`. |
| `/meat-admin/flavor-feedback` | 使用者喜好 `flavor_feedback`. |
| `/meat-admin/regional-preferences` | 地區偏好分布 `regional_preference`. |
| `/meat-admin/meat-database` | 和牛、澳和、美牛、部位、熟成天數. |
| `/meat-admin/food-safety` | 食安/召回/防偽掃描紀錄. |
| `/meat-admin/reports` | 肉品報表分析. |
| `/meat-admin/app-api-contract` | 未來 App API Contract. |

## 4. Future Data Domain Placeholders

These names are placeholders for contract discussion only.

| Domain | Placeholder entity | Notes |
| --- | --- | --- |
| Brand / factory | `meat_brand`, `meat_factory` | Organization model must be separate from sake merchant orgs unless an explicit platform org abstraction is approved. |
| Tag registry | `tag_registry` | QR / NFC / RFID identity and lifecycle. |
| Vacuum bag | `vacuum_bag_batch` | Bag lot traceability. |
| Meat batch | `meat_batch` | Product, origin, cut, quantity, brand/factory relation. |
| Aging profile | `aging_profile` | Temperature, humidity, target days, process rules. |
| Aging session | `aging_session` | Active process instance for one or more batches. |
| Aging diary | `aging_diary` | Operator notes, photos, inspections, readings. |
| Flavor feedback | `flavor_feedback` | Consumer or tasting feedback. |
| Regional preference | `regional_preference` | Aggregated preference by region; should avoid exposing personal data. |
| Food safety | `food_safety_event`, `recall_event`, `anti_counterfeit_scan` | Traceability, recall, scan history. |
| App API | `meat_app_contract` | Future consumer app read/write boundary. |

## 5. Sidebar Placeholder

| Section | Items | Lifecycle |
| --- | --- | --- |
| 廠商與工廠 | 肉品廠商管理 | placeholder |
| Tag Registry | QR / NFC / RFID Tag Registry | placeholder |
| 批次與熟成 | 真空熟成袋批次管理, 肉品批次, 熟成參數, 熟成任務, 熟成日記 | placeholder |
| 偏好資料 | 使用者喜好, 地區偏好分布 | placeholder |
| 肉品資料庫 | 和牛, 澳和, 美牛, 部位, 熟成天數 | placeholder |
| 食安治理 | 食安/召回/防偽掃描紀錄 | placeholder |
| 分析 | 肉品報表分析 | placeholder |
| API Contract | 未來 App API Contract | placeholder |

## 6. Role Visibility

| Role | Meat Admin visibility |
| --- | --- |
| `platform_owner` | Governance and support access, audited. |
| `platform_admin` | Delegated governance and support access, audited. |
| `meat_brand_admin` | Brand-scoped admin access. |
| `meat_factory_admin` | Factory-scoped admin access. |
| `meat_operator` | Operational aging, scanning, diary, and assigned task access. |
| `meat_viewer` | Read-only access. |
| `consumer_app_user` | No Meat Admin access. |
| `sake_org_admin` | No Meat Admin access by default. |
| `sake_store_manager` | No Meat Admin access. |
| `sake_staff` | No Meat Admin access. |

## 7. Isolation Rules

1. Meat Admin must not reuse Sake merchant roles.
2. Meat Admin must not rely on Sake sidebar config.
3. Meat Admin must not write to Sake inventory, shipment, order, catalog, or machine tables.
4. Shared platform identity is allowed only through an explicit platform organization abstraction.
5. Food-safety and recall events require audit-grade traceability from the first implementation.
6. Consumer app data must be separated from backoffice users and must follow privacy rules.
7. AI Agent access to Meat Admin data must be product-scoped, org-scoped, and approval-gated for write-like actions.

## 8. Open Questions Before Implementation

1. Should meat brand and meat factory be separate org types or a parent/child org hierarchy?
2. Will tag registry be owned by the platform, brand, or factory?
3. Which scans are public anti-counterfeit checks versus private operational events?
4. What personal data, if any, exists in flavor feedback?
5. Which App API contracts are read-only at launch?
6. What is the minimum audit log required for food-safety and recall workflows?

## 9. Non-Scope

This placeholder does not authorize:

- database migrations
- table creation
- production UI implementation
- API implementation
- RLS policy changes
- secret creation or storage
- changes to current Sake Admin behavior
