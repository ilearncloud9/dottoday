import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// Concept E is built "staged" (owner, 2026-11-16, ED-360): the colour
/// roles keep their old Concept A names until each screen is rebuilt, and
/// plan M20.14 deletes those names. A file rebuilt for Concept E says so on
/// a line of its own:
///
/// ```dart
/// // concept-e: rebuilt (M19.1, E-Phones Today)
/// ```
///
/// and from then on may only read Concept E's names. This test fails if a
/// marked file still reads a Concept A name.
final _marker = RegExp(r'^//\s*concept-e:\s*rebuilt\b', multiLine: true);

/// Concept A name → the Concept E role it now stands for.
const _old = {
  'surface': 'ground',
  'raised': 'card',
  'text': 'ink',
  'muted': 'secondary',
  'outline': 'hairline',
  'accentInk': 'accentText',
  'accentTint': 'tonal',
};

/// A read of a Concept A role on the theme's colours (`c.raised`,
/// `t.colors.muted`, `colors.outline`).
final _read = RegExp(
  r'\b(?:colors|c)\.(' + _old.keys.join('|') + r')\b(?!\s*[:(])',
);

/// Concept E headings are sentence case; Concept A uppercased them in each
/// widget (owner, 2026-11-16: they change as each screen is rebuilt).
final _upper = RegExp(r'\.toUpperCase\(\)');

List<String> offences(String path, String source) {
  if (!_marker.hasMatch(source)) return const [];
  final out = <String>[];
  final lines = source.split('\n');
  for (var i = 0; i < lines.length; i++) {
    for (final m in _read.allMatches(lines[i])) {
      out.add('$path:${i + 1} reads `${m.group(1)}`; use `${_old[m[1]]}`');
    }
    if (_upper.hasMatch(lines[i])) {
      out.add('$path:${i + 1} uppercases text; Concept E is sentence case');
    }
  }
  return out;
}

void main() {
  test('the scanner flags an old name only in a marked file', () {
    const marked =
        '// concept-e: rebuilt (test)\nfinal x = c.raised;\n'
        "final y = 'Steps'.toUpperCase();\n";
    const unmarked = 'final x = c.raised;\n';
    expect(offences('a.dart', marked), hasLength(2));
    expect(offences('b.dart', unmarked), isEmpty);
  });

  for (final dir in ['lib/features', 'lib/shared']) {
    test('$dir: files rebuilt for Concept E use only Concept E names', () {
      final found = <String>[
        for (final MapEntry(key: path, value: source) in readLibSources(
          dir,
        ).entries)
          ...offences(path, source),
      ];
      expect(found, isEmpty);
    });
  }
}
