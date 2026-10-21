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
