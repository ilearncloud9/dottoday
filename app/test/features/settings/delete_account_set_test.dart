import 'dart:convert';
import 'dart:typed_data';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/picked_set_check.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/data/owners/account_export.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/features/settings/pages/delete_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/a11y.dart';
import '../../support/account_screen_fakes.dart';
import '../../support/export_fakes.dart';
import '../auth/auth_harness.dart';

// CR-160 B7c, Delete account with a set: "uncertain" until "Check my
// files…" confirms it; the deletion's question says it is a set; on the
// web the files are downloaded one by one, and only all of them counts as
// handed over. Copy approved 2026-11-11.

void main() {
  late FakeAccountActions actions;
  late FakeFileGateway files;
  setUp(() {
    actions = FakeAccountActions();
    files = FakeFileGateway();
  });

  Future<void> page(WidgetTester t, {bool browser = false}) =>
      pumpAccountScreen(
        t,
        const DeleteAccountView(owner: 'a', wide: false),
        actions: actions,
        browser: browser,
        overrides: [fileGatewayProvider.overrideWithValue(files)],
      );

  const uncertain =
      'Your data was handed over as 3 files. We can’t confirm you saved all '
      'of them. Check your files, or export again.';

  testWidgets('uncertain, then a check that finds every file: exported', (
    t,
  ) async {
    actions
      ..exportOutcome = OwnerExportOutcome.uncertain
      ..fileCount = 3
      ..checkAnswer = const PickedSetComplete();
    await page(t);
    await tapIn(t, find.text('Export my data first'));
    await t.pumpAndSettle();
    expect(find.text(uncertain), findsOneWidget);
    await expectA11yGuidelines(t);
    files.pickedFiles = [PickedFileStub.one()];
    await tapIn(t, find.text('Check my files…'));
    await t.pumpAndSettle();
    expect(actions.checked.single, hasLength(1));
    expect(
      find.text('Exported. You can delete your account now.'),
      findsOneWidget,
    );
    expect(find.text('Check my files…'), findsNothing);
  });

  testWidgets('a check missing files: said, still uncertain', (t) async {
    actions
      ..exportOutcome = OwnerExportOutcome.uncertain
      ..fileCount = 3
      ..checkAnswer = const PickedSetMissing(1);
    await page(t);
    await tapIn(t, find.text('Export my data first'));
    await t.pumpAndSettle();
    files.pickedFiles = [PickedFileStub.one()];
    await tapIn(t, find.text('Check my files…'));
    await t.pumpAndSettle();
    expect(
      find.text('1 of 3 files are missing. Pick the manifest and every part.'),
      findsOneWidget,
    );
    expect(find.text(uncertain), findsOneWidget);
  });

  testWidgets('deleting while uncertain asks the set question', (t) async {
    actions
      ..exportOutcome = OwnerExportOutcome.uncertain
      ..fileCount = 3
      ..deleteResult = const Err(ExportNotSavedFailure(retryable: true));
    await page(t);
    await tapIn(t, find.text('Export my data first'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'DELETE');
    await t.pump();
    await tapIn(t, find.widgetWithText(FilledButton, 'Delete account'));
    await t.pumpAndSettle();
    expect(
      find.text(
        'Delete without a confirmed copy? We can’t confirm all 3 files were '
        'saved. You may permanently lose data that hasn’t been saved '
        'elsewhere.',
      ),
      findsOneWidget,
    );
    expect(find.text('Try export again'), findsOneWidget);
  });

  testWidgets('web: one Download per file; all of them is handed over', (
    t,
  ) async {
    final store = MemoryPreparedFileStore();
    actions.setFiles = [
      for (final n in ['m.json', 'p1.json', 'p2.json'])
        await t.runAsync(
              () => store.put(n, utf8.encode('{}'), sha256Hex('{}')),
            ) ??
            (throw StateError('not prepared')),
    ];
    actions.fileCount = 3;
    await page(t, browser: true);
    await tapIn(t, find.text('Export my data first'));
    await t.pumpAndSettle();
    expect(find.text('Download 3 files'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tapIn(t, find.text('Download').first);
      await t.pumpAndSettle();
    }
    expect(files.downloads, ['m.json', 'p1.json', 'p2.json']);
    await t.tapAt(const Offset(5, 5));
    await t.pumpAndSettle();
    expect(find.text(uncertain), findsOneWidget);
  });

  testWidgets('web: closing the downloads early is cancelled', (t) async {
    final store = MemoryPreparedFileStore();
    actions.setFiles = [
      await t.runAsync(
            () => store.put('m.json', utf8.encode('{}'), sha256Hex('{}')),
          ) ??
          (throw StateError('not prepared')),
      await t.runAsync(
            () => store.put('p1.json', utf8.encode('{}'), sha256Hex('{}')),
          ) ??
          (throw StateError('not prepared')),
    ];
    await page(t, browser: true);
    await tapIn(t, find.text('Export my data first'));
    await t.pumpAndSettle();
    await tapIn(t, find.text('Download').first);
    await t.pumpAndSettle();
    await t.tapAt(const Offset(5, 5));
    await t.pumpAndSettle();
    expect(
      find.text(
        'The export was cancelled. We can’t confirm that you saved a copy.',
      ),
      findsOneWidget,
    );
  });
}

/// A picked file for the fakes (its bytes are never checked here).
abstract final class PickedFileStub {
  static PickedFile one() => PickedFile(
    'm.json',
    2,
    () async => Uint8List.fromList(utf8.encode('{}')),
  );
}
