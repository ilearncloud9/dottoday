import 'package:dottoday/core/ids/id_generator.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/writes/write_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'sweep_gateway.dart';

// CR-160 B7 gate (docs/cr-160-multipart-export.md): the set screens of
// B7a–c on a device. With a small part size, [seedSetSized]'s tasks make
// a set of several files; [SweepGateway] stands in for the native sheets.

/// One sweep step's tools: [shot] captures (and checks the accessibility
/// tree), [until] waits for a finder, [rest] lets animations finish.
typedef SweepTools = ({
  Future<void> Function(String name) shot,
  Future<void> Function(Finder finder) until,
  Future<void> Function() rest,
});

/// Writes [count] tasks with long notes for [owner], through the app's
/// write path, so its export is several parts.
Future<void> seedSetSized(
  ProviderContainer c,
  String owner, {
  int count = 40,
}) async {
  final profile = await c.read(localProfileProvider.future);
  final now = DateTime.now().toUtc();
  await c
      .read(writeUseCaseProvider)
      .apply(
        WriteBatch(
          userId: owner,
          occurrences: [
            for (var i = 0; i < count; i++)
              Occurrence(
                id: const UuidV7Generator().newId(),
                userId: owner,
                title: 'Sweep task ${i + 1}',
                notes: 'A long note so the export needs several files. ' * 30,
                tzId: profile.tzId,
                startUtc: now.add(Duration(days: 1 + i % 5, hours: i % 8)),
                durationMin: 30,
                createdAt: now,
                updatedAt: now,
              ),
          ],
        ),
      );
  await c.read(afterWriteEffectsProvider).idle;
}

/// Settings › Export › Everything (JSON) as a set: the sheet (on the web
/// its Download list first), then "Check my files…" missing one file and
/// complete. Returns where the set's files are in [SweepGateway.handed],
/// manifest first.
Future<List<int>> sweepExportSet(
  WidgetTester tester,
  SweepGateway files,
  SweepTools t, {
  required bool browser,
  bool shots = true,
}) async {
  GoRouter.of(
    tester.element(find.byType(Scaffold).first),
  ).go('/settings/export');
  await t.until(find.text('Everything (JSON)'));
  await t.rest();
  final mark = files.handed.length;
  await tester.tap(find.text('Everything (JSON)'));
  if (browser) {
    await t.until(find.textContaining('Download '));
    await t.rest();
    if (shots) await t.shot('cr160_export_downloads');
    await downloadEach(tester, t, close: false);
  }
  await t.until(find.text('Check my files…'));
  await t.rest();
  final names = [for (var i = mark; i < files.handed.length; i++) i];
  if (!shots) {
    await closeTop(tester, find.text('Check my files…'), t);
    return names;
  }
  if (!browser) await t.shot('cr160_export_set');
  await check(tester, files, names.sublist(1), t);
  await t.until(find.textContaining('files are missing'));
  await t.shot('cr160_export_check_missing');
  await check(tester, files, names, t);
  await t.until(find.textContaining('files are here and complete'));
  await t.shot('cr160_export_check_all');
  await closeTop(tester, find.text('Check my files…'), t);
  return names;
}

/// Settings › Import a backup… with set [a]: two files in ("Add the rest
/// of this backup"), a file of another set [b] refused, then the rest,
/// which leads to the Replace question (answered Cancel: nothing changes).
Future<void> sweepImportSet(
  WidgetTester tester,
  SweepGateway files,
  SweepTools t, {
  required List<int> a,
  required List<int> b,
}) async {
  GoRouter.of(
    tester.element(find.byType(Scaffold).first),
  ).go('/settings/export');
  await t.until(find.text('Import a backup…'));
  await tester.ensureVisible(find.text('Import a backup…'));
  await t.rest();
  files.queuePick(a.sublist(0, 2));
  await tester.tap(find.text('Import a backup…'));
  await t.until(find.text('Add the rest of this backup'));
  await t.rest();
  await t.shot('cr160_import_add_rest');
  files.queuePick([b[1]]);
  await tester.tap(find.text('Add files…'));
  await t.until(find.textContaining('isn’t part of this backup'));
  await t.rest();
  await t.shot('cr160_import_foreign');
  files.queuePick(a.sublist(2));
  await tester.tap(find.text('Add files…'));
  await t.until(find.text('Replace your tasks with this backup?'));
  await t.rest();
  await t.shot('cr160_import_confirm');
  await tester.tap(find.text('Cancel').last);
  await t.rest();
}

