import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

// B5 (docs/11 §0, docs/09 M9.1): every surface outside the app reads the
// day snapshot, so every code path that changes a task must redraw it. A
// path does that by going through the single write path (`WriteUseCase`,
// whose after-write effects write the snapshot) or by scheduling the
// effects itself. This scan finds every file that writes the occurrences
// table directly and makes each one say how the snapshot follows.

/// Direct writes of the occurrences table (DAO and repository definitions
/// are the write primitives themselves and are skipped).
final _writesOccurrences = RegExp(
  r'[oO]ccurrences\.upsertAll\b|(UPDATE|DELETE FROM|INSERT INTO) occurrences|'
  r'updates: \{[^}]*occurrences',
);

/// Files that write occurrences directly → how the snapshot follows.
const _known = {
  // Each commit ends in `_effects.schedule(userId)`.
  'data/calendar/calendar_importer.dart': 'schedule',
  'data/calendar/calendar_write_back.dart': 'schedule',
  // Applies pulled rows; `EngineSyncService` calls `onPulled`, wired to
  // `afterWriteEffects.schedule` in sync_providers.dart.
  'data/sync/synced_rows.dart': 'onPulled',
  // Removes rows already in Trash for 30 days: they left the snapshot when
  // they were trashed (through the write path).
  'data/trash/trash_purge.dart': 'none: rows already out of the snapshot',
};

void main() {
  final sources = readLibSources('lib');

  test('every direct writer of tasks is classified', () {
    final writers = {
      for (final MapEntry(key: path, value: src) in sources.entries)
        if (!path.startsWith('data/daos/') &&
            !path.startsWith('data/repositories/') &&
            _writesOccurrences.hasMatch(src))
          path,
    };
    expect(
      writers,
      _known.keys.toSet(),
      reason:
          'A new direct write of occurrences: route it through WriteUseCase '
          'or schedule AfterWriteEffects, then classify it here.',
    );
  });

  test('the classified writers do what they say', () {
    for (final MapEntry(key: path, value: how) in _known.entries) {
      final src = sources[path]!;
      switch (how) {
        case 'schedule':
          expect(src, contains('_effects.schedule('), reason: path);
        case 'onPulled':
          expect(
            sources['data/sync/sync_providers.dart'],
            contains('onPulled: (id) => ref.read(afterWriteEffectsProvider)'),
          );
      }
    }
    expect(
      sources['data/writes/drift_write_use_case.dart'],
      contains('_effects.schedule('),
    );
  });

  test('the effects write the day snapshot', () {
    expect(
      sources['data/writes/after_write_effects.dart'],
      contains('await _snapshot.write(userId)'),
    );
    expect(
      sources['data/refresh/daily_refresh.dart'],
      contains('await _widgets.write(userId)'),
    );
  });
}
