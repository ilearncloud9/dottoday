import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Settings › Siri & Shortcuts (docs/09 M14.3, D3) quotes the five phrases
// Siri listens for. They must say exactly what `AppShortcuts.strings`
// registers in each language, or the page teaches a phrase Siri ignores.

const _keys = {
  'Add a task in \${applicationName}': 'siriPhraseAdd',
  "What's next in \${applicationName}": 'siriPhraseNext',
  'Mark my task done in \${applicationName}': 'siriPhraseDone',
  'Give my task 15 more minutes in \${applicationName}': 'siriPhrasePlus15',
  'Start focus in \${applicationName}': 'siriPhraseFocus',
};

final _line = RegExp(r'^"(.+)" = "(.+)";$');

Map<String, String> _strings(String lang) => {
  for (final l in File(
    'ios/Runner/$lang.lproj/AppShortcuts.strings',
  ).readAsLinesSync())
    if (_line.firstMatch(l.trim()) case final m?) m[1]!: m[2]!,
};

void main() {
  test('Swift registers exactly the five phrases (no sixth intent)', () {
    final src = File('ios/Runner/DotShortcuts.swift').readAsStringSync();
    expect(RegExp('AppShortcut\\(').allMatches(src), hasLength(5));
    expect(_strings('en').keys.toSet(), _keys.keys.toSet());
  });

  for (final lang in ['en', 'de', 'fr', 'es']) {
    test('$lang: the page says what Siri listens for', () {
      final arb =
          jsonDecode(File('lib/core/l10n/arb/app_$lang.arb').readAsStringSync())
              as Map<String, dynamic>;
      final siri = _strings(lang);
      for (final MapEntry(key: phrase, value: key) in _keys.entries) {
        final spoken = siri[phrase];
        expect(spoken, isNotNull, reason: '$lang: $phrase');
        expect(
          arb[key],
          spoken!.replaceAll(r'${applicationName}', 'Dottoday'),
          reason: '$lang: $key',
        );
      }
    });
  }
}
