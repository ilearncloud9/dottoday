import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/owners/account_export_set.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/export_set_world.dart';
import '../../support/guest_backup_world.dart';
import '../../support/owner_app.dart';
import '../../support/staged_import_world.dart';

// CR-160 Stage B6, D1 with a multipart export (docs/cr-160-multipart-
// export.md §10): only possession confirmed is `done`; a handoff without
// it is `uncertain` and leaves the deletion refused like a cancelled
// export; a part not prepared is `failed`; only a row larger than any part
// is `tooLarge`. Imported calendar events are kept as tasks and every
// template is in it: nothing left out.

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late GuestBackupWorld w;
  setUp(() async => w = await exportWorld());
  tearDown(() => w.dispose());

  Future<OwnerSet> export({
    DeliveryOutcome handed = DeliveryOutcome.delivered,
    bool throws = false,
    int targetBytes = 8000,
  }) => exportOwnerSet(
    w.db,
    stagedOwner,
    store: MemoryPreparedFileStore(),
    logger: w.app.container.read(loggerProvider),
    deliver: (files) async {
      if (throws) throw const FormatException('share failed');
      return handed;
    },
    nowUtc: ownerAppNow,
    exportId: setExportId,
    appVersion: '1.0.0',
    schemaVersion: 21,
    date: '2026-11-11',
    targetBytes: targetBytes,
  );

  test('handed over: uncertain, with every row the device has', () async {
    final r = await export();
    expect(r.outcome, OwnerSetOutcome.uncertain);
    final set = r.set!;
    expect(set.manifest.purpose, ExportPurpose.accountDeletion);
    final local = await localOwnerCounts(w.db, stagedOwner);
    expect(set.manifest.totals, {
      'series': local.series,
      'occurrences': local.tasks,
      'subtasks': local.steps,
      'routines': local.routines,
      'calendarSeries': local.calendarSeries,
    });
    expect(local.calendarSeries, 1);
    // The imported event is an ordinary task in it, its step kept.
    final rows = [
      for (final p in set.parts)
        for (final o
            in (jsonDecode(preparedText(p)) as Map)['occurrences'] as List)
          o as Map<String, Object?>,
    ];
    final event = rows.singleWhere((o) => o['id'] == exportEvent);
    expect(event['source'], 'user');
    expect(event['calendar_link_id'], isNull);
  });

  test("the completeness check: the device's own counts pass, one row "
      'fewer in any table fails', () async {
    final set = (await export()).set!;
    final check = ownerSetComplete(w.db, stagedOwner);
    expect(await check(set.manifest.totals), isTrue);
    for (final t in partTables) {
      final fewer = {...set.manifest.totals, t: set.manifest.totals[t]! - 1};
      expect(await check(fewer), isFalse, reason: t);
    }
  });

  test('closed sheet: cancelled; a handoff that throws: failed', () async {
    expect(
      (await export(handed: DeliveryOutcome.cancelled)).outcome,
      OwnerSetOutcome.cancelled,
    );
    expect((await export(throws: true)).outcome, OwnerSetOutcome.failed);
  });

  test('one row too large: tooLarge; fits one part: the single-file '
      'rule', () async {
    expect((await export(targetBytes: 1500)).outcome, OwnerSetOutcome.tooLarge);
    expect(
      (await export(targetBytes: 20000000)).outcome,
      OwnerSetOutcome.singleFile,
    );
  });

  test('confirmed only by exactly the files: then done', () async {
    final set = (await export()).set!;
    final manifest = preparedText(set.manifestFile);
    final parts = [for (final p in set.parts) preparedText(p)];
    expect(
      confirmOwnerSet(set, manifest, parts.skip(1)),
      OwnerSetOutcome.uncertain,
    );
    expect(confirmOwnerSet(set, manifest, parts), OwnerSetOutcome.done);
  });

  test('the deletion waits after an uncertain, cancelled or failed set, '
      'never after a confirmed one', () {
    for (final o in [
      OwnerSetOutcome.uncertain,
      OwnerSetOutcome.cancelled,
      OwnerSetOutcome.failed,
    ]) {
      expect(
        setShortfall(o),
        isA<ExportNotSavedFailure>().having((f) => f.retryable, 'retry', true),
        reason: '$o',
      );
    }
    expect(
      setShortfall(OwnerSetOutcome.tooLarge),
      isA<ExportNotSavedFailure>().having((f) => f.retryable, 'retry', false),
    );
    expect(setShortfall(OwnerSetOutcome.done), isNull);
    expect(setShortfall(null), isNull, reason: 'no export asked for');
  });
}
