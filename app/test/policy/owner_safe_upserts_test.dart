import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

// CR-160 Finding X: an upsert by id rewrites the row's owner, so a row of
// another account on this device could change hands. Every upsert of a
// user's rows goes through a path that first proves each id is the
// writer's own: the write path (`checkNoForeignRows` in `writeRows`), the
// sync pull (`checkPulledRow`), or a writer that only ever upserts rows it
// read back for the same owner. A new caller (a staged import, say) must
// be classified here, which makes it say which guard it relies on.

final _upserts = RegExp(r'\.upsertAll\(|\.upsert\(');

/// Files outside the DAOs and repositories that upsert → their guard.
const _known = {
  // The write path: `checkNoForeignRows` before `writer.upsertAll`.
  'data/writes/row_writer.dart': 'checkNoForeignRows',
  // The writers' `upsertAll` closures, only ever called by `writeRows`.
  'data/writes/entity_writers.dart': 'writeRows',
  // The sync pull: `SyncEngine._apply` runs `checkPulledRow` first.
  'data/sync/synced_rows.dart': 'checkPulledRow',
  // Device-only calendar rows: new ids from the importer's generator, or
  // the same owner's rows found through its own links.
  'data/calendar/calendar_importer.dart': 'own rows',
  'data/calendar/calendar_write_back.dart': 'own rows',
  // calendar_accounts rows found by (owner, provider, external id).
  'data/calendar/drift_calendar_source_repository.dart': 'own rows',
  // A server table under RLS, not a local row.
  'data/notifications/push/supabase_push_store.dart': 'server',
};

void main() {
  final sources = readLibSources('lib');

  test('every upsert of user rows is classified by its ownership guard', () {
    final callers = {
      for (final MapEntry(key: path, value: src) in sources.entries)
        if (!path.startsWith('data/daos/') &&
            !path.startsWith('data/repositories/') &&
            _upserts.hasMatch(src))
          path,
    };
    expect(
      callers,
      _known.keys.toSet(),
      reason:
          'A new upsert of rows: go through WriteUseCase (checkNoForeignRows) '
          'or prove the ids are the owner\'s own, then classify it here.',
    );
  });

  test('the guards named are where they say', () {
    expect(
      sources['data/writes/row_writer.dart'],
      matches(
        RegExp(r'checkNoForeignRows\([\s\S]*?\);\s*await writer\.upsertAll'),
      ),
    );
    expect(
      sources['data/sync/sync_engine.dart'],
      matches(RegExp(r'checkPulledRow\([\s\S]*?_rows\.put')),
    );
  });
}
