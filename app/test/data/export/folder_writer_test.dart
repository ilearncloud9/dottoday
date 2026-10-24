import 'dart:io';

import 'package:dottoday/data/export/folder_writer_io.dart';
import 'package:dottoday/domain/export/export_files.dart';
import 'package:flutter_test/flutter_test.dart';

// The Mac's several-files export (docs/09 M8.1): written whole or not at
// all, never a half file under the export's name.
void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('export_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('every file lands whole, no .part left', () async {
    await writeToFolder(dir.path, const [
      ExportFile(name: 'a.csv', mimeType: 'text/csv', content: 'x,ü\r\n'),
      ExportFile(name: 'b.csv', mimeType: 'text/csv', content: ''),
    ]);
    final names = dir.listSync().map((e) => e.uri.pathSegments.last).toSet();
    expect(names, {'a.csv', 'b.csv'});
    expect(File('${dir.path}/a.csv').readAsStringSync(), 'x,ü\r\n');
  });

  test('a failed write leaves nothing under the name', () async {
    // A folder in the target's place makes the rename fail.
    Directory('${dir.path}/a.csv').createSync();
    await expectLater(
      writeToFolder(dir.path, const [
        ExportFile(name: 'a.csv', mimeType: 'text/csv', content: 'x'),
      ]),
      throwsA(isA<FileSystemException>()),
    );
    expect(File('${dir.path}/a.csv.part').existsSync(), isFalse);
  });
}
