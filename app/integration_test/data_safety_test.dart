// Settings › Data and privacy and Export on a device (docs/09 M20.10
// part 1; E-R2-21 §1–4, ED-319; the multi-file sheet, ED-477): the Data
// rows, Export with its formats and backups, and a backup saved as several
// files. In-memory data:
//   tool/device_tests.sh ios <udid> data_safety          (DEVICE_SHOT)
//   tool/device_tests.sh android <serial> data_safety
import 'dart:convert';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/router/app_routes.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:dottoday/features/settings/widgets/export_set_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../test/domain/export/export_fixtures.dart';
import '../test/features/timeline/calendar/calendar_world.dart';
import 'support/device_shot.dart';

Future<PreparedSet> _set() async {
  final split =
      splitExport(
            hostileBundle(),
            exportId: '01928c3e-0000-7000-8000-0000000000a1',
            appVersion: '0.1.0 (1)',
            schemaVersion: 21,
            purpose: ExportPurpose.export,
            date: '2026-11-26',
            targetBytes: 4096,
          )
          as MultipartSplit;
  final store = MemoryPreparedFileStore();
  final files = [
    for (final f in split.files)
      await store.put(f.name, utf8.encode(f.content), sha256Hex(f.content)),
  ];
  return PreparedSet(split.manifest, files.first, files.skip(1).toList());
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(tz_data.initializeTimeZones);

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('data safety, ${mode.name}', (tester) async {
      Future<void> shot(String step) =>
          deviceShot(binding, tester, 'data_safety_${mode.name}_$step');
      final router = await pumpCalendar(tester, mode: mode);

      router.go(AppRoutes.settingsPage(SettingsPage.dataPrivacy));
      await tester.pumpAndSettle();
      await shot('1_data_privacy');

      router.go(AppRoutes.settingsPage(SettingsPage.export));
      await tester.pumpAndSettle();
      await shot('2_export');

      final set = await tester.runAsync(_set);
      final context = tester.element(
        find.text(lookupAppLocalizations(const Locale('en')).exportJson),
      );
      // Not awaited: the sheet stays open for the shot.
      // ignore: unawaited_futures
      showExportSetSheet(context, set!, browser: false);
      await tester.pumpAndSettle();
      await shot('3_saved_as_files');

      router.go(AppRoutes.today);
      await tester.pumpAndSettle();
    });
  }
}
