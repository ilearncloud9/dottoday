import 'package:dottoday/data/backup/backup_audit.dart';
import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/legacy_guest_quarantine.dart';
import 'package:dottoday/domain/backup/backup_recovery.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/guest_backup_world.dart';
import '../../support/owner_app.dart';

// The recovery classification and read-only audit (CR-160 I1), on
// synthetic fixtures: one stored backup per kind. These counts describe the
// fixtures only, not real devices.

const _a = '01928c3e-0000-7000-8000-00000000000a';

String _backupOf(String owner) => encodeExportJson(
  ExportBundle(
    exportedAt: ownerAppNow,
    profile: profileFixture().copyWith(id: owner),
    occurrences: [occurrenceFixture().copyWith(userId: owner)],
  ),
);

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  group('classifyBackupJson', () {
    test('each failure is named for what it is', () {
      expect(classifyBackupJson(_backupOf(_a), _a), BackupRecovery.restorable);
      expect(
        classifyBackupJson('{"pad":"${'a' * (maxImportBytes + 1)}"}', _a),
        BackupRecovery.oversized,
      );
      expect(classifyBackupJson('{"version":2}', _a), BackupRecovery.malformed);
      expect(classifyBackupJson('not json', _a), BackupRecovery.malformed);
      expect(
        classifyBackupJson(_backupOf(_a).replaceAll('indigo', 'zz-bad'), _a),
        BackupRecovery.malformed,
        reason: 'shape fine, a row the validators refuse',
      );
      expect(
        classifyBackupJson(_backupOf(userId), _a),
        BackupRecovery.wrongOwner,
      );
      expect(classifyBackupJson(_backupOf(_a), null), BackupRecovery.noOwner);
    });

    test('a row naming another owner is wrong-owner, not malformed', () {
      final mixed = _backupOf(
        _a,
      ).replaceFirst('"user_id": "$_a"', '"user_id": "$userId"');
      expect(classifyBackupJson(mixed, _a), BackupRecovery.wrongOwner);
    });
  });

  test('audit of synthetic fixtures: classes, references, candidates; '
      'nothing changed', () async {
    final w = GuestBackupWorld();
    addTearDown(w.dispose);
    final guest = await w.app.shown();
    Future<int> put(String? owner, String json) => w.store
        .into(w.store.backups)
        .insert(
          BackupsCompanion.insert(
            createdAt: ownerAppNow.millisecondsSinceEpoch,
            reason: 'daily',
            appSchemaVersion: 18,
            json: json,
            owner: Value(owner),
          ),
        );
    final legacyGuest = await put(guest, _backupOf(guest));
    final ownerless = await put(null, '{"version":1,"profile":{}}');
    final oversized = await put(
      guest,
      '{"pad":"${'a' * (maxImportBytes + 1)}"}',
    );
    final malformed = await put(guest, '{"version":2}');
    final wrong = await put(guest, _backupOf(userId));
    await recordLegacyGuestBoundary(w.db, w.store);
    final fresh = await w.backup(guest);
    final before = await w.store.select(w.store.backups).get();

    final audit = {for (final e in await auditBackups(w.db, w.store)) e.id: e};

    expect(audit[legacyGuest]!.recovery, BackupRecovery.restorable);
    expect(audit[legacyGuest]!.references, {BackupReference.legacyQuarantine});
    expect(audit[legacyGuest]!.restorableNow, isFalse);
    expect(audit[legacyGuest]!.deletionCandidate, isFalse);
    expect(audit[ownerless]!.recovery, BackupRecovery.noOwner);
    expect(audit[ownerless]!.ownerEstablished, isFalse);
    expect(audit[ownerless]!.references, isEmpty);
    expect(audit[ownerless]!.deletionCandidate, isTrue);
    expect(audit[oversized]!.recovery, BackupRecovery.oversized);
    expect(audit[oversized]!.b4Eligible, isTrue);
    expect(audit[oversized]!.deletionCandidate, isFalse);
    expect(audit[malformed]!.recovery, BackupRecovery.malformed);
    expect(audit[malformed]!.deletionCandidate, isTrue);
    expect(audit[wrong]!.recovery, BackupRecovery.wrongOwner);
    expect(audit[fresh]!.restorableNow, isTrue);
    expect(audit[fresh]!.references, {BackupReference.listed});

    final counts = <BackupRecovery, int>{};
    for (final e in audit.values) {
      counts[e.recovery] = (counts[e.recovery] ?? 0) + 1;
    }
    expect(counts, {
      BackupRecovery.restorable: 2,
      BackupRecovery.noOwner: 1,
      BackupRecovery.oversized: 1,
      BackupRecovery.malformed: 1,
      BackupRecovery.wrongOwner: 1,
    });
    final after = await w.store.select(w.store.backups).get();
    expect(
      [for (final r in after) '${r.id}:${r.json.length}:${r.owner}'],
      [for (final r in before) '${r.id}:${r.json.length}:${r.owner}'],
      reason: 'read-only',
    );
  });
}
