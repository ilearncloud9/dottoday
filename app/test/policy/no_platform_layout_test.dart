import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// Layout adapts by width class, never by `Platform.isX` (CLAUDE.md §11,
/// docs/10 §4). Chrome idioms go through `DotIdiom.of(context)`.
void main() {
  final platformCheck = RegExp(r'\bPlatform\.is[A-Z]');
  for (final dir in ['lib/features', 'lib/shared']) {
    test('$dir never branches on Platform.isX', () {
      final offences = [
        for (final MapEntry(key: path, value: source) in readLibSources(
          dir,
        ).entries)
          if (platformCheck.hasMatch(source)) path,
      ];
      expect(offences, isEmpty);
    });
  }
}
