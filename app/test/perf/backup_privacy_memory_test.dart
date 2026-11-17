@Tags(['perf'])
library;

import 'dart:io';

import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/user_data_snapshot.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../support/guest_backup_world.dart';
import '../support/owner_app.dart';
import '../support/rss_sampler.dart';

// CR-160 I1 measurement, not a gate: duration and peak RSS above idle of
// the guest-backup privacy steps on backups near the 25 MB import limit.
// Host VM (flutter_tester) with in-memory SQLite, no SQLCipher: not a
// device figure. Skipped unless CR160_PERF is set:
//
//   CR160_PERF=1 flutter test test/perf/backup_privacy_memory_test.dart

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _rowsPerSession = 1150; // ~11.8 MB of JSON each
const _notes = 10000; // maxNotesLength

void main() {
  final enabled = Platform.environment['CR160_PERF'] != null;
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late GuestBackupWorld w;
  late String guest;

  Future<void> session(String tag) async {
    final pad = 'n' * _notes;
    for (var i = 0; i < _rowsPerSession; i += 150) {
      await w.write(guest, [
        for (var j = i; j < (i + 150).clamp(0, _rowsPerSession); j++)
          w
              .task(
                guest,
                '01928c3e-0000-7000-8$tag-${j.toString().padLeft(12, '0')}',
                'Row $j',
              )
              .copyWith(notes: pad),
      ]);
    }
  }

  /// Two legacy guest backups, three P1 ones (kept + moved work, each near
  /// 24 MB) and one oversized; the moved half then belongs to [_a].
  Future<String> world() async {
    w = GuestBackupWorld();
    guest = await w.app.shown();
    await session('001');
    await w.app.owners.signOut();
    await session('002');
    final json = encodeExportJson(
      (await w.db.transaction(() => readUserData(w.db, guest, ownerAppNow)))!,
    );
    for (var i = 0; i < 2; i++) {
      await w.store
          .into(w.store.backups)
          .insert(
            BackupsCompanion.insert(
              createdAt: ownerAppNow.millisecondsSinceEpoch,
              reason: 'daily',
              appSchemaVersion: 19,
              json: json,
              owner: Value(guest),
            ),
          );
    }
    for (var i = 0; i < 3; i++) {
      await w.backup(guest);
    }
    await w.store
        .into(w.store.backups)
        .insert(
          BackupsCompanion.insert(
            createdAt: ownerAppNow.millisecondsSinceEpoch,
            reason: 'daily',
            appSchemaVersion: 20,
            json: '{"pad":"${'a' * (maxImportBytes + 1)}"}',
            owner: Value(guest),
          ),
        );
    await w.promote(_a);
    await w.app.owners.signOut();
    final sizes = [
      for (final r in await w.store.select(w.store.backups).get())
        r.json.length,
    ];
    return '${sizes.length} backups, '
        '${[for (final s in sizes) mb(s)].join(' / ')} MB';
  }

  /// Each backup handled by policy after the step: the restorable ones
  /// hold none of the moved work (session 002); the legacy ones stay
  /// hidden; the oversized one stays hidden, stored and unchanged.
  Future<void> expectPolicy() async {
    final v = await guestBackupVisibility(w.db, guest);
    final listed = await w.listed();
    final rows = await (w.store.select(
      w.store.backups,
    )..where((b) => b.owner.equals(guest))).get();
    var checked = 0;
    for (final r in rows) {
      if (r.json.startsWith('{"pad"')) {
        expect(v.hides(r.id), isTrue, reason: 'oversized ${r.id}');
        expect(r.json.length, maxImportBytes + 11, reason: 'unchanged');
      } else {
        expect(r.json, isNot(contains('-8002-')), reason: 'moved ${r.id}');
        expect(listed.contains(r.id), !v.quarantines(r.id), reason: '${r.id}');
      }
      checked++;
    }
    expect(checked, greaterThanOrEqualTo(6));
  }

  void report(String step, String backups, RssMeasure m) {
    // ignore: avoid_print, the measurement is the output.
    print(
      'CR160_PERF $step: ${m.took.inMilliseconds} ms, '
      'peak ${mb(m.peak - m.idle)} MB above idle '
      '(idle ${mb(m.idle)} MB); $backups',
    );
  }

  test(
    'P2 + legacy scrub on a confirmed deletion',
    () async {
      final backups = await world();
      final m = await measureRss(() => w.app.owners.accountDeleted(_a));
      report('deletion cleanup (legacy + P2)', backups, m);
      await expectPolicy();
      await w.dispose();
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 10)),
  );

  test(
    'maintenance: P3 after 30 days and the daily legacy scrub',
    () async {
      final backups = await world();
      w.clock.advance(const Duration(days: 31));
      final m = await measureRss(() => w.backups.runDailyIfDue(guest));
      report('maintenance (P3 + legacy + daily backup)', backups, m);
      await expectPolicy();
      await w.dispose();
    },
    skip: !enabled,
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
