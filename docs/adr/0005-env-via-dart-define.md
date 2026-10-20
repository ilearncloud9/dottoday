# ADR-0005: Client config via `--dart-define-from-file`, not a bundled `.env`

**Status**: accepted · **Date**: 2026-10-20 · **Supersedes**: `flutter_dotenv` row in CLAUDE.md §2

## Context
M0.3 loaded `app/.env` with `flutter_dotenv`, which requires bundling `.env` as an asset. M0.12
requires release builds not to ship that file. Flutter assets cannot vary by build mode, and
per-flavor assets would need native flavors on every platform (M9-sized work).

## Decision
All builds compile config in with `--dart-define-from-file`: `app/.env` for debug
(`flutter run --dart-define-from-file=.env`), `app/.env.prod` for release
(`flutter build <target> --dart-define-from-file=.env.prod`). `Env.fromEnvironment()` reads
`String.fromEnvironment` and keeps the M0.3 validation (fail fast, https-only, service-role key
rejected). `flutter_dotenv` and the `.env` asset are removed. A missing define fails at startup with
an `EnvConfigError` naming the exact command.

## Alternatives
Per-flavor assets (needs native flavors now), bundling but ignoring `.env` in release (still ships
the file), `--dart-define` per key (error-prone, long commands).

## Consequences
+ No config file in any bundle; one mechanism for every mode; CI needs no `.env` to test or build.
− Values are compile-time constants: changing `.env` needs a full restart, not hot reload.
− Values are still embedded in the binary/JS, so only public values are allowed (unchanged, 06 §1).
