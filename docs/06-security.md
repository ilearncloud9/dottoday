# 06 — Security & Privacy

A planner holds a person's whole life schedule. Treat titles, notes, locations and calendar data as
sensitive personal data.

## 1. Threat model (STRIDE-lite)

| Threat | Example | Mitigation |
|---|---|---|
| Unauthorised data access via API | user A reads user B's rows through PostgREST | RLS on every table, `user_id = auth.uid()` policies, no `security definer` views exposed; RLS tests in CI |
| Token theft on device | stolen phone, malware reading prefs | Supabase session stored in Keychain/Keystore via `flutter_secure_storage`; local DB SQLCipher-encrypted with a key from secure storage; biometric/App-lock optional |
| Token theft on web | XSS reads localStorage | Strict CSP (no inline scripts), Supabase session in memory + refresh via HttpOnly cookie through a thin Edge Function proxy (or `persistSession` with PKCE and short TTL if proxy not built in v1 — ADR-0003), `Trusted Types` where supported |
| Calendar OAuth secret leakage | client contains Google client secret | OAuth code flow completes in an Edge Function; refresh tokens in Supabase Vault; client never sees provider tokens |
| Injection | SQL/RRULE/markdown | parameterised queries only (Drift/PostgREST); RRULE parsed by library and re-serialised, never concatenated; notes rendered with a sanitising markdown-lite renderer, links `rel=noopener`, no raw HTML |
| Notification spoofing / data in payloads | payload shows notes on lock screen | notification body = title + time only; notes never in payload; "hide content on lock screen" setting |
| Sync tampering | malicious client sets another user's `user_id` | `sync_push` RPC overwrites `user_id` with `auth.uid()`; HLC bounded (reject > 5 min future) |
| Account takeover | magic link reuse | Supabase defaults: single-use links, 10-min expiry; rate limits; Sign in with Apple/Google via PKCE |
| Data loss | bug deletes rows | tombstones + 30-day trash, daily local backups, export; destructive endpoints require confirmation |
| Supply chain | compromised pub package | lockfile committed, `dart pub outdated --mode=null-safety` + `osv-scanner` in CI, deps justified in ADRs |
| Secrets in repo | `.env` committed | `.gitignore`, `gitleaks` pre-commit + CI, only `SUPABASE_URL` and anon key in client env |

## 2. Authentication & session
- Methods: email magic link (OTP), Sign in with Apple (required on iOS when offering social login), Google.
- PKCE flow on all platforms. Access token TTL 1 h, refresh rotation on. Sessions revocable from settings ("Sign out everywhere").
- Optional app lock: biometrics/passcode via `local_auth`; auto-lock after N minutes; blur in app switcher.

## 3. Authorisation (Supabase RLS)
- Every table: `enable row level security`, policies for select/insert/update/delete scoped to `auth.uid()`.
- `profiles.id` is `auth.users.id`; insert via trigger on signup.
- `calendar_accounts` tokens are in Vault; Edge Functions use the service role but filter by the invoking user's JWT.
- `sync_push` RPC is `security invoker`; validates payload shapes; caps batch size (500 rows).

## 4. Data at rest
- Device: SQLCipher (AES-256) with a 32-byte random key in Keychain/Keystore. Backups encrypted with the same key; export files are plaintext **by user action only**, with a warning.
- Web: Drift WASM over IndexedDB on `sqlite3mc.wasm` (one tab at a time); the raw DB key is stored in IndexedDB sealed by a non-extractable WebCrypto AES-GCM key (ADR-0003 amendment, M2.9). Accept that web at-rest protection is weaker (page script can unwrap it); document in privacy page.
- Server: Postgres encryption at rest (Supabase default); Vault for tokens; daily backups with PITR on paid tier.

## 5. Data in transit
TLS 1.2+ only; certificate pinning not used (Supabase rotates); HSTS on web.

## 6. Privacy
- No third-party analytics SDKs in v1. Crash reporting (Sentry) with `sendDefaultPii=false`, breadcrumbs scrubbed of titles/notes.
- Data minimisation: no location unless the user adds it to a task; no contacts; no ad IDs.
- GDPR: export (F7), delete account (Edge Function deletes all rows + auth user within 24 h, emails confirmation), privacy policy and data-processing page in-app. App Store privacy labels: "Data not linked to you" where accurate.
- Children: 13+ age gate in onboarding copy.

## 7. Input validation
- Every external input validated at the boundary: Quick Add text (length, control chars stripped), import JSON (schema + size ≤ 25 MB), calendar events (field lengths), deep links (allow-listed routes only), notification payloads (ID lookups only).
- Server CHECK constraints mirror client rules (see data model).

## 8. Platform hardening
- iOS/macOS: App Transport Security default, Keychain `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`, `NSFaceIDUsageDescription`, no `UIFileSharingEnabled`.
- Android: `android:allowBackup="false"` (we do our own backups), network security config (cleartext off), `FLAG_SECURE` when app lock is on, Play Integrity not required v1.
- Web: CSP `default-src 'self'; connect-src <supabase>; img-src 'self' data:; script-src 'self' 'wasm-unsafe-eval'`, `X-Frame-Options: DENY`, `Referrer-Policy: no-referrer`, service worker scope limited.
- Logging never includes task content; `Logger.redact()` enforced via lint rule (`avoid_print` + custom lint `no_pii_in_logs`).

### Web push (M5.3b)
Reminder text never reaches our server or the browser vendor's push service in the clear: the app
encrypts each push body in the browser to that browser's own subscription keys (RFC 8291,
`web/push_crypto.js`) and uploads only the ciphertext, the fire time and the ID-only plan
(`scheduled_pushes`, RLS: own rows on own subscriptions; ≤ 500 pending per subscription). The
`send-push` Edge Function holds the VAPID private key (function secret), accepts only the
service-role caller (cron), forwards ciphertext with `TTL: 3600`, drops subscriptions the push service
reports gone (404/410) and logs counts only. `push_subscriptions` stores the endpoint only; the
browser's `p256dh`/`auth` keys stay in the browser.

## 9. Security checklist (run at every `/ship-check`)
- [ ] New/changed tables have RLS enabled and policies tested (pgTAP tests pass).
- [ ] No secret, token, or private key in the diff (`gitleaks` clean).
- [ ] All new inputs validated client + server.
- [ ] No task content in logs, crash reports, or notification payloads.
- [ ] Session/keys only in secure storage; nothing sensitive in SharedPreferences/localStorage.
- [ ] Destructive actions are undoable or confirmed.
- [ ] Dependencies added are justified and scanned.
- [ ] Deep links and notification actions can't open another user's data (ID is looked up under current user).
- [ ] Web CSP unchanged or tightened; no inline scripts added.
- [ ] Account deletion and export still work end-to-end.
