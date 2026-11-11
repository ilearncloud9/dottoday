import 'dart:convert';
import 'dart:io';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/logging/logger_provider.dart';
import 'package:dottoday/data/export/export_service.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/picked_set_check.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/owners/account_export_set.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../support/export_set_world.dart';
import '../../support/guest_backup_world.dart';
import '../../support/staged_import_world.dart';

// CR-160 Stage B6/B7c, D1 with a multipart export (docs/cr-160-multipart-
// export.md §10): only possession confirmed is `done`; a handoff without
// it is `uncertain` and leaves the deletion waiting like a cancelled
// export; a part not prepared is `failed`; only a row larger than any part
// is `tooLarge`; an account that fits one file takes the single-file rule.
// Imported calendar events are kept as tasks and every template is in it.

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late GuestBackupWorld w;
  setUp(() async => w = await exportWorld());
  tearDown(() => w.dispose());

  Future<OwnerSet?> export({
    DeliveryOutcome handed = DeliveryOutcome.delivered,
    bool throws = false,
    int targetBytes = 8000,
  }) => exportOwnerSet(
    w.db,
    stagedOwner,
    exports: DriftExportService(
      db: w.db,
      clock: w.app.container.read(clockProvider),
      logger: w.app.container.read(loggerProvider),
      partTarget: targetBytes,
    ),
    logger: w.app.container.read(loggerProvider),
    deliver: (files) async {
      if (throws) throw const FormatException('share failed');
      return handed;
    },
    appVersion: () async => '1.0.0',
  );

  /// A part's occurrences, read from its temporary file.
  List<Map<String, Object?>> occurrences(PreparedFile f) => [
    for (final o
        in (jsonDecode(File(f.path!).readAsStringSync()) as Map)['occurrences']
            as List)
      o as Map<String, Object?>,
  ];

  test('handed over: uncertain, with every row the device has', () async {
    final r = (await export())!;
    expect(r.outcome, OwnerExportOutcome.uncertain);
    final set = r.set!;
    addTearDown(set.discard);
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
    final event = [
      for (final p in set.parts) ...occurrences(p),
    ].singleWhere((o) => o['id'] == exportEvent);
    expect(event['source'], 'user');
    expect(event['calendar_link_id'], isNull);
  });

  test("the completeness check: the device's own counts pass, one row "
      'fewer in any table fails', () async {
    final set = (await export())!.set!;
    addTearDown(set.discard);
    final check = ownerSetComplete(w.db, stagedOwner);
    expect(await check(set.manifest.totals), isTrue);
    for (final t in partTables) {
      final fewer = {...set.manifest.totals, t: set.manifest.totals[t]! - 1};
      expect(await check(fewer), isFalse, reason: t);
    }
  });

  test('closed sheet: cancelled; a handoff that throws: failed; neither '
      'keeps a set', () async {
    final closed = (await export(handed: DeliveryOutcome.cancelled))!;
    expect((closed.outcome, closed.set), (OwnerExportOutcome.cancelled, null));
    final thrown = (await export(throws: true))!;
    expect((thrown.outcome, thrown.set), (OwnerExportOutcome.failed, null));
  });

  test('one row too large: tooLarge; fits one part: null, the single-file '
      'rule', () async {
    expect(
      (await export(targetBytes: 1500))!.outcome,
      OwnerExportOutcome.tooLarge,
    );
    expect(await export(targetBytes: 20000000), isNull);
  });

  test('confirmed only by exactly the files', () async {
    final set = (await export())!.set!;
    addTearDown(set.discard);
    List<PickedFile> picked(Iterable<PreparedFile> files) => [
      for (final f in files)
        PickedFile(f.name, f.size, () => File(f.path!).readAsBytes()),
    ];
    expect(
      await confirmOwnerSet(set, picked(set.files.skip(1))),
      isA<PickedSetMissing>(),
    );
    expect(
      await confirmOwnerSet(set, picked(set.files)),
      isA<PickedSetComplete>(),
    );
  });

  test('the deletion waits after an uncertain, cancelled or failed export, '
      'never after a confirmed one or none', () {
    for (final o in [
      OwnerExportOutcome.uncertain,
      OwnerExportOutcome.cancelled,
      OwnerExportOutcome.failed,
    ]) {
      expect(
        exportShortfall(asked: true, outcome: o),
        isA<ExportNotSavedFailure>().having((f) => f.retryable, 'retry', true),
        reason: '$o',
      );
    }
    for (final o in [OwnerExportOutcome.tooLarge, null]) {
      expect(
        exportShortfall(asked: true, outcome: o),
        isA<ExportNotSavedFailure>().having((f) => f.retryable, 'retry', false),
        reason: '$o (null: still running)',
      );
    }
    expect(
      exportShortfall(asked: true, outcome: OwnerExportOutcome.done),
      isNull,
    );
    expect(exportShortfall(asked: false, outcome: null), isNull);
  });
}
