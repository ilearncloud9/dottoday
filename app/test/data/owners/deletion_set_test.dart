import 'dart:async';
import 'dart:io';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/picked_set_check.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/data/repositories/drift_occurrence_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/fixtures.dart';
import '../../support/deletion_world.dart';

// CR-160 B7c, D1 with an account too large for one file (parts of 4,000
// bytes here): the export is a set, `uncertain` until "Check my files"
// confirms exactly its files; until then the deletion waits as after a
// cancelled export, and "Delete without a saved copy" still lets it go.
// The set is D1's only in this D1 session and owner session.

const _account = '01928c3e-0000-7000-8000-00000000000a';
const _other = '01928c3e-0000-7000-8000-00000000000b';

AppFailure failure(Result<void, AppFailure> r) =>
    (r as Err<void, AppFailure>).failure;

/// [files] picked back from their temporary paths.
List<PickedFile> picked(Iterable<PreparedFile> files) => [
  for (final f in files)
    PickedFile(f.name, f.size, () => File(f.path!).readAsBytes()),
];

void main() {
  setUpAll(() async {
    tz_data.initializeTimeZones();
    await initializeDateFormatting();
  });

  late DeletionWorld w;
  setUp(() async {
    w = await DeletionWorld.boot(_account, partTarget: 4000);
    await DriftOccurrenceRepository(w.db).upsertAll([
      for (var i = 0; i < 6; i++)
        occurrenceFixture().copyWith(
          id: '01928c3e-0000-7000-9000-${i.toString().padLeft(12, '0')}',
          userId: _account,
          notes: 'n' * 2000,
        ),
    ]);
  });
  tearDown(() => w.dispose());

  List<PreparedFile> handed() => w.files.deliveredSets.single;

  test('handed over: uncertain, the deletion waits; a check missing a file '
      'changes nothing; exactly the files: done, and it goes', () async {
    expect(await w.actions.exportFirst(_account), OwnerExportOutcome.uncertain);
    expect(w.files.delivered, isEmpty, reason: 'a set, not one file');
    final files = handed();
    expect(files.length, greaterThan(2));
    expect(w.actions.exportFileCount(_account), files.length);
    expect(
      failure(await w.actions.deleteAccount()),
      isA<ExportNotSavedFailure>().having((f) => f.retryable, 'retry', true),
    );
    expect(
      await w.actions.checkExport(_account, picked(files.skip(1))),
      isA<PickedSetMissing>(),
    );
    expect(
      failure(await w.actions.deleteAccount()),
      isA<ExportNotSavedFailure>(),
    );
    expect(
      await w.actions.checkExport(_account, picked(files)),
      isA<PickedSetComplete>(),
    );
    expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
  });

  test('after uncertain, "Delete without a saved copy" lets it go', () async {
    await w.actions.exportFirst(_account);
    expect(w.actions.waiveExport(_account), isTrue);
    expect(await w.actions.deleteAccount(), isA<Ok<void, AppFailure>>());
  });

  test('closing D1 removes the files and the set; nothing to check', () async {
    await w.actions.exportFirst(_account);
    final files = handed();
    w.actions.endDeletion(_account);
    // Removed in the background (D1 closing never waits on the disk), one
    // file after another: wait for all of them, not just the first.
    bool anyLeft() => files.any((f) => File(f.path!).existsSync());
    for (var i = 0; i < 100 && anyLeft(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    for (final f in files) {
      expect(File(f.path!).existsSync(), isFalse, reason: f.name);
    }
    expect(w.actions.exportFileCount(_account), isNull);
  });

  test('A → B → A: a set checked afterwards never lets it go', () async {
    await w.actions.exportFirst(_account);
    final files = handed();
    await w.app.signIn(_other);
    await w.app.signIn(_account);
    await w.actions.checkExport(_account, picked(files));
    expect(
      failure(await w.actions.deleteAccount()),
      isA<ReviewChangedFailure>(),
    );
    expect(w.server.askedAt, isEmpty);
  });

  test('a check still reading when a new export starts never marks the '
      'new one done', () async {
    await w.actions.exportFirst(_account);
    final files = handed();
    final bytes = [for (final f in files) await File(f.path!).readAsBytes()];
    final open = Completer<void>();
    final slow = [
      for (final (i, f) in files.indexed)
        PickedFile(f.name, f.size, () async {
          await open.future;
          return bytes[i];
        }),
    ];
    final check = w.actions.checkExport(_account, slow);
    w.files.outcome = DeliveryOutcome.cancelled;
    expect(await w.actions.exportFirst(_account), OwnerExportOutcome.cancelled);
    open.complete();
    expect(await check, isA<PickedSetComplete>());
    expect(
      failure(await w.actions.deleteAccount()),
      isA<ExportNotSavedFailure>(),
      reason: 'the cancelled export stands',
    );
  });

  test('a new export removes the set before it, and its files', () async {
    await w.actions.exportFirst(_account);
    final old = handed();
    w.files.outcome = DeliveryOutcome.cancelled;
    expect(await w.actions.exportFirst(_account), OwnerExportOutcome.cancelled);
    expect(w.actions.exportFileCount(_account), isNull);
    for (final f in old) {
      expect(File(f.path!).existsSync(), isFalse, reason: f.name);
    }
    expect(await w.actions.checkExport(_account, picked(old)), isNull);
  });

  test('a closed sheet or the web closing its downloads early: cancelled, '
      'no set kept', () async {
    w.files.outcome = DeliveryOutcome.cancelled;
    expect(await w.actions.exportFirst(_account), OwnerExportOutcome.cancelled);
    expect(w.actions.exportFileCount(_account), isNull);
    final shared = w.files.deliveredSets.length;
    expect(
      await w.actions.exportFirst(
        _account,
        handOver: (files) async => DeliveryOutcome.cancelled,
      ),
      OwnerExportOutcome.cancelled,
    );
    expect(
      await w.actions.exportFirst(
        _account,
        handOver: (files) async => DeliveryOutcome.delivered,
      ),
      OwnerExportOutcome.uncertain,
    );
    expect(
      w.files.deliveredSets.length,
      shared,
      reason: 'handed over by the web, not shared',
    );
  });
}
