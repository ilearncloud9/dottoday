import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';
import 'ui_string_literals.dart';

void main() {
  group('uiStringLiteralLines', () {
    test('flags plain and interpolated literals', () {
      const src = '''
Widget a() => Text('Hello');
Widget b(int n) => Text('\$n tasks');
Widget c() => Text('a' 'b');
''';
      expect(uiStringLiteralLines(src), [1, 2, 3, 3]);
    });

    test('allows directives, annotations, empty, keys and l10n-ignore', () {
      const src = '''
import 'package:flutter/widgets.dart';
part 'x.g.dart';
@Deprecated('use y')
Widget a() => Text('');
Widget b() => SizedBox(key: ValueKey('timeline'));
Widget c() => SizedBox(key: const ValueKey<String>('x'));
Widget d() => SizedBox(key: Key('k'));
Widget e() => Text('•'); // l10n-ignore: bullet glyph, not copy
''';
      expect(uiStringLiteralLines(src), isEmpty);
    });

    test('l10n-ignore without a reason does not suppress', () {
      expect(uiStringLiteralLines("final s = 'x'; // l10n-ignore:\n"), [1]);
    });
  });

  // All of features/ and shared/, not just widgets/: notifiers produce
  // user-visible text too. Legitimate exceptions use `// l10n-ignore: <why>`.
  test('no UI string literals in features/** and shared/**', () {
    final sources = {
      ...readLibSources('lib/features'),
      ...readLibSources('lib/shared'),
    };
    final offenders = [
      for (final MapEntry(key: path, value: src) in sources.entries)
        for (final line in uiStringLiteralLines(src)) 'lib/$path:$line',
    ];
    expect(offenders, isEmpty, reason: 'Use context.l10n (CLAUDE.md §4).');
  });
}
