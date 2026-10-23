import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';

// No-shame rule (CLAUDE.md §11, 11-standout-roadmap D, docs/09 M6.5.11):
// no streaks, no "late / missed / failed" said about the user, no red for
// what isn't done. Every English string is checked; new strings must pass.

/// Words that judge (word boundaries: "later" and "latest" pass).
final _judging = RegExp(
  r'\b(late|missed|miss|failed|fail|failure|streaks?|overdue|behind)\b',
  caseSensitive: false,
);

/// The owner's one exception (2026-10-23): "Running late" is the user's
/// own action — the button, its menu item and sheet, the help answer about
/// it and the setting that names its nudge — not the app judging them.
/// The text a user reads: ICU placeholder names (`{missed}`) are code.
String _withoutPlaceholders(String icu) =>
    icu.replaceAll(RegExp(r'\{\w+'), '{');

const _runningLateAction = {
  'runningLate',
  'todayMenuLate',
  'lateAmount',
  'helpLateQ',
  'helpLateA',
  'settingsLateNudge',
};

void main() {
  test('no English string judges the user', () {
    final arb =
        jsonDecode(File('lib/core/l10n/arb/app_en.arb').readAsStringSync())
            as Map<String, Object?>;
    final offending = [
      for (final MapEntry(:key, :value) in arb.entries)
        if (!key.startsWith('@') &&
            value is String &&
            !_runningLateAction.contains(key) &&
            _judging.hasMatch(_withoutPlaceholders(value)))
          '$key: $value',
    ];
    expect(offending, isEmpty);
  });

  test('the exception list only names strings that exist', () {
    final arb = File('lib/core/l10n/arb/app_en.arb').readAsStringSync();
    for (final key in _runningLateAction) {
      expect(arb, contains('"$key":'), reason: key);
    }
  });

  test('no red: UI never paints with an error colour', () {
    final red = RegExp(r'colorScheme\.error|Colors\.red');
    final hits = [
      for (final dir in ['lib/features', 'lib/shared'])
        for (final MapEntry(:key, :value) in readLibSources(dir).entries)
          if (red.hasMatch(value)) key,
    ];
    expect(hits, isEmpty);
  });
}
