import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// Raw style values a widget must take from `DotTheme` instead (CLAUDE.md
/// §11, docs/10 §2): colours, curves, literal radii and animation
/// durations. Time maths (`Duration(minutes: …)`) is fine, and a line
/// ending in `// style-ignore: <reason>` is exempt (e.g. a save debounce,
/// which is behaviour, not motion).
final _banned = <String, RegExp>{
  'Color(0x…)': RegExp(r'\bColor\(0x'),
  'Colors.*': RegExp(r'\bColors\.(?!transparent\b)'),
  'Curves.*': RegExp(r'\bCurves\.'),
  'literal radius': RegExp(r'Radius\.circular\(\s*\d'),
  'literal animation duration': RegExp(r'Duration\(\s*milliseconds:\s*\d'),
};

/// Exemption marker; must carry a reason.
final _ignore = RegExp(r'//\s*style-ignore:\s*\S');

void main() {
  for (final dir in ['lib/features', 'lib/shared']) {
    test('$dir uses theme tokens, never raw style values', () {
      final offences = <String>[];
      for (final MapEntry(key: path, value: source) in readLibSources(
        dir,
      ).entries) {
        final lines = source.split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (_ignore.hasMatch(lines[i])) continue;
          for (final MapEntry(key: what, value: re) in _banned.entries) {
            if (re.hasMatch(lines[i])) offences.add('$path:${i + 1} $what');
          }
        }
      }
      expect(offences, isEmpty, reason: 'Read DotTheme.of(context) instead.');
    });
  }
}
