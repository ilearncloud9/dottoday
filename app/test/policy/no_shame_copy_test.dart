import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'source_scan.dart';
import 'store_listing_test.dart' show readListing, storeLocales;

// No-shame rule (CLAUDE.md §11, 11-standout-roadmap D, docs/09 M6.5.11):
// no streaks, no "late / missed / failed" said about the user, no red for
// what isn't done. Every string in every language is checked; new strings
// must pass (docs/09 M8.3 added de/fr/es).

/// Words that judge (word boundaries: "later" and "latest" pass). The
/// night (docs/15 W6, §12) adds "short", "debt" and "score": the app plans
/// sleep, it never measures it.
final _judging = RegExp(
  r'\b(late|missed|miss|failed|fail|failure|streaks?|overdue|behind|'
  r'short|debt|score)\b',
  caseSensitive: false,
);

/// The same judgement in the translations (stems: "verpasst" and
/// "verspätet" both hit). "tarde" is Spanish for afternoon, so it is not
/// listed; "retraso" only appears in the Running-late strings.
final _judgingByLocale = {
  'de': RegExp(
    r'(verpass|versäum|überfällig|verspät|fehlgeschlagen|gescheitert|'
    r'misserfolg|rückstand|strähne)',
    caseSensitive: false,
  ),
  'fr': RegExp(
    r'(manqué|raté|en retard|échou|échec|dépassé|\bséries?\b)',
    caseSensitive: false,
  ),
  'es': RegExp(
    r'(perdid|fallid|fallar|atrasad|retras|vencid|racha|fracas)',
    caseSensitive: false,
  ),
};

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

/// The weekly review's footer (11 D1, docs/09 M12.1: "No streaks here —
/// just what happened."): it names streaks only to promise there are
/// none, as the plan words it.
const _noStreakPromise = {'weekReviewNoStreaks'};

/// Running late's "Too short to lose {minutes} min": about a task's
/// length, not the user's night.
const _taskLength = {'lateShortenTooShort'};

/// Keys the judging check skips.
const _allowed = {..._runningLateAction, ..._noStreakPromise, ..._taskLength};

void main() {
  test('no English string judges the user', () {
    final arb =
        jsonDecode(File('lib/core/l10n/arb/app_en.arb').readAsStringSync())
            as Map<String, Object?>;
    final offending = [
      for (final MapEntry(:key, :value) in arb.entries)
        if (!key.startsWith('@') &&
            value is String &&
            !_allowed.contains(key) &&
            _judging.hasMatch(_withoutPlaceholders(value)))
          '$key: $value',
    ];
    expect(offending, isEmpty);
  });

  for (final MapEntry(key: locale, value: judging)
      in _judgingByLocale.entries) {
    test('no $locale string judges the user', () {
      final arb =
          jsonDecode(
                File('lib/core/l10n/arb/app_$locale.arb').readAsStringSync(),
              )
              as Map<String, Object?>;
      final offending = [
        for (final MapEntry(:key, :value) in arb.entries)
          if (!key.startsWith('@') &&
              value is String &&
              !_allowed.contains(key) &&
              judging.hasMatch(_withoutPlaceholders(value)))
            '$key: $value',
      ];
      expect(offending, isEmpty);
    });
  }

  // The store listings speak for the app too (docs/store, M8.6).
  for (final locale in storeLocales) {
    test('the $locale store listing judges no one', () {
      final judging = _judgingByLocale[locale] ?? _judging;
      final offending = [
        for (final MapEntry(:key, :value) in readListing(locale).entries)
          if (judging.hasMatch(value) || _judging.hasMatch(value)) key,
      ];
      expect(offending, isEmpty);
    });
  }

  test('the exception list only names strings that exist', () {
    final arb = File('lib/core/l10n/arb/app_en.arb').readAsStringSync();
    for (final key in _allowed) {
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
