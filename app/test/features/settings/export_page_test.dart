import 'dart:convert';
import 'dart:typed_data';

import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/domain/backup/backup_service.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/export/export_fixtures.dart';
import '../../support/a11y.dart';
import '../../support/export_fakes.dart';
import 'settings_harness.dart';

// Settings › Export (docs/09 M8.1, R-11): export, import with a pre-import
// backup and Undo, and going back to a backup on this device.

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  late FakeFileGateway files;
  late FakeExportService exports;
  late FakeBackupService backups;

  setUp(() {
    files = FakeFileGateway();
    exports = FakeExportService();
    backups = FakeBackupService();
  });

  Future<void> pump(WidgetTester tester) => pumpSettings(
    tester,
    location: '/settings/export',
    files: files,
    exports: exports,
    backups: backups,
  );

  testWidgets('each format is built and handed over on a tap', (tester) async {
    await pump(tester);
    expect(find.textContaining("aren't encrypted"), findsOneWidget);
    for (final (row, format) in [
      ('Everything (JSON)', ExportFormat.json),
      ('Tasks (CSV)', ExportFormat.csv),
      ('Calendar (.ics)', ExportFormat.ics),
    ]) {
      await _tap(tester, row);
      expect(exports.built.last, format);
      expect(files.delivered.last.single.name, 'dottoday.${format.name}');
    }
    expect(find.text('Exported'), findsWidgets);
    await expectA11yGuidelines(tester);
  });

  testWidgets('a closed sheet says nothing; a failed one says so', (
    tester,
  ) async {
    await pump(tester);
    files.outcome = DeliveryOutcome.cancelled;
    await _tap(tester, 'Everything (JSON)');
    expect(find.text('Exported'), findsNothing);
    files.throws = Exception('no sheet');
    await _tap(tester, 'Everything (JSON)');
    expect(find.textContaining("Couldn't save or share"), findsOneWidget);
  });

  testWidgets('import says what it replaces; nothing before Replace', (
    tester,
  ) async {
    final text = encodeExportJson(hostileBundle());
    files.picked = PickedBytes(utf8.encode(text));
    await pump(tester);
    await _tap(tester, 'Import a backup…');
    expect(files.pickLimits, [maxImportBytes]);
    expect(find.text('Replace your tasks with this backup?'), findsOneWidget);
    expect(find.textContaining('has 3 tasks'), findsOneWidget);
    expect(find.textContaining('moves to Trash'), findsOneWidget);
    expect(backups.imported, isEmpty);

    await _tap(tester, 'Cancel');
    expect(backups.imported, isEmpty);

    await _tap(tester, 'Import a backup…');
    await _tap(tester, 'Replace');
    expect(backups.imported, [text]);
    expect(find.text('Backup imported'), findsOneWidget);
    final safety = backups.backups.first;
    expect(safety.reason, BackupReason.preImport);
    // The new backup shows in the list at once.
    expect(find.text('Before an import'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(backups.restored, [safety.id]);
  });

  testWidgets('a wrong or oversized file is refused by name', (tester) async {
    await pump(tester);
    files.picked = PickedBytes(utf8.encode('{"version": 2}'));
    await _tap(tester, 'Import a backup…');
    expect(find.textContaining("isn't a Dottoday backup"), findsOneWidget);
    files.picked = PickedBytes(Uint8List.fromList([0xff, 0xfe]));
    await _tap(tester, 'Import a backup…');
    expect(find.textContaining("isn't a Dottoday backup"), findsWidgets);
    files.picked = const PickTooLarge();
    await _tap(tester, 'Import a backup…');
    expect(find.textContaining('over 25 MB'), findsOneWidget);
    expect(backups.imported, isEmpty);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('a backup on this device can be gone back to', (tester) async {
    backups.backups.add(
      BackupInfo(
        id: 7,
        createdAtUtc: DateTime.utc(2026, 10, 20, 7, 5),
        reason: BackupReason.daily,
        sizeBytes: 10,
      ),
    );
    await pump(tester);
    expect(find.text('Daily backup'), findsOneWidget);
    await _tap(tester, 'Daily backup');
    expect(find.text('Go back to this backup?'), findsOneWidget);
    expect(backups.restored, isEmpty);
    await _tap(tester, 'Restore');
    expect(backups.restored, [7]);
    expect(find.text('Backup restored'), findsOneWidget);
  });

  testWidgets('no backups yet: says when the first comes', (tester) async {
    await pump(tester);
    expect(find.textContaining('No backups yet'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final size in [const Size(390, 1400), const Size(1280, 1400)]) {
      testWidgets('a11y: ${mode.name} ${size.width}, page and confirm', (
        tester,
      ) async {
        backups.backups.add(
          BackupInfo(
            id: 7,
            createdAtUtc: DateTime.utc(2026, 10, 20, 7, 5),
            reason: BackupReason.daily,
            sizeBytes: 10,
          ),
        );
        files.picked = PickedBytes(
          utf8.encode(encodeExportJson(hostileBundle())),
        );
        await pumpSettings(
          tester,
          location: '/settings/export',
          mode: mode,
          size: size,
          files: files,
          exports: exports,
          backups: backups,
        );
        await expectA11yGuidelines(tester);
        await _tap(tester, 'Import a backup…');
        expect(find.byType(AlertDialog), findsOneWidget);
        await expectA11yGuidelines(tester);
      });
    }
  }
}
