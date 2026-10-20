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
