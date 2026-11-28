import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

/// The colour roles carry Concept E's names only (plan M20.14, ED-360,
/// ED-503). The compiler already rejects a read of a name `DotColors` no
/// longer has; this test stops a Concept A name from being added back to
/// the class as a field or alias getter.
const _conceptA = {
  'surface': 'ground',
  'raised': 'card',
  'text': 'ink',
  'muted': 'secondary',
  'outline': 'hairline',
  'accentInk': 'accentText',
  'accentTint': 'tonal',
};

/// Members of the class [name] in [source] that use a Concept A name.
List<String> offences(String source, {String name = 'DotColors'}) {
  final cls = parseDart(source).declarations
      .whereType<ClassDeclaration>()
      .firstWhere((c) => c.namePart.typeName.lexeme == name);
  final names = <String>[
    for (final member in cls.body.members)
      if (member case FieldDeclaration(:final fields))
        for (final v in fields.variables) v.name.lexeme
      else if (member case MethodDeclaration(:final name))
        name.lexeme,
  ];
  return [
    for (final n in names)
      if (_conceptA[n] case final e?) '`$n` is Concept A; use `$e`',
  ];
}

void main() {
  test('the scanner flags a Concept A field or getter', () {
    const bad = '''
class DotColors {
  final Color raised;
  Color get muted => raised;
  final Color ink;
}
''';
    expect(offences(bad), hasLength(2));
  });

  test('DotColors uses only Concept E names', () {
    final source = File('lib/core/theme/dot_colors.dart').readAsStringSync();
    expect(offences(source), isEmpty);
  });
}
