import 'dart:convert';

import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/import_file_kind.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_part.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../fixtures.dart';
import 'export_fixtures.dart';

// CR-160 Stage B1 (docs/cr-160-multipart-export.md §2–§4, ADR-0019): the
// multipart format round-trips exactly, is byte-for-byte deterministic,
// is refused by today's (and every shipped) JSON v1 importer before any
// write, and its integrity check refuses corrupt, truncated, mixed or
// edited parts. A JSON v1 export that fits one part is unchanged.

const _id = '01928c3e-0000-7000-8000-0000000000e1';
const _otherId = '01928c3e-0000-7000-8000-0000000000e2';

/// The hostile bundle plus [n] tasks with long notes and a step each, so
/// series, instances and steps span parts.
ExportBundle _big(int n, {int notes = 400}) {
  final base = hostileBundle();
  String id(String kind, int i) =>
      '01928c3e-0000-7000-8$kind-${i.toString().padLeft(12, '0')}';
  return ExportBundle(
    exportedAt: base.exportedAt,
    profile: base.profile,
    series: base.series,
    occurrences: [
      ...base.occurrences,
      for (var i = 0; i < n; i++)
        occurrenceFixture().copyWith(
          id: id('001', i),
          title: '$hostileTitle $i',
          notes: '${hostileNotes * (notes ~/ hostileNotes.length)} $i',
        ),
    ],
    subtasks: [
      ...base.subtasks,
      for (var i = 0; i < n; i++)
        subtaskFixture().copyWith(
          id: id('002', i),
          occurrenceId: id('001', i),
          title: 'Step $i',
        ),
    ],
    routines: base.routines,
  );
}

ExportSplit _split(ExportBundle b, {String id = _id, int target = 8192}) =>
    splitExport(
      b,
      exportId: id,
      appVersion: '1.0.0+1',
      schemaVersion: 20,
      purpose: ExportPurpose.export,
      date: '2026-11-11',
      targetBytes: target,
    );

MultipartSplit _multi(ExportBundle b, {String id = _id, int target = 8192}) =>
    _split(b, id: id, target: target) as MultipartSplit;

/// What B3 will do through staging, in memory: the parts' rows back into
/// one v1 bundle.
ExportBundle _join(ExportManifest m, List<ExportPart> parts) {
  final ordered = [...parts]..sort((a, b) => a.index.compareTo(b.index));
  return ExportBundle.fromJson({
    'version': 1,
    'exportedAt': m.exportedAtMs,
    'profile': ordered.first.profile,
    for (final t in partTables) t: [for (final p in ordered) ...p.rows[t]!],
  });
}

List<ExportPart> _accepted(MultipartSplit s) {
  final set = PartSet(s.manifest);
  final parts = [
    for (final f in s.files.skip(1))
      switch (set.add(f.content)) {
        PartAccepted(:final part) => part,
        PartRefused(:final problem) => fail('refused: $problem'),
      },
  ];
  expect(set.complete, isTrue);
  return parts;
}

