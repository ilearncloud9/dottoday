# ADR-0003: Web session storage and at-rest encryption

**Status**: accepted (v1) · **Date**: 2026-10-20

## Context
Browsers cannot offer Keychain-grade storage. Supabase JS/Dart default persists the session in localStorage, which XSS could read.

## Decision (v1)
Strict CSP (no inline scripts, 'self' only), PKCE, 1-hour access tokens with rotation, session persisted via Supabase's default storage but wrapped in a WebCrypto AES-GCM key held non-extractable in IndexedDB; local Drift WASM data blobs encrypted with the same key. Document the residual risk in the privacy page.

## Follow-up (v1.1)
Move refresh token to an HttpOnly cookie via an Edge Function proxy; then drop localStorage session entirely.
