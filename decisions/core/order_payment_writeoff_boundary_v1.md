# Order Payment Write-off Boundary v1

## Status
Accepted

---

## Purpose

This document defines the boundary between:

- order domain
- payment domain
- settlement / write-off domain
- collection reminder workflows

Its purpose is to prevent the system from incorrectly inferring accounting facts from order events alone.

---

## Core Principle

> Order activity is not payment fact.  
> Payment fact is not write-off fact.  
> Collection action must be based on accounting truth.

---

## Domain Separation

### Order Domain
Represents:
- order creation
- confirmation
- fulfillment
- shipment completion

### Payment Domain
Represents:
- money received or attempted
- payment method
- payment confirmation
- payment failure

### Settlement / Write-off Domain
Represents:
- how payment is allocated to one or more orders
- whether an order is partially or fully settled
- whether receivable has been cleared

---

## Rule: Order Status Must Not Replace Payment Status

The following are forbidden assumptions:

- shipped = paid
- completed = paid
- old order = overdue receivable
- no recent update = unpaid
- approved task = payment confirmed

Order status may indicate business progress, but must not be treated as accounting fact.

---

## Allowed Order Activity Summary

Client page may eventually show from order domain:

- latest order date
- latest order status
- current month order quantity
- current month order amount
- order count
- recent order trend

These are valid business activity indicators.

---

## Forbidden Receivable Inference

The following must not be computed from order domain alone:

- unpaid amount
- outstanding balance
- overdue amount
- overdue days
- collection priority
- collection escalation level

These require accounting facts.

---

## Canonical Facts Required for Collection Status

Collection / receivable status must eventually be based on canonical facts such as:

- payment record
- payment confirmation status
- settlement allocation
- remaining balance
- due date
- write-off state

Without these facts, system must not claim that a client owes money.

---

## Payment Method Boundary

### Auto-confirmable Methods
May support automatic payment confirmation if provider callback exists:
- credit card
- LINE Pay
- other gateway-confirmed payment methods

### Human-confirmed Methods
Require manual verification:
- bank transfer
- manual remittance
- offline payment
- payment proof screenshot

---

## Write-off Principle

Write-off / settlement must be treated as its own fact layer.

Examples:
- one payment settles one order
- one payment settles multiple orders
- partial payment settles part of one order
- accountant manually confirms remittance and allocates payment

These cannot be safely inferred from order timeline alone.

---

## Bot Reminder Boundary

### Bot May
- send polite standard reminders
- notify about due or nearly due invoices
- remind customer to provide payment proof
- create follow-up task for salesperson
- remind internal staff to verify payment

### Bot Must Not
- accuse customer of non-payment without accounting fact
- claim overdue debt from order timing alone
- issue aggressive collection message
- replace human handling of disputed payment

---

## Human Escalation Boundary

Human must handle:
- disputed balances
- large outstanding amounts
- sensitive customers
- relationship-preserving collection
- accounting exceptions
- manual remittance verification

---

## UI Guidance

Client page may eventually contain separate sections:

### A. Order Activity
- order amount this month
- order quantity this month
- latest order
- order trend

### B. Payment / Receivable
- unpaid amount
- outstanding balance
- overdue days
- reminder status

### Rule
If payment/AR facts are unavailable, UI must:
- hide the collection section
- or show `—`
- or clearly mark `未建立帳務資料`

Never fabricate `0` as if it were verified.

---

## Future Canonical Domains

This boundary anticipates future domains such as:

- merchant payments
- payment allocations
- receivables summary
- collection tasks
- payment proof review

But those are not part of order domain itself.

---

## Anti-Patterns

Forbidden patterns include:

- using `order_status` as payment status
- using AI task state as payment fact
- inferring overdue from order age alone
- treating shipment completion as settlement
- allowing bot to collect payment based on workflow inference only

---

## Summary

Orders, payments, and write-off are separate layers.

The system must:

- use order facts for business activity
- use payment facts for payment status
- use settlement/write-off facts for receivable truth
- use bot only within verified accounting boundaries
:::
