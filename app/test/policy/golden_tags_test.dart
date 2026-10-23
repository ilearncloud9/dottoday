import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Goldens are baselined on macOS and run only in the macOS `goldens` job;
// an untagged golden file runs in the Linux unit job and fails on pixels
// (found by CI, M5.9).
void main() {
  test('every golden test file is tagged golden', () {
    final untagged = [
      for (final f in Directory('test').listSync(recursive: true))
        if (f is File && f.path.endsWith('_test.dart'))
          if (_untaggedGolden(f.readAsStringSync())) f.path,
    ];
    expect(untagged, isEmpty);
  });
}

bool _untaggedGolden(String source) =>
    (source.contains('goldenMatrix(') ||
        source.contains('matchesGoldenFile(')) &&
    !source.contains("@Tags(['golden'])");
