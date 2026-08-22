# Public Spatial Topology UI Contract v1

## Vocabulary

Use nine relative zones: `NW`, `N`, `NE`, `W`, `CENTER`, `E`, `SW`, `S`, `SE`. These are display/grouping codes, not pixel coordinates or machine-control addresses.

## Editor

The authenticated editor shows a 3×3 grid plus an accessible list/dropdown alternative. It supports:

- search/filter for larger fleets;
- assign, remove, enable and disable known demo Machines;
- multiple Machines per eligible zone;
- localized customer-friendly labels;
- change diff, affected count and draft validation;
- immutable version publication/rollback through an approved server workflow.

Do not derive position from drag coordinates, list order, machine-number suffix or array index. Unknown/conflicting topology must display neutral guidance.

## Customer-facing behavior

Customer copy uses friendly labels such as “right-side machine”; it never speaks internal IDs, serials, Gateway IDs or slot addresses. Sold-out, offline, disabled, maintenance and unknown machines are not presented as actionable recommendations.

Topology is guidance only. It never authorizes dispense or defines an MCU command.

