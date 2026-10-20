# Changelog

All notable changes to this project will be documented in this file (Keep a Changelog, SemVer).

## [Unreleased]

### Added
- Project kit: agent instructions, specs, schema, implementation plan.
- M0.1: Flutter project scaffold (iOS, Android, macOS, Web) with blank shell app, smoke test, Inter font, placeholder assets and committed `pubspec.lock`; `intl` bumped to ^0.20.3 and `analyzer` pinned <7.4 so codegen compiles.
- M0.2: Feature-first folder layout (`core`, `data`, `domain`, `features/*`, `shared`, `integration_test`) with boundary READMEs.
- M0.3: `core/env` — `Env` loaded from `app/.env` in `bootstrap()`, provided via `envProvider`; fails fast on missing/invalid `SUPABASE_URL`/`SUPABASE_ANON_KEY` and rejects service-role keys.
- M0.4: `core/theme` — semantic colour, type (Inter), spacing, radii and motion tokens from 03 §1 via `AppTheme.of(context)`; zero-duration motion under reduced motion; light/dark goldens. Removed unused `google_fonts`.
- M0.5: `core/router` — go_router with the 8 routes (5-branch shell + `/day/:date`, `/month`, `/task/:id`); every location passes an allow-list guard (real dates, UUID v7 IDs, no query/fragment/foreign scheme) and falls back to `/today`. Plan: add M0.13, M5.0, M4.2 ownership note.
- M0.6: `core/l10n` — gen-l10n (en source, `nullable-getter: false`), `context.l10n`, localised app title; policy tests forbidding UI string literals (all of `features/**` and `shared/**`) and cross-layer imports (feature→feature, domain→Flutter, shared/core→features).
- M0.7: `core/clock` (`Clock`, `SystemClock`, test `FakeClock`), PII-safe structured `Logger` (event keys only, typed fields, `LogId`/`Logger.redact`, errors by type) with `no_pii_in_logs` policy test, sealed `AppFailure` (enum-only fields) with localised messages, and hand-rolled `Result<T, F extends AppFailure>`.
- M0.8: GitHub Actions — `app` (codegen freshness, format, analyze, tests; goldens on macOS with 0.1 % tolerance), `supabase` (pgTAP RLS), `security` (gitleaks, osv-scanner); all actions SHA-pinned.
