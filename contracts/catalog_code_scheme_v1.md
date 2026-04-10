# Catalog Code Scheme v1

## Purpose

This contract defines the human-readable coding scheme for canonical catalog entities.

These codes are for:
- search
- ERP / inventory integration
- reporting
- human recognition

These codes are NOT the primary relational keys.
System relations must still use UUIDs.

---

## Scope

Covered entities:
- brewery
- brand
- product_master
- product_variant

---

## General Rules

1. Codes must be stable and human-readable.
2. UUID remains the true system key.
3. Codes should avoid embedding mutable business states unless explicitly defined.
4. Inventory-layer attributes must not be encoded into canonical product identity unless they are true variant attributes.

---

## Brewery Code

### Format
`{COUNTRY}-{PREF}-{BREWERY}`

### Example
`JP-TKO-OZAWA`

### Meaning
- `COUNTRY`: ISO-like country code
- `PREF`: prefecture / regional code
- `BREWERY`: romanized brewery slug

### Notes
- Brewery slug should be normalized and uppercase
- Example regional code:
  - `TKO` = Tokyo
  - `NGT` = Niigata
  - `KYT` = Kyoto

---

## Brand Code

### Format
`{BREWERY_CODE}-{BRAND}`

### Example
`JP-TKO-OZAWA-SAWANOI`

### Notes
- Brand is scoped under brewery
- Same brand name under different breweries must not collide

---

## Product Master Code

### Format
`{BRAND_CODE}-{NNN}`

### Example
`JP-TKO-OZAWA-SAWANOI-001`

### Meaning
- `NNN`: sequential product number within the brand

### Notes
- Product master represents the core product identity
- Do not encode inventory or batch information here
- Do not encode seasonal / lot-specific states here unless they are part of long-lived product identity

---

## Product Variant Code

### Format
`{PRODUCT_MASTER_CODE}-{VOL}-{TYPE}-{ATTR1?}-{ATTR2?}`

### Example
`JP-TKO-OZAWA-SAWANOI-001-720-JUN-NAM`

### Meaning
- `VOL`: bottle volume in ml
- `TYPE`: canonical type code
- `ATTR*`: optional stable variant attributes

### Notes
- Variant code should only include attributes that define a stable sellable variant
- Avoid stuffing temporary campaign / lot / inventory states into variant code

---

## Recommended Type Codes

### Product Type
- `FUT` = 普通酒
- `HON` = 本釀造
- `GIN` = 吟釀
- `DGI` = 大吟釀
- `JUN` = 純米
- `JGI` = 純米吟釀
- `JDG` = 純米大吟釀
- `NIG` = 濁酒
- `SPA` = 發泡
- `KOS` = 古酒

### Stable Attributes
- `NAM` = 生酒
- `HIA` = 火入
- `GEN` = 原酒
- `MUR` = 無濾過
- `ORI` = おりがらみ
- `LTD` = 限定
- `SEA` = 季節

### Seasonal Attributes (optional, only if variant-defining)
- `SPR` = 春
- `SUM` = 夏
- `AUT` = 秋
- `WIN` = 冬

---

## Barcode Rule

Barcode is treated as a strong identifier at the variant level.

If a barcode already exists in the canonical catalog:
- do not create a new variant blindly
- require merge or explicit duplicate review

Barcode should not replace UUID.
Barcode is a canonical identification aid, not the system primary key.

---

## Explicit Exclusions

The following must NOT be encoded into canonical code identity:

- batch number
- expiration date
- storage location
- inventory quantity
- shelving status
- receiving status

These belong to inventory / batch layers, not catalog identity.

---

## Summary

- Brewery code identifies producer
- Brand code identifies brand under producer
- Product master code identifies product family
- Variant code identifies sellable stable variant
- UUID remains the true relational key