/// Settings › Account › Delete account with an account too large for one
/// file: the set handed over (the web's Download list first), the
/// uncertain status, the set's delete question (answered Cancel), then
/// "Check my files…" complete. Closed without deleting.
Future<void> sweepDeleteSet(
  WidgetTester tester,
  SweepGateway files,
  SweepTools t, {
  required bool browser,
}) async {
  GoRouter.of(
    tester.element(find.byType(Scaffold).first),
  ).go('/settings/account');
  final delete = find.widgetWithText(TextButton, 'Delete account');
  await t.until(delete);
  await tester.ensureVisible(delete);
  await t.rest();
  await tester.tap(delete);
  await t.until(find.text('Export my data first'));
  await t.rest();
  final mark = files.handed.length;
  await tester.tap(find.text('Export my data first'));
  if (browser) {
    await t.until(find.textContaining('Download '));
    await t.rest();
    await t.shot('cr160_delete_downloads');
    await downloadEach(tester, t, close: true);
  }
  final uncertain = find.textContaining('We can’t confirm you saved all');
  await t.until(uncertain);
  await t.rest();
  await t.shot('cr160_delete_uncertain');
  final names = [for (var i = mark; i < files.handed.length; i++) i];
  await tester.enterText(find.byType(TextField), 'DELETE');
  // A web build without `flutter drive` has no test text input: the word
  // goes through the field's controller, which the page listens to.
  final field = tester.widget<TextField>(find.byType(TextField));
  if (field.controller!.text != 'DELETE') field.controller!.text = 'DELETE';
  await t.rest();
  // Android's soft keyboard leaves the buttons just below the scrolled
  // view; a person scrolls to them.
  final confirm = find.widgetWithText(FilledButton, 'Delete account');
  await tester.ensureVisible(confirm);
  await t.rest();
  await tester.tap(confirm);
  await t.until(find.textContaining('Delete without a confirmed copy?'));
  await t.rest();
  await t.shot('cr160_delete_set_question');
  await tester.tap(find.text('Cancel').last);
  await t.rest();
  await check(tester, files, names, t);
  await t.until(find.text('Exported. You can delete your account now.'));
  await t.rest();
  await t.shot('cr160_delete_confirmed');
  await closeTop(tester, find.text('Export my data first'), t);
}

/// Picks the files at [names] back through "Check my files…".
Future<void> check(
  WidgetTester tester,
  SweepGateway files,
  List<int> names,
  SweepTools t,
) async {
  final row = find.text('Check my files…');
  await tester.ensureVisible(row);
  await t.rest();
  files.queuePick(names);
  await tester.tap(row);
  await t.rest();
}

/// Taps every Download in the web's list, one by one; [close]: D1's list
/// is its own sheet, closed after.
Future<void> downloadEach(
  WidgetTester tester,
  SweepTools t, {
  required bool close,
}) async {
  final button = find.widgetWithText(TextButton, 'Download');
  while (tester.any(button)) {
    await tester.ensureVisible(button.first);
    await tester.tap(button.first);
    await t.rest();
  }
  if (close) await closeTop(tester, find.text('Downloaded').first, t);
}

/// Pops the route that shows [inside] (a sheet, dialog or page).
Future<void> closeTop(WidgetTester tester, Finder inside, SweepTools t) async {
  Navigator.of(tester.element(inside.first)).pop();
  await t.rest();
}
