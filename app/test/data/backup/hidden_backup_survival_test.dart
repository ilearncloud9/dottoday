import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/backup/backup_audit.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/guest_backup_cutoff.dart';
import 'package:dottoday/data/backup/legacy_guest_quarantine.dart';
import 'package:dottoday/domain/backup/backup_recovery.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/guest_backup_world.dart';
import '../../support/owner_app.dart';

// CR-160 I1 final verification: guest backups that can't be read safely
// (over the 25 MB import limit, or not a backup at all), whether in the
// legacy quarantine or under a P1 cutoff, stay hidden, unchanged and
// stored through every privacy step: P2 on a confirmed deletion, P3 after
// 30 days, the legacy evidence scrub, retention. Never shown, never
// deleted, never restored.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _secret = '01928c3e-0000-7000-8000-000000000fc1';

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late GuestBackupWorld w;
  late String guest;
  setUp(() async {
    w = GuestBackupWorld();
    guest = await w.app.shown();
  });
  tearDown(() => w.dispose());

  Future<int> put(String json) => w.store
      .into(w.store.backups)
      .insert(
        BackupsCompanion.insert(
          createdAt: ownerAppNow.millisecondsSinceEpoch,
          reason: 'daily',
          appSchemaVersion: 20,
          json: json,
          owner: Value(guest),
        ),
      );

  final oversized = '{"pad":"${'a' * (maxImportBytes + 1)}"}';
  // The schema refuses text that is not JSON (CHECK json_valid), so an
  // unreadable backup is valid JSON that is not a backup.
  const malformed = '{"not":"a backup"}';

  test('oversized and unreadable guest backups, legacy and under a cutoff, '
      'stay hidden, unchanged and stored through P2, P3 and the legacy '
      'scrub', () async {
    final legacyBig = await put(oversized);
    final legacyBad = await put(malformed);
    await w.write(guest, [w.task(guest, _secret, 'Secret plan')]);
    await w.backup(guest); // the first fenced work: the boundary
    final p1Big = await put(oversized);
    final p1Bad = await put(malformed);
    await w.promote(_a);
    await w.app.owners.signOut();
    final junk = [legacyBig, legacyBad, p1Big, p1Bad];
    final before = {for (final id in junk) id: await w.json(id)};

    expect(
      (await scrubLegacyByEvidence(w.db, w.store)).unreadable,
      2,
      reason: 'the legacy ones are counted, not touched',
    );
    await w.app.owners.accountDeleted(_a); // P2
    w.clock.advance(const Duration(days: 31));
    await w.backups.runDailyIfDue(guest); // P3 and the legacy scrub

    final v = await guestBackupVisibility(w.db, guest);
    final listed = await w.listed();
    for (final id in junk) {
      expect(await w.json(id), before[id], reason: '$id unchanged');
      expect(v.hides(id), isTrue, reason: '$id hidden');
      expect(listed, isNot(contains(id)));
      expect(await w.backups.restore(guest, id), isA<Err<void, AppFailure>>());
    }
    final audit = {for (final e in await auditBackups(w.db, w.store)) e.id: e};
    expect(audit[legacyBig]!.recovery, BackupRecovery.oversized);
    expect(audit[p1Big]!.recovery, BackupRecovery.oversized);
    expect(audit[legacyBad]!.recovery, BackupRecovery.malformed);
    expect(audit[p1Bad]!.recovery, BackupRecovery.malformed);
    for (final id in junk) {
      expect(audit[id]!.restorableNow, isFalse);
    }
  });
}
