@Tags(['golden'])
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/export/export_providers.dart';
import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/picked_import.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:dottoday/features/settings/widgets/import_set_sheet.dart';
import 'package:dottoday/shared/sheets/app_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../domain/export/export_fixtures.dart';
import '../../support/dot_golden.dart';
import '../../support/export_fakes.dart';

// Settings › Export › Import, "Add the rest of this backup" (CR-160 B7b,
// derived: no reference render). Two of four files in, after another
// backup's file was refused. Copy approved 2026-11-11.

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
      null,
      () async => Uint8List.fromList(utf8.encode(f.content)),
    ),
];

void main() {
  setUpAll(loadAppFonts);
  final set = _split('01928c3e-0000-7000-8000-0000000000d1');
  final files = FakeFileGateway();
  late SetDraft draft;
  setUp(() async {
    draft = ((await addPicked(null, _picked(set.files.take(2)))) as PickedSet)
        .draft;
  });

  goldenMatrix(
    'import_set_add_rest',
    height: 420,
    a11yVariants: true,
    overrides: [fileGatewayProvider.overrideWithValue(files)],
    build: (_) => Scaffold(
      body: SingleChildScrollView(
        child: Builder(
          builder: (context) => AppSheet(
            title: context.l10n.importAddTitle,
            child: ImportSetSheet(draft: draft),
          ),
        ),
      ),
    ),
    act: (tester) async {
      files.pickedFiles = _picked([
        _split('01928c3e-0000-7000-8000-0000000000d2').files.last,
      ]);
      await tester.tap(find.text('Add files…'));
    },
  );
}
