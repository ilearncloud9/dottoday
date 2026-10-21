# ADR-0006: SQLCipher via the `sqlite3` 3.x build hook, not `sqlcipher_flutter_libs`

**Status**: accepted · **Date**: 2026-10-21 · **Supersedes**: `sqlcipher_flutter_libs` in the
"Local DB" row of CLAUDE.md §2 · **Decided by**: owner (M2.1 "decide first")

## Context
`sqlcipher_flutter_libs` is end-of-life (`0.7.0+eol`). `drift`/`drift_dev` ≥ 2.32 require `sqlite3`
3.x, which builds SQLite through Dart native-assets hooks instead of the `*_flutter_libs` plugins.
Staying on drift < 2.32 also pinned `analyzer` < 10 and `freezed` < 4 (M0.11), and `drift_flutter`
clashed with `sqlcipher_flutter_libs` on Apple targets.

## Decision
`drift` ^2.35 + `sqlite3` ^3 with `hooks.user_defines.sqlite3.source: sqlcipher` in
`app/pubspec.yaml`. The hook links SQLCipher (prebuilt per platform; OpenSSL on Android) on iOS,
Android and macOS. `sqlcipher_flutter_libs` is removed; no package is added. Encryption at rest is
unchanged: a 32-byte random key in Keychain/Keystore via `flutter_secure_storage`, applied with
`PRAGMA key` before any other statement (06 §4). Web is unchanged (ADR-0003: Drift WASM over OPFS,
data wrapped with a non-extractable WebCrypto key).

`test/data/db/sqlcipher_linked_test.dart` asserts `PRAGMA cipher_version` returns a value, because
plain SQLite ignores `PRAGMA key` and would silently store plaintext.

## Alternatives
- `source: sqlite3mc` (SQLite3MultipleCiphers) on native and web: would also encrypt the web WASM DB,
  but rewrites ADR-0003 and changes the cipher format the specs name. Revisit if web encryption is
  reworked (ADR-0003 follow-up).
- Stay on drift < 2.32 with the EOL plugin: no migration now, but an unmaintained native crypto
  dependency and frozen codegen toolchain.

## Consequences
+ One maintained source of SQLite/SQLCipher; codegen toolchain unblocked (analyzer 14, freezed 4).
+ No Flutter plugin registration for SQLite, so no Apple plugin clash.
− SQLCipher may lag upstream SQLite by a release; its license (BSD-style) applies — list it in
  the app's open-source notices (M8.6).
− A build-hook setting is easy to lose in a pubspec edit; the linked-cipher test guards it.
