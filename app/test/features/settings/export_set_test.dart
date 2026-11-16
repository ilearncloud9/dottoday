import 'dart:convert';

import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/data/owners/account_gate.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/export/export_fixtures.dart';
import '../../support/a11y.dart';
import '../../support/export_fakes.dart';
import 'settings_harness.dart';

// CR-160 B7a: Settings › Export › Everything (JSON) over one part is a set
// (owner: automatic). Native hands every file over at once, then says what
// it is; the web lists one Download per file. "Check my files…" picks them
// back and says whether they are complete. Copy approved 2026-11-11.

/// A set of the hostile bundle in small parts, prepared in memory.
Future<PreparedSet> _set(String exportId) async {
  final split =
      splitExport(
            hostileBundle(),
            exportId: exportId,
            appVersion: '0.1.0 (1)',
            schemaVersion: 21,
            purpose: ExportPurpose.export,
            date: '2026-11-11',
            targetBytes: 2048,
          )
          as MultipartSplit;
  final store = MemoryPreparedFileStore();
  final files = [
    for (final f in split.files)
      await store.put(f.name, utf8.encode(f.content), sha256Hex(f.content)),
  ];
  return PreparedSet(split.manifest, files.first, files.skip(1).toList());
}

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
  late PreparedSet set;
  setUp(() async {
    files = FakeFileGateway();
    exports = FakeExportService();
    set = await _set('01928c3e-0000-7000-8000-0000000000a1');
    exports.set = Ok(set);
  });

  Future<void> pump(WidgetTester tester, {bool browser = false}) =>
      pumpSettings(
        tester,
        location: '/settings/export',
        files: files,
        exports: exports,
        overrides: [inBrowserProvider.overrideWithValue(browser)],
      );

  testWidgets('native: every file handed over at once, then what it is and '
      'a check that says complete', (tester) async {
    await pump(tester);
    await _tap(tester, 'Everything (JSON)');
    final n = set.files.length;
    expect(exports.setVersions, ['0.1.0 (1)']);
    expect(files.deliveredSets.single.map((f) => f.name), [
      for (final f in set.files) f.name,
    ]);
    expect(files.delivered, isEmpty, reason: 'not a single file');
    expect(find.text('Exported as $n files'), findsOneWidget);
    expect(find.textContaining('saved as $n files'), findsOneWidget);
    files.pickedFiles = pickedFrom(set.files.reversed.toList());
    await _tap(tester, 'Check my files…');
    expect(find.text('All $n files are here and complete.'), findsOneWidget);
    await expectA11yGuidelines(tester);
  });

  testWidgets('the check: files missing, or another export\'s', (tester) async {
    await pump(tester);
    await _tap(tester, 'Everything (JSON)');
    final n = set.files.length;
    files.pickedFiles = pickedFrom(set.files.skip(2).toList());
    await _tap(tester, 'Check my files…');
    expect(
      find.text('2 of $n files are missing. Pick the manifest and every part.'),
      findsOneWidget,
    );
    final other = await _set('01928c3e-0000-7000-8000-0000000000a2');
    files.pickedFiles = pickedFrom(other.files);
    await _tap(tester, 'Check my files…');
    expect(
      find.text(
        'These files don’t match this export. Pick the files you just saved.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a closed share sheet: no sheet, nothing said', (tester) async {
    await pump(tester);
    files.outcome = DeliveryOutcome.cancelled;
    await _tap(tester, 'Everything (JSON)');
    expect(find.textContaining('Exported'), findsNothing);
  });

  testWidgets('web: one Download per file, each marked once asked', (
    tester,
  ) async {
    await pump(tester, browser: true);
    await _tap(tester, 'Everything (JSON)');
    final n = set.files.length;
    expect(files.deliveredSets, isEmpty);
    expect(find.text('Download $n files'), findsOneWidget);
    expect(find.text('Download'), findsNWidgets(n));
    await _tap(tester, 'Download');
    expect(files.downloads, [set.files.first.name]);
    expect(find.text('Downloaded'), findsOneWidget);
    expect(find.text('Download'), findsNWidgets(n - 1));
    expect(
      find.text('Your browser may ask you to allow several downloads.'),
      findsOneWidget,
    );
    await expectA11yGuidelines(tester);
  });
}
