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
  `PRAGMA hexkey`. It runs **in the page** over drift's IndexedDB file system, opened through
  sqlite3mc's encrypting VFS (`multipleciphers-indexeddb`). drift's worker/OPFS modes can't be
  used: they always open the plain default VFS, which rejects the key.
- One tab at a time: a Web Lock per database; a second tab gets `DatabaseUnavailable`
  (`openInAnotherTab`) instead of two in-memory copies overwriting each other in IndexedDB.
- The 32-byte raw key exists in IndexedDB only sealed (AES-GCM) under a **non-extractable**
  WebCrypto key stored alongside it (`dottoday-keyvault`). Script can use it but never export it;
  copying the storage to another browser profile doesn't carry a usable key.
- Rejected: drift's OPFS worker with a custom worker entrypoint (opens the unwrapped VFS);
  a custom encrypting VFS (re-implements sqlite3mc); unencrypted OPFS (06 §4).
- Cost: no OPFS speed-up and single-tab use on web. Revisit if drift exposes the VFS name.
- Verified in CI (`a11y-web` job): a probe build writes a task (and, since M9.1, the day
  snapshot's web copy), then Playwright scans every OPFS file, IndexedDB value, Cache Storage
  entry and `localStorage` value for its plaintext title, and checks a second tab is refused.
- Residual risk unchanged: XSS in the page can unwrap the key and read data.
