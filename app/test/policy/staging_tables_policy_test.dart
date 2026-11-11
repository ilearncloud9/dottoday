import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

// CR-160 Stage B2 (docs/cr-160-multipart-export.md §6): the staging tables
// are never synced and never read in normal queries. Only the staging store
// reads or writes them; the schema declares them; account removal deletes
// them. No outbox entity, synced-table list or trigger names them.

final _staging = RegExp(
  r'import_staging|import_sessions|ImportStaging|ImportSessions|'
  r'importStaging|importSessions',
);

const _allowed = {
  'data/backup/staged_import_store.dart',
  'data/db/app_database.dart',
  'data/db/tables/import_staging_tables.dart',
  'data/sync/account_owners.dart',
};

void main() {
  test('only the staging store, the schema and account removal name the '
      'staging tables', () {
    expect({
      for (final MapEntry(key: path, value: src) in readLibSources(
        'lib',
      ).entries)
        if (_staging.hasMatch(src)) path,
    }, _allowed);
  });

  test('account removal only deletes them', () {
    final src = File('lib/data/sync/account_owners.dart').readAsStringSync();
    final uses = _staging.allMatches(src).length;
    expect(
      RegExp('DELETE FROM import_sessions WHERE owner = ?').allMatches(src),
      hasLength(uses),
    );
  });

  test('no outbox entity, trigger or synced table names them', () {
    for (final file in [
      'lib/data/db/tables/sync_tables.dart',
      'lib/data/db/search.drift',
      'lib/data/sync/server_columns.dart', // the synced tables
    ]) {
      final f = File(file);
      expect(f.existsSync(), isTrue, reason: file);
      expect(_staging.hasMatch(f.readAsStringSync()), isFalse, reason: file);
    }
  });
}
