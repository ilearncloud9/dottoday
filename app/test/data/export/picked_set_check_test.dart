import 'dart:convert';
import 'dart:typed_data';

import 'package:dottoday/data/export/file_gateway.dart';
import 'package:dottoday/data/export/picked_set_check.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:dottoday/domain/export/multipart_format.dart';
import 'package:dottoday/domain/export/multipart_splitter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../domain/export/export_fixtures.dart';

// CR-160 B7a "Check my files": the picked files against the prepared set,
// read one at a time. Complete only for exactly the set; how many are
// missing otherwise; wrong for another export's, a changed, unreadable or
// doubled file.

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

PickedFile _file(String name, List<int> bytes) =>
    PickedFile(name, bytes.length, () async => Uint8List.fromList(bytes));

List<PickedFile> _picked(List<ExportFile> files) => [
  for (final f in files) _file(f.name, utf8.encode(f.content)),
];

void main() {
  final set = _split('01928c3e-0000-7000-8000-0000000000b1');
  final total = set.files.length;
  Future<PickedSetCheck> check(List<PickedFile> files) =>
      checkPickedSet(set.manifest, files);

  test('every file, any order: complete', () async {
    expect(
      await check(_picked(set.files.reversed.toList())),
      isA<PickedSetComplete>(),
    );
  });

  test('missing: the manifest, some parts, or everything', () async {
    Matcher missing(int n) =>
        isA<PickedSetMissing>().having((m) => m.missing, 'missing', n);
    expect(await check(_picked(set.files.skip(1).toList())), missing(1));
    expect(
      await check(_picked(set.files.take(2).toList())),
      missing(total - 2),
    );
    expect(await check(const []), missing(total));
  });

  test('wrong: another export, a changed or unreadable file, a file or '
      'manifest twice', () async {
    final other = _split('01928c3e-0000-7000-8000-0000000000b2');
    expect(await check(_picked(other.files)), isA<PickedSetWrong>());
    expect(
      await check(_picked([other.files.first, ...set.files.skip(1)])),
      isA<PickedSetWrong>(),
      reason: "this set's parts under another export's manifest",
    );
    final changed = [
      ..._picked(set.files.take(total - 1).toList()),
      _file('x.json', utf8.encode('${set.files.last.content} ')),
    ];
    expect(await check(changed), isA<PickedSetWrong>());
    expect(
      await check([
        ..._picked(set.files),
        _file('bad.json', [0xff, 0xfe]),
      ]),
      isA<PickedSetWrong>(),
    );
    expect(
      await check([..._picked(set.files), _picked(set.files).last]),
      isA<PickedSetWrong>(),
    );
    expect(
      await check([..._picked(set.files), _picked(set.files).first]),
      isA<PickedSetWrong>(),
    );
  });
}
