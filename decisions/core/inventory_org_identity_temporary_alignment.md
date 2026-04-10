# Inventory Org Identity Temporary Alignment

## Status
Temporary alignment for staging compatibility.

## Decision

In A6-1, inventory-layer tables temporarily use:

- `org_id -> stores.id`

This is a staging-first compatibility choice, not the final semantic model.

## Why

Current staging-compatible chains are centered on:
- `stores`
- `locations`
- legacy inventory-related tables
- existing smoke-testable paths

Using `stores.id` allows the following chain to be introduced with minimal disruption:

`receipt -> line -> batch -> position -> movement`

## What This Does NOT Mean

This does NOT mean:
- `store = org`
- `stores.id` is the final canonical organization identity

## Expected Final Model

Long-term semantic direction should be:

- `merchant_orgs.org_id` = organization identity
- `stores.id` = branch / site / store identity

Inventory tables should eventually align as:

- `org_id -> merchant_orgs.org_id`
- `branch_id / store_id -> stores.id`

## Consequence

A6-1 can proceed without over-engineering or breaking staging compatibility.

A later migration will be required to normalize org identity at the inventory layer.

## Follow-up

Planned future work:
- A6-1.1 org identity correction proposal
- compatibility migration from `stores.id` to `merchant_orgs.org_id`
- explicit branch/store modeling
