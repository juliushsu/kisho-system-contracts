Client Summary and Collection Boundary v1

Status

Accepted

⸻

Purpose

This document defines the boundary for merchant-side client management, client summary, and collection reminder workflows.

Its purpose is to ensure that:
	•	client management is not limited to basic contact records
	•	ordering activity and collection status are clearly separated
	•	AI reminder flows remain safe and commercially appropriate
	•	bot reminders do not overstep human relationship management

⸻

Core Principle

Client summary may show business activity.
Collection status must be based on accounting facts.
Bot may remind.
Human decides escalation.

⸻

1. Client Management Scope

Merchant-side client management should eventually include three layers:
	1.	Client identity / contact layer
	2.	Client ordering activity layer
	3.	Client collection / receivable layer

These layers must not be confused.

⸻

2. Allowed Client Summary (Order Activity)

The client page may show, when canonical order read model is available:
	•	latest order status
	•	latest order date
	•	current month order quantity
	•	current month order amount
	•	order count
	•	recent order trend

These belong to the ordering activity layer.

⸻

3. Receivable / Collection Boundary

The following must NOT be inferred only from order status:
	•	outstanding balance
	•	unpaid amount
	•	overdue amount
	•	overdue days
	•	collection priority

These values require proper accounting facts, such as:
	•	invoice issued
	•	payment received
	•	remaining receivable
	•	due date

Rule

Orders may support demand / activity analysis.
Receivable status must come from invoice / payment / AR facts.

⸻

4. Bot vs Human Collection Roles

Bot May
	•	send polite reminder messages
	•	remind about due dates
	•	remind about missing payment confirmation
	•	prompt user to review payment status
	•	generate follow-up task for sales owner

Bot Must Not
	•	aggressively pressure customer
	•	negotiate disputed balances
	•	decide collection escalation level by itself
	•	claim legal / financial consequences
	•	send collection notices when accounting facts are uncertain

Human Must Handle
	•	disputed payments
	•	large overdue balances
	•	sensitive customers
	•	relationship-preserving negotiation
	•	escalation beyond standard reminder flow

⸻

5. Reminder Levels

Level 1 — Soft Reminder

Used when:
	•	payment due soon
	•	minor overdue
	•	no dispute signal

Allowed for bot.

Level 2 — Attention Required

Used when:
	•	overdue beyond threshold
	•	repeated unpaid reminder
	•	customer marked as important / relationship-sensitive

Bot may create task, but human should review.

Level 3 — Human Escalation

Used when:
	•	large balance
	•	long overdue
	•	dispute / abnormality exists
	•	repeated ignored reminders

Must be handled by human owner.

⸻

6. AI Reminder Rule

AI may:
	•	detect overdue risk
	•	create collection reminder task
	•	draft LINE reminder text
	•	summarize customer payment history
	•	suggest next follow-up timing

AI must not:
	•	assume unpaid status without accounting fact
	•	auto-send high-risk collection messages
	•	expose internal credit / risk scoring to customer
	•	replace human judgment in escalation

⸻

7. Data Boundary Rule

Ordering Activity Layer

May use:
	•	canonical merchant orders read model

Collection Layer

Must use:
	•	invoice / payment / AR canonical facts

Forbidden

Do not compute collection state from:
	•	order status only
	•	shipment status only
	•	workflow inference only

⸻

8. UI Guidance

The client page may be split into:

A. Client Profile
	•	contact
	•	type
	•	status
	•	owner

B. Order Activity
	•	current month quantity
	•	current month amount
	•	latest order
	•	recent trend

C. Collection Status
	•	outstanding balance
	•	overdue days
	•	reminder status
	•	escalation owner

If collection facts are unavailable, UI must not fabricate values.

Use:
	•	—
	•	未建立帳務資料
	•	or hide the section

Do not show fake 0.

⸻

9. Task Integration

Collection reminders should integrate with ai_tasks as collaboration tasks.

Possible future task types:
	•	client_payment_reminder
	•	client_overdue_followup
	•	client_collection_review

These task states remain collaboration-only and must not replace accounting facts.

⸻

10. Future Extension Rule

This boundary supports future features such as:
	•	AI LINE bot reminder
	•	salesperson handoff
	•	aging summary
	•	collection dashboard
	•	customer risk flagging

But only after canonical AR / invoice / payment read model is established.

⸻

Summary

Client management must evolve beyond contact records, but must remain structurally correct:
	•	order activity comes from order facts
	•	collection status comes from AR / invoice / payment facts
	•	bot handles standard reminders
	•	humans handle relationship-sensitive escalation
