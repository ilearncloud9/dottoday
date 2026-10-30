import 'package:drift/drift.dart';

/// Local-only sync bookkeeping on every table pushed via `sync_push`
/// (docs/04 §4).
///
/// [dirty] marks rows with local changes not yet acknowledged by
/// `sync_push`; [version] counts local writes so the sync engine can detect
/// a row edited again while its push was in flight.
mixin SyncColumns on Table {
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(0))();
}

/// `created_at`/`updated_at` as UTC epoch ms (docs/05 intro).
mixin TimestampColumns on Table {
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

/// The shape of a stored sound id (docs/12 §3): 1–64 of `[a-z0-9._]`, so
/// `none`, `system` and every catalogue id fit and a picker bug can't
/// store free text. Unknown ids are allowed (a newer device's catalogue);
/// they resolve to a default on read. Mirrors 0009_sound_id.sql.
const soundIdCheck = CustomExpression<bool>(
  'sound_id IS NULL OR (length(sound_id) BETWEEN 1 AND 64 '
  "AND sound_id NOT GLOB '*[^a-z0-9._]*')",
);
