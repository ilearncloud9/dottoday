import 'dart:convert';
import 'dart:typed_data';

import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/picked_import.dart';
import 'package:dottoday/domain/export/export_bundle.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/export_json.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import '../../domain/export/export_fixtures.dart';

// CR-160 B7b: what picked files are. One v1 file alone is today's import;
// anything else is one set, gathered over picks, checked whole once every
// file is in; a file over the limit is refused unread.

/// The hostile bundle plus a task in Trash (never counted as a task to
/// replace with).
ExportBundle _bundle() {
  final b = hostileBundle();
  return ExportBundle(
    exportedAt: b.exportedAt,
    profile: b.profile,
    series: b.series,
    occurrences: [
      ...b.occurrences,
      b.occurrences.first.copyWith(
        id: '01928c3e-0000-7000-8000-0000000009d1',
        seriesId: null,
        deletedAt: b.exportedAt,
      ),
    ],
    subtasks: b.subtasks,
    routines: b.routines,
  );
}

MultipartSplit _split(String id) =>
    splitExport(
          _bundle(),
          exportId: id,
          appVersion: '1',
          schemaVersion: 21,
          purpose: ExportPurpose.export,
          date: '2026-11-11',
          targetBytes: 2048,
        )
        as MultipartSplit;

PickedFile _file(String name, List<int> bytes) =>
    PickedFile(name, bytes.length, () async => Uint8List.fromList(bytes));

List<PickedFile> _picked(Iterable<ExportFile> files) => [
  for (final f in files) _file(f.name, utf8.encode(f.content)),
];

Matcher _refused(PickRefusal r) =>
    isA<PickRefused>().having((p) => p.reason, 'reason', r);

void main() {
  setUpAll(tz_data.initializeTimeZones);
  final set = _split('01928c3e-0000-7000-8000-0000000000c1');
  final other = _split('01928c3e-0000-7000-8000-0000000000c2');
  final live = _bundle().occurrences.where((o) => o.deletedAt == null).length;
  assert(live < _bundle().occurrences.length, 'a task in Trash');

  test('one v1 file is today\'s import', () async {
    final text = encodeExportJson(hostileBundle());
    expect(
      await addPicked(null, [_file('b.json', utf8.encode(text))]),
      isA<PickedSingle>().having((p) => p.text, 'text', text),
    );
  });

  test('a whole set at once: complete, its live tasks counted, read in '
      'order', () async {
    final r = await addPicked(null, _picked(set.files.reversed));
    final draft = (r as PickedSet).draft;
    expect(draft.complete, isTrue);
    expect(draft.liveTasks, live);
    expect((draft.added, draft.total), (set.files.length, set.files.length));
    expect(
      [for (final read in draft.readers) await read()],
      [for (final f in set.files.skip(1)) f.content],
    );
  });

  test('gathered over picks; a part twice is harmless', () async {
    final first = await addPicked(null, _picked(set.files.take(2)));
    final draft = (first as PickedSet).draft;
    expect(draft.complete, isFalse);
    expect((draft.added, draft.total), (2, set.files.length));
    final again = await addPicked(draft, _picked(set.files.skip(1)));
    expect((again as PickedSet).draft.complete, isTrue);
  });

  test('another backup\'s file, a v1 file among a set\'s, two v1 files: '
      'foreign', () async {
    final draft =
        (await addPicked(null, _picked(set.files.take(2))) as PickedSet).draft;
    expect(
      await addPicked(draft, _picked([other.files.last])),
      _refused(PickRefusal.foreign),
    );
    expect(
      await addPicked(draft, _picked([other.files.first])),
      _refused(PickRefusal.foreign),
    );
    final v1 = _file('b.json', utf8.encode(encodeExportJson(hostileBundle())));
    expect(
      await addPicked(null, [..._picked(set.files.take(1)), v1]),
      _refused(PickRefusal.foreign),
    );
    expect(await addPicked(null, [v1, v1]), _refused(PickRefusal.foreign));
  });

  test('a changed part is refused and leaves the draft; the right file '
      'completes it', () async {
    final draft =
        (await addPicked(null, _picked(set.files.take(1))) as PickedSet).draft;
    final changed = [
      ..._picked(set.files.skip(1).take(set.files.length - 2)),
      _file('x.json', utf8.encode('${set.files.last.content} ')),
    ];
    expect(await addPicked(draft, changed), _refused(PickRefusal.notBackup));
    expect(draft.complete, isFalse);
    final fixed = await addPicked(draft, _picked([set.files.last]));
    expect((fixed as PickedSet).draft.complete, isTrue);
  });

  test('over the limit: refused unread; not UTF-8 or not a backup: '
      'notBackup', () async {
    final big = PickedFile(
      'big.json',
      maxImportBytes + 1,
      () => throw StateError('read'),
    );
    expect(await addPicked(null, [big]), _refused(PickRefusal.tooLarge));
    expect(
      await addPicked(null, [
        _file('x.json', [0xff, 0xfe]),
      ]),
      _refused(PickRefusal.notBackup),
    );
    expect(
      await addPicked(null, [_file('x.json', utf8.encode('{"version": 2}'))]),
      _refused(PickRefusal.notBackup),
    );
  });
}
