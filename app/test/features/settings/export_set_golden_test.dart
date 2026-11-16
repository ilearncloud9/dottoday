@Tags(['golden'])
library;

import 'dart:convert';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/export/multipart_export.dart';
import 'package:dottoday/data/export/prepared_file.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:dottoday/features/settings/widgets/export_set_sheet.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../domain/export/export_fixtures.dart';
import '../../support/dot_golden.dart';
import '../../support/export_fakes.dart';

// Settings › Export, a JSON export saved as a set (CR-160 B7a, derived:
// no reference render; docs/design-references/README.md "derived"). Native
// after a check that found every file; the web's per-file downloads with
// one already asked for. Copy approved 2026-11-11.

void main() {
  setUpAll(loadAppFonts);
  late PreparedSet set;
  final files = FakeFileGateway();
  setUpAll(() async {
    final split =
        splitExport(
              hostileBundle(),
              exportId: '01928c3e-0000-7000-8000-0000000000a1',
              appVersion: '0.1.0 (1)',
              schemaVersion: 21,
              purpose: ExportPurpose.export,
              date: '2026-11-11',
              targetBytes: 4096,
            )
            as MultipartSplit;
    final store = MemoryPreparedFileStore();
    final prepared = [
      for (final f in split.files)
        await store.put(f.name, utf8.encode(f.content), sha256Hex(f.content)),
    ];
    set = PreparedSet(
      split.manifest,
      prepared.first,
      prepared.skip(1).toList(),
    );
  });

  Widget sheet({required bool browser}) => Scaffold(
    body: SingleChildScrollView(
      child: Builder(
        builder: (context) => AppSheet(
          title: browser
              ? context.l10n.exportDownloadTitle(set.files.length)
              : context.l10n.exportSetDone(set.files.length),
          child: ExportSetSheet(set: set, browser: browser),
        ),
      ),
    ),
  );

  goldenMatrix(
    'export_set_native',
    height: 560,
    a11yVariants: true,
    overrides: [fileGatewayProvider.overrideWithValue(files)],
    build: (_) => sheet(browser: false),
    act: (tester) async {
      files.pickedFiles = pickedFrom(set.files);
      await tester.tap(find.text('Check my files…'));
    },
  );

  goldenMatrix(
    'export_set_web',
    height: 720,
    widths: const {'medium', 'expanded'},
    overrides: [fileGatewayProvider.overrideWithValue(files)],
    build: (_) => sheet(browser: true),
    act: (tester) async {
      await tester.tap(find.text('Download').first);
    },
  );
}
