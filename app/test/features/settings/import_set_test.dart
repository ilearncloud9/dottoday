import 'dart:convert';
import 'dart:typed_data';

import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/export/export_fixtures.dart';
import '../../support/a11y.dart';
import '../../support/export_fakes.dart';
import 'settings_harness.dart';

// CR-160 B7b: Settings › Export › Import a backup… takes a set. Picked
// whole, it goes straight to today's confirmation (the set's date and live
// tasks); picked in part, "Add the rest of this backup" gathers the rest;
// another backup's file is refused there; closing it imports nothing.
// Copy approved 2026-11-11.

MultipartSplit _split(String id) =>
    splitExport(
          hostileBundle(),
          exportId: id,
          appVersion: '1',
          schemaVersion: 21,
          purpose: ExportPurpose.export,
          date: '2026-11-11',
          targetBytes: 2048,
        )
        as MultipartSplit;

List<PickedFile> _picked(Iterable<ExportFile> files) => [
  for (final f in files)
    PickedFile(
      f.name,
      utf8.encode(f.content).length,
      () async => Uint8List.fromList(utf8.encode(f.content)),
    ),
];

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  final set = _split('01928c3e-0000-7000-8000-0000000000d1');
  final n = set.files.length;
  late FakeFileGateway files;
  late FakeBackupService backups;
  setUp(() {
    files = FakeFileGateway();
    backups = FakeBackupService();
  });

  Future<void> pump(WidgetTester tester) => pumpSettings(
    tester,
    location: '/settings/export',
    files: files,
    backups: backups,
  );

  List<String> parts() => [for (final f in set.files.skip(1)) f.content];

  testWidgets('a whole set: today\'s confirmation, then the set imported in '
      'order', (tester) async {
    await pump(tester);
    files.pickedFiles = _picked(set.files.reversed);
    await _tap(tester, 'Import a backup…');
    expect(find.text('Replace your tasks with this backup?'), findsOneWidget);
    expect(find.textContaining('has 3 tasks'), findsOneWidget);
    await _tap(tester, 'Replace');
    expect(backups.importedSets.single, [set.files.first.content, ...parts()]);
    expect(backups.imported, isEmpty, reason: 'not a single file');
  });

  testWidgets('part of a set: Add the rest gathers it; another backup\'s '
      'file is refused there', (tester) async {
    await pump(tester);
    files.pickedFiles = _picked(set.files.take(2));
    await _tap(tester, 'Import a backup…');
    expect(find.text('Add the rest of this backup'), findsOneWidget);
    expect(find.text('2 of $n files added.'), findsOneWidget);
    await expectA11yGuidelines(tester);

    files.pickedFiles = _picked([
      _split('01928c3e-0000-7000-8000-0000000000d2').files.last,
    ]);
    await _tap(tester, 'Add files…');
    expect(
      find.text('This file isn’t part of this backup. Nothing was changed.'),
      findsOneWidget,
    );
    files.pickedFiles = _picked(set.files.skip(2));
    await _tap(tester, 'Add files…');
    expect(find.text('Replace your tasks with this backup?'), findsOneWidget);
    await _tap(tester, 'Replace');
    expect(backups.importedSets.single.skip(1), parts());
  });

  testWidgets('closing Add the rest imports nothing', (tester) async {
    await pump(tester);
    files.pickedFiles = _picked(set.files.take(1));
    await _tap(tester, 'Import a backup…');
    expect(find.text('1 of $n files added.'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Add the rest of this backup'), findsNothing);
    expect(backups.importedSets, isEmpty);
  });

  testWidgets('another backup\'s file in the first pick: refused, nothing '
      'asked', (tester) async {
    await pump(tester);
    files.pickedFiles = _picked([
      ...set.files.take(1),
      _split('01928c3e-0000-7000-8000-0000000000d3').files.last,
    ]);
    await _tap(tester, 'Import a backup…');
    expect(
      find.text('This file isn’t part of this backup. Nothing was changed.'),
      findsOneWidget,
    );
    expect(find.text('Replace your tasks with this backup?'), findsNothing);
  });
}
