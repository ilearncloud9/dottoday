# ADR-0003: Web session storage and at-rest encryption

**Status**: accepted (v1) · **Date**: 2026-10-20

## Context
Browsers cannot offer Keychain-grade storage. Supabase JS/Dart default persists the session in localStorage, which XSS could read.

## Decision (v1)
Strict CSP (no inline scripts, 'self' only), PKCE, 1-hour access tokens with rotation, session persisted via Supabase's default storage but wrapped in a WebCrypto AES-GCM key held non-extractable in IndexedDB; local Drift WASM data blobs encrypted with the same key. Document the residual risk in the privacy page.

## Follow-up (v1.1)
Move refresh token to an HttpOnly cookie via an Edge Function proxy; then drop localStorage session entirely.

## Amendment (2026-10-21, M2.9): how the Drift WASM data is encrypted
- The web database runs on `sqlite3mc.wasm` (SQLite3MultipleCiphers, default ChaCha20-Poly1305)
  from the same sqlite3.dart release as the native SQLCipher build (ADR-0006), keyed with
  `PRAGMA hexkey` on every connection — in the page and in our own drift worker
  (`app/web/drift_worker.dart`, compiled by `tool/web_db_assets.sh`), because the stock worker
  can't apply a key.
- The 32-byte raw key exists in IndexedDB only sealed (AES-GCM) under a **non-extractable**
  WebCrypto key stored alongside it (`dottoday-keyvault`). Script can use it but never export it;
  copying the storage to another browser profile doesn't carry a usable key.
- Rejected: a custom encrypting VFS (re-implements what sqlite3mc already does); wrapping each
  OPFS block in WebCrypto from Dart (async crypto under SQLite's sync VFS needs the same worker
  plumbing plus our own crypto).
- Verified in CI (`a11y-web` job): a probe build writes a task, then Playwright scans every OPFS
  file and IndexedDB value for its plaintext title.
- Residual risk unchanged: XSS in the page can unwrap the key and read data; native and web
  formats differ (SQLCipher vs sqlite3mc), which only matters for raw-file copying, never done.
