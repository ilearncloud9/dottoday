import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/staged_import_store.dart';
import 'package:dottoday/data/db/app_database.dart';
import 'package:dottoday/data/db/connection/cipher_setup.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/owner_app.dart';
import '../../support/staged_import_world.dart';

// CR-160 Stage B3 gate: a crash during the commit. The database files are
// copied, as a killed process leaves them on disk, from inside the commit
// transaction after several chunks were written; the copy, reopened, holds
// the owner's data exactly as before the import (SQLCipher, WAL, as the
// app opens it), and the next run's cleanup removes the leftover staging.
// The copy is taken in the same process: a real process kill is covered by
// SQLite's journal recovery, which reopening the copy exercises.
// Also: no after-write effect is scheduled inside the commit, and one is
// scheduled after it.

const _key = 'cd';

AppDatabase _open(File file) => AppDatabase(
  NativeDatabase(
    file,
    setup: (raw) => configureCipherConnection(raw, _key * 32),
  ),
);

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  test('a crash mid-commit leaves the owner\'s data as it was; the next run '
      'cleans up the staging', () async {
    final dir = await Directory.systemTemp.createTemp('dottoday-b3-crash');
    addTearDown(() => dir.delete(recursive: true));
    final live = File('${dir.path}/live/dottoday.db')
      ..parent.createSync(recursive: true);
    final crashed = Directory('${dir.path}/crashed')..createSync();
    final w = await stagedWorld(db: _open(live));
    addTearDown(w.dispose);
    final before = await stagedState(w);
    var chunks = 0;
    final r =
        await stagedImporter(
          w,
          afterChunk: () async {
            if (++chunks != 3) return;
            for (final suffix in ['', '-wal', '-shm']) {
              final f = File('${live.path}$suffix');
              if (f.existsSync()) {
                f.copySync('${crashed.path}/dottoday.db$suffix');
              }
            }
          },
        ).importText(
          stagedOwner,
          encodeExportJson(stagedFile()),
          safety: () async => const Ok(null),
        );
    expect(r, isA<Ok<void, AppFailure>>(), reason: 'the live run finished');
    expect(chunks, greaterThan(3));
    expect(await stagedState(w), isNot(before));

    final reopened = _open(File('${crashed.path}/dottoday.db'));
    addTearDown(reopened.close);
    expect(await stagedDbState(reopened), before);
    expect(
      await cleanUpStaleImports(reopened, runId: 'run-2', nowUtc: ownerAppNow),
      1,
    );
    expect(await reopened.select(reopened.importStaging).get(), isEmpty);
  });

  test(
    'no after-write effect runs inside the commit; one runs after',
    () async {
      final w = await stagedWorld();
      addTearDown(w.dispose);
      final effects = w.app.container.read(afterWriteEffectsProvider);
      await effects.idle;
      final idle = effects.idle;
      var chunks = 0;
      final r =
          await stagedImporter(
            w,
            afterChunk: () async {
              chunks++;
              expect(
                identical(effects.idle, idle),
                isTrue,
                reason: 'chunk $chunks',
              );
            },
          ).importText(
            stagedOwner,
            encodeExportJson(stagedFile()),
            safety: () async => const Ok(null),
          );
      expect(r, isA<Ok<void, AppFailure>>());
      expect(chunks, greaterThan(3));
      expect(identical(effects.idle, idle), isFalse, reason: 'scheduled after');
    },
  );
}