String _flip(String text, int at) =>
    text.replaceRange(at, at + 1, text[at] == 'a' ? 'b' : 'a');

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('an export that fits one part is today\'s JSON v1 file, unchanged', () {
    final b = hostileBundle();
    expect(
      (_split(b, target: partTargetBytes) as SingleFileSplit).text,
      encodeExportJson(b),
    );
  });

  test('a larger one round-trips exactly through manifest and parts; '
      'references across parts resolve', () {
    final b = _big(60);
    final s = _multi(b);
    expect(s.files.length, greaterThan(4));
    for (final f in s.files.skip(1)) {
      expect(utf8.encode(f.content).length, lessThanOrEqualTo(8192));
    }
    final joined = _join(s.manifest, _accepted(s));
    expect(joined.toJson(), b.toJson());
    // The joined set passes today's import validation, references and all.
    final decoded = decodeExportJson(encodeExportJson(joined));
    expect(decoded, isA<Ok<ExportBundle, ValidationFailure>>());
    expect(s.manifest.totals['occurrences'], b.occurrences.length);
    expect(s.manifest.parts.first.counts['occurrences'], isNot(0));
  });

  test('deterministic: the same data gives the same bytes, names and '
      'hashes', () {
    final a = _multi(_big(40));
    final b = _multi(_big(40));
    expect(
      [for (final f in a.files) f.content],
      [for (final f in b.files) f.content],
    );
    expect(
      [for (final f in a.files) f.name],
      [for (final f in b.files) f.name],
    );
    expect(
      a.files.first.name,
      'dottoday-backup-2026-11-11-000000e1-manifest.json',
    );
    expect(
      a.files[1].name,
      endsWith(
        '-part-01-of-${a.files.length - 1 < 10 ? '0' : ''}${a.files.length - 1}.json',
      ),
    );
  });

  test('today\'s importer (and every shipped one) refuses a manifest and '
      'every part before reading a row', () {
    final s = _multi(_big(30));
    for (final ExportFile(:content) in s.files) {
      final r = decodeExportJson(content);
      expect(
        r,
        isA<Err<ExportBundle, ValidationFailure>>().having(
          (e) => e.failure.rule,
          'rule',
          ValidationRule.invalidFormat,
        ),
      );
      expect(jsonDecode(content), isNot(contains('version')));
    }
  });

  test('files are recognised by content, never by name', () {
    final s = _multi(_big(30));
    expect(importFileKind(s.files.first.content), ImportFileKind.manifest);
    for (final f in s.files.skip(1)) {
      expect(importFileKind(f.content), ImportFileKind.part);
    }
    expect(
      importFileKind(encodeExportJson(hostileBundle())),
      ImportFileKind.legacy,
    );
    expect(importFileKind('not json'), ImportFileKind.unknown);
    expect(importFileKind('{"version":2}'), ImportFileKind.unknown);
    expect(
      importFileKind('{"version":1,"format":"dottoday-part"}'),
      ImportFileKind.legacy,
      reason: 'a v1 key wins: today\'s import reads it',
    );
    expect(
      importFileKind('"${'a' * (maxImportBytes + 1)}"'),
      ImportFileKind.tooLarge,
    );
  });

  group('integrity', () {
    late MultipartSplit s;
    setUp(() => s = _multi(_big(40)));
    String part(int i) => s.files[i].content;

    test('a changed byte, a truncated part or a part of another export is '
        'refused', () {
      final set = PartSet(s.manifest);
      expect(
        (set.add(_flip(part(2), 200)) as PartRefused).problem,
        PartProblem.hashMismatch,
      );
      expect(
        (set.add(part(2).substring(0, part(2).length - 5)) as PartRefused)
            .problem,
        PartProblem.hashMismatch,
      );
      final other = _multi(_big(40), id: _otherId);
      expect(
        (set.add(other.files[2].content) as PartRefused).problem,
        PartProblem.hashMismatch,
      );
      expect(set.missing, [for (var i = 1; i < s.files.length; i++) i]);
    });

    test('an edited part with its hash recomputed in the manifest is caught '
        'by its fields; rows are left to the importer\'s validators', () {
      final edited = (jsonDecode(part(2)) as Map<String, Object?>)
        ..['index'] = 3;
      final text = canonicalJson(edited);
      final m = jsonDecode(s.files.first.content) as Map<String, Object?>;
      final entries = (m['parts']! as List<Object?>)
          .cast<Map<String, Object?>>();
      entries[1]
        ..['sha256'] = sha256Hex(text)
        ..['bytes'] = utf8.encode(text).length;
      final manifest = ExportManifest.decode(canonicalJson(m))!;
      expect(
        (checkPart(manifest, text) as PartRefused).problem,
        PartProblem.inconsistent,
      );
    });

    test('a repeated part is accepted only as the identical file', () {
      final set = PartSet(s.manifest);
      expect((set.add(part(1)) as PartAccepted).duplicate, isFalse);
      expect((set.add(part(1)) as PartAccepted).duplicate, isTrue);
      expect(set.missing, isNot(contains(1)));
      expect(set.complete, isFalse);
    });

    test('over the read limit: refused before reading', () {
      expect(
        (checkPart(s.manifest, '"${'a' * (maxImportBytes + 1)}"')
                as PartRefused)
            .problem,
        PartProblem.tooLarge,
      );
    });
  });

  test('a manifest that is not exactly this format is not read', () {
    final good =
        jsonDecode(_multi(_big(30)).files.first.content)
            as Map<String, Object?>;
    String edit(void Function(Map<String, Object?> m) f) {
      final m = jsonDecode(jsonEncode(good)) as Map<String, Object?>;
      f(m);
      return canonicalJson(m);
    }

    expect(ExportManifest.decode(canonicalJson(good)), isNotNull);
    for (final bad in [
      edit((m) => m['version'] = 1),
      edit((m) => m['formatVersion'] = 2),
      edit((m) => m['exportId'] = 'not-a-uuid'),
      edit((m) => m['purpose'] = 'sideload'),
      edit((m) => (m['totals']! as Map)['occurrences'] = 1),
      edit((m) => ((m['parts']! as List).first as Map)['index'] = 2),
      edit((m) => ((m['parts']! as List).first as Map)['sha256'] = 'ABC'),
      edit((m) => (m['parts']! as List).clear()),
      'not json',
    ]) {
      expect(
        ExportManifest.decode(bad),
        isNull,
        reason: bad.substring(0, bad.length.clamp(0, 40)),
      );
    }
  });

  test('a row too large for any part fails the split: nothing is left '
      'out', () {
    final b = _big(3, notes: 9000);
    final r = _split(b, target: 4096);
    expect(
      r,
      isA<RowTooLarge>().having((r) => r.table, 'table', 'occurrences'),
    );
  });

  test('at full size (~25.6 MB): parts stay under the 10 MB target and '
      'round-trip', () {
    final b = _big(2500, notes: maxNotesForTest);
    final s = _multi(b, target: partTargetBytes);
    expect(s.files.length - 1, 3);
    for (final f in s.files.skip(1)) {
      expect(utf8.encode(f.content).length, lessThanOrEqualTo(partTargetBytes));
    }
    expect(_join(s.manifest, _accepted(s)).toJson(), b.toJson());
  });
}

/// `maxNotesLength` (domain/validation/field_rules.dart), less the suffix.
const maxNotesForTest = 9990;
