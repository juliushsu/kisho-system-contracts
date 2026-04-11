Modern Delivery and Signature Flow v1

Status

Accepted (planning decision)

⸻

Context

Traditional alcohol and beverage distribution workflows often rely on:
	•	dot-matrix printed triplicate delivery notes
	•	paper-based recipient signatures
	•	manual invoice mailing
	•	courier receipt records stored outside the system
	•	weak linkage between delivery, shipment, inventory, and customer proof

This creates several operational problems:
	•	high manual labor cost
	•	poor traceability
	•	low delivery status visibility
	•	difficult audit trail
	•	fragmented proof of delivery

The system should move toward a modern digital delivery flow.

⸻

Core Decision

The delivery and signing process must become digital-first, not paper-first.

This means:
	•	shipment is the operational outbound object
	•	delivery proof must be recorded digitally
	•	recipient confirmation must be traceable
	•	paper documents may still exist, but are not the system source of truth

⸻

Scope of This Decision

This decision defines the future direction for:
	•	delivery execution
	•	recipient signature
	•	proof of delivery
	•	delivery status traceability

It does not yet define:
	•	final DB schema
	•	courier API integration
	•	invoice generation
	•	accounting treatment

⸻

Delivery Modes

The system must support at least the following delivery modes:

1. Sales Direct Delivery

A salesperson personally delivers goods to the customer.

Characteristics:
	•	delivery is executed in person
	•	recipient may sign on phone / tablet
	•	suitable for restaurant / shop visits

2. Courier Delivery

Goods are handed to a third-party logistics provider.

Characteristics:
	•	system records shipment event
	•	external courier handles physical delivery
	•	signature or proof may come from courier system
	•	final proof may be URL / uploaded image / API callback

3. Pickup

Customer or partner picks up goods directly.

Characteristics:
	•	simplified signature or confirmation flow
	•	may still require recipient acknowledgment

⸻

Proof of Delivery (POD) Principles

Every completed delivery should be associated with one or more proof records.

Possible proof types:
	•	handwritten signature on mobile device
	•	courier delivery confirmation
	•	uploaded signed receipt image
	•	delivery confirmation URL
	•	timestamped manual acknowledgment

The system should treat POD as a structured record, not as a paper assumption.

⸻

Signature Principles

Digital Signature First

Recipient confirmation should prefer digital capture:
	•	mobile phone browser
	•	tablet signing surface
	•	embedded signature canvas

Signature Metadata

If signature is collected, the system should preserve:
	•	signed_at
	•	signed_by (if available)
	•	signer name / role (optional)
	•	signature image / asset URL
	•	operator / salesperson who collected it
	•	delivery mode

Optional Extra Metadata

Later phases may include:
	•	GPS
	•	device information
	•	IP address
	•	photo confirmation

These are optional and not required in v1.

⸻

Relationship to Shipment

Delivery confirmation belongs after shipment creation.

Correct flow:

Order
  -> Shipment
  -> Delivery execution
  -> Proof of Delivery / Signature
  -> Delivered status
``` id="x9h81l"

Rules:

1. Shipment may exist before delivery is complete.
2. Shipped status and delivered status are not the same.
3. Signature does not replace shipment; it confirms delivery completion.
4. Inventory consumption should be tied to shipment execution, not delayed until signature collection.

---

## Relationship to Inventory

Inventory remains the source of truth for stock.

This decision does not change:

- batch logic
- position logic
- movement logic

Instead:

- shipment execution consumes inventory
- delivery confirmation proves recipient-side completion

So the relationship is:

```text
Inventory
  -> Shipment execution
  -> Delivery proof
``` id="k5f4ae"

---

## Relationship to Invoice

Invoice flow is related but separate.

Rules:

1. Delivery confirmation does not automatically equal invoice issuance.
2. Invoice sending may occur:
   - before shipment
   - after shipment
   - after delivery
   depending on business rule
3. Invoice should be modeled as its own process.

This decision only states that delivery proof and invoice must not be collapsed into one object.

---

## UI Direction

Future UI should support:

### Shipment / Delivery Detail
- shipment status
- delivery mode
- planned / actual ship date
- delivered status
- proof of delivery block
- signature preview
- confirmation timeline

### Mobile Delivery View
For salesperson use:
- open shipment
- confirm delivery
- collect signature
- add delivery note / remark
- mark delivered

### Customer / Recipient View
Optional later:
- open delivery link
- confirm receipt
- sign digitally

---

## Non-Goals (Current Phase)

This decision does NOT yet require:

- full courier integration
- PDF delivery note generation
- OCR of signed receipts
- automatic invoice dispatch
- government e-invoice integration
- legal electronic signature compliance design

These may be added later.

---

## Legal / Compliance Direction

For alcohol-related deliveries, the system should assume:

- traceability is important
- recipient confirmation should be auditable
- digital records are preferable to paper-only records

Later legal review may define:
- retention period
- signature sufficiency
- compliance wording
- age / alcohol warning handling in delivery-related pages

---

## Product Direction

This decision supports the broader system goal:

> Move beverage merchant operations from paper-based execution to digital operational traceability.

Benefits include:

- better auditability
- lower manual friction
- easier cross-team collaboration
- stronger integration with inventory and future AI agents

---

## Future Follow-up

Recommended future decisions / specs:

- `shipment_scope_v1`
- `shipment_order_inventory_boundary_v1`
- `invoice_delivery_boundary_v1`
- `delivery_proof_data_model_v1`
- `mobile_signature_capture_flow_v1`

---

## Summary

The system must treat delivery as a digital operational flow.

Paper may remain as an optional output, but:

> digital shipment tracking and proof of delivery must become the primary system model.
:::
