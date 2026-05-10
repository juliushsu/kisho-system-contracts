# 2026-05-10 Readdy VER289 Frontend Alignment

## Context

Readdy delivered `皇上吉祥-VER289` as a frontend package with Supabase service usage and one Edge Function.

The package includes a `.env` file. Values were not copied into this public contract repository.

## Decision

Add `contracts/readdy_ver289_frontend_alignment_v1.md` as the public coordination contract for Codex / Readdy / CTO.

## Publicly Documented

- route surface
- service-layer boundaries
- table/view/RPC/Edge Function names
- role and org-scope rules
- known transitional write paths
- open backend reconciliation items

## Intentionally Excluded

- `.env` values
- Supabase project URL values
- anon key values
- service role key values
- JWTs, tokens, passwords, or private keys

## Follow-Up

- clean stale shipment comments in frontend types
- reconcile import review RPC naming
- replace order direct writes with RPCs
- confirm storage policy for storefront assets
