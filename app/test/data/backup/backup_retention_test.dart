import 'package:dottoday/data/backup/backup_database.dart';
import 'package:dottoday/data/backup/backup_retention.dart';
import 'package:dottoday/domain/backup/backup_restorability.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';

// Retention that keeps an owner's last restorable backup (CR-160 backup
// safety), on stored rows: restorable means the restore's own check passes,
// not merely "under 25 MB"; it is per owner; other owners are never read
// or touched; nothing beyond one pinned backup is kept.

const _a = '01928c3e-0000-7000-8000-00000000000a';
const _b = '01928c3e-0000-7000-8000-00000000000b';

String _restorable(String owner) => encodeExportJson(
  ExportBundle(
    exportedAt: DateTime.utc(2026, 11, 10),
    profile: profileFixture().copyWith(id: owner),
    occurrences: [occurrenceFixture().copyWith(userId: owner)],
  ),
);

/// Valid JSON, over the import limit.
final _oversized = '{"pad":"${'a' * (maxImportBytes + 1)}"}';

/// Under the limit and valid JSON, but not a backup a restore accepts.
const _invalid = '{"version":1,"exportedAt":0}';

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late BackupDatabase db;
  var at = 0;
  setUp(() {
    db = BackupDatabase(NativeDatabase.memory());
    at = 0;
  });
  tearDown(() => db.close());

  Future<int> put(String owner, String reason, String json) => db
      .into(db.backups)
      .insert(
        BackupsCompanion.insert(
          createdAt: ++at,
          reason: reason,
          appSchemaVersion: 20,
          json: json,
          owner: Value(owner),
        ),
      );

  Future<Set<int>> ids(String owner) async => {
    for (final b in await (db.select(
      db.backups,
    )..where((b) => b.owner.equals(owner))).get())
      b.id,
  };

  test('plain count retention while newer backups restore', () async {
    for (var i = 0; i < 9; i++) {
      await put(_a, 'daily', _restorable(_a));
    }
    await pruneKeepingRestorable(db, _a, 'daily', 7);
    expect(await ids(_a), hasLength(7));
  });

  test('repeated oversized pre-imports keep the last restorable one, and '
      'only that one', () async {
    await put(_a, 'preImport', _restorable(_a)); // oldest of all
    final last = await put(_a, 'preImport', _restorable(_a));
    for (var i = 0; i < 8; i++) {
      await put(_a, 'preImport', _oversized);
      await pruneKeepingRestorable(db, _a, 'preImport', 5);
    }
    final kept = await ids(_a);
    expect(kept, contains(last), reason: 'the newest restorable');
    expect(kept, hasLength(6), reason: '5 newest + the pinned one');
  });

  test('the pin looks across reasons: a restorable pre-restore backup '
      'counts', () async {
    final daily = await put(_a, 'daily', _restorable(_a));
    final preRestore = await put(_a, 'preRestore', _restorable(_a));
    for (var i = 0; i < 8; i++) {
      await put(_a, 'daily', _oversized);
      await pruneKeepingRestorable(db, _a, 'daily', 7);
    }
    final kept = await ids(_a);
    expect(kept, contains(preRestore));
    expect(kept, isNot(contains(daily)), reason: 'not the newest restorable');
  });

  test('under 25 MB is not restorable by itself: an invalid one is not '
      'pinned', () async {
    final good = await put(_a, 'daily', _restorable(_a));
    final bad = await put(_a, 'daily', _invalid);
    for (var i = 0; i < 7; i++) {
      await put(_a, 'daily', _oversized);
    }
    await pruneKeepingRestorable(db, _a, 'daily', 7);
    final kept = await ids(_a);
    expect(kept, contains(good));
    expect(kept, isNot(contains(bad)));
  });

  test("per owner: B's restorable backup never stands in for A's, and B's "
      "pruning never touches A's", () async {
    final aGood = await put(_a, 'daily', _restorable(_a));
    for (var i = 0; i < 7; i++) {
      await put(_a, 'daily', _oversized);
    }
    final aBefore = await ids(_a);
    for (var i = 0; i < 9; i++) {
      await put(_b, 'daily', _restorable(_b));
      await pruneKeepingRestorable(db, _b, 'daily', 7);
    }
    expect(await ids(_a), aBefore, reason: "B's pruning left A alone");
    await put(_a, 'daily', _oversized);
    await pruneKeepingRestorable(db, _a, 'daily', 7);
    expect(await ids(_a), contains(aGood));
    expect(await ids(_b), hasLength(7));
  });

  test("a backup holding another owner's profile is not A's restorable "
      'one', () async {
    final foreign = await put(_a, 'daily', _restorable(_b));
    for (var i = 0; i < 7; i++) {
      await put(_a, 'daily', _oversized);
    }
    await pruneKeepingRestorable(db, _a, 'daily', 7);
    expect(await ids(_a), isNot(contains(foreign)));
  });

  group('isRestorableBackup', () {
    final bundle = ExportBundle(
      exportedAt: DateTime.utc(2026, 11, 10),
      profile: profileFixture(),
      occurrences: [occurrenceFixture()],
    );
    final json = encodeExportJson(bundle);

    test('the owner, complete: yes', () {
      expect(isRestorableBackup(json, userId, matches: bundle), isTrue);
    });
    test('another owner: no', () {
      expect(isRestorableBackup(json, _a), isFalse);
    });
    test('over the limit, malformed or not a backup: no', () {
      expect(isRestorableBackup(_oversized, userId), isFalse);
      expect(isRestorableBackup('{"version":1', userId), isFalse);
      expect(isRestorableBackup(_invalid, userId), isFalse);
    });
    test('incomplete against the account it was taken of: no', () {
      final more = ExportBundle(
        exportedAt: bundle.exportedAt,
        profile: bundle.profile,
        occurrences: [
          occurrenceFixture(),
          occurrenceFixture().copyWith(
            id: '01928c3e-0000-7000-8000-00000000f001',
          ),
        ],
      );
      expect(isRestorableBackup(json, userId, matches: more), isFalse);
    });
  });
}
