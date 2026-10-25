import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../support/pseudo/pseudo_source.dart';
import '../../support/pseudo/pseudo_text.dart';

// The pseudo locale behind the truncation sweep (docs/09 M8.3).

void main() {
  test('pseudo text is longer, accented and bracketed', () {
    expect(pseudo('Add task'), '⟦ÅÅďď ťååšk⟧');
    expect(pseudo('9:30 – 11:00'), '9:30 – 11:00');
    expect(pseudo(', '), ', ');
    final long = 'Search titles, notes and subtasks';
    expect(pseudo(long).length, greaterThan(long.length * 1.3));
  });

  test('pseudo localizations cover every message (regenerate if not)', () {
    String squash(String s) => s.replaceAll(RegExp(r'[\s,]'), '');
    final expected = pseudoLocalizationsSource(
      File(abstractL10nPath).readAsStringSync(),
    );
    final actual = File(pseudoOutputPath).readAsStringSync();
    expect(
      squash(actual) == squash(expected),
      isTrue,
      reason:
          'Stale: run `dart run test/support/pseudo/write_pseudo.dart` '
          'from app/ after changing app_en.arb.',
    );
  });
}
