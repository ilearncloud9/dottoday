import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Key parity (docs/09 M8.3, docs/03 §5, R-13): every language ships with
// every string. A key added to app_en.arb fails CI until de, fr and es
// carry it too — gen-l10n alone would silently fall back to English.

const _arbDir = 'lib/core/l10n/arb';
const _translations = ['de', 'fr', 'es'];

/// Strings that may read exactly as in English, per language. Anything
/// else identical to English is treated as untranslated. Add a key here
/// only when the English word is the right word in that language.
const _sameAsEnglish = {
  'de': {
    'routineSummary',
    'routineDropTitle',
    'routineName',
    'learnInsightOk',
    'realityMetaJoin',
    'realityPlan',
    'appTitle',
    'durationMinutes',
    'durationHoursMinutes',
    'colorMint',
    'colorIndigo',
    'iconCode',
    'iconTv',
    'syncOffline',
    'liveExtend',
    'sheetExtend',
    'settingsSnapValue',
    'settingsVersion',
    'changelogVersion',
    'runningLateBy',
    'editorEscKey',
    'accountName',
    'accountSync',
    'settingsSync',
    'syncTitle',
    'inAppAlertOk',
    'taskLinks',
  },
  'fr': {
    'routinesTitle',
    'routineSummary',
    'routineDropTitle',
    'learnInsightOk',
    'realityMetaJoin',
    'realityPlan',
    'appTitle',
    'durationMinutes',
    'durationHoursMinutes',
    'colorIndigo',
    'colorViolet',
    'colorRose',
    'iconCode',
    'iconTv',
    'iconDocument',
    'liveExtend',
    'sheetExtend',
    'editorNotes',
    'addSuggestions',
    'settingsSnapValue',
    'settingsAccent',
    'settingsVersion',
    'changelogVersion',
    'runningLateBy',
    'editorEscKey',
    'exportFormats',
    'lockAfterMinutes',
    'inAppAlertOk',
  },
  'es': {
    'routineSummary',
    'learnInsightOk',
    'realityMetaJoin',
    'realityPlan',
    'appTitle',
    'durationMinutes',
    'durationHoursMinutes',
    'colorCoral',
    'iconTv',
    'liveExtend',
    'sheetExtend',
    'settingsSnapValue',
    'runningLateBy',
    'editorEscKey',
    'inAppAlertOk',
    'testAlarmNo',
  },
};

Map<String, Object?> _arb(String locale) =>
    jsonDecode(File('$_arbDir/app_$locale.arb').readAsStringSync())
        as Map<String, Object?>;

/// Message keys (not `@@locale` or `@key` metadata) and their text.
Map<String, String> _messages(Map<String, Object?> arb) => {
  for (final MapEntry(:key, :value) in arb.entries)
    if (!key.startsWith('@')) key: value! as String,
};

/// Declared placeholder names of [key] in the English template.
Set<String> _declared(Map<String, Object?> en, String key) {
  final meta = en['@$key'] as Map<String, Object?>?;
  final placeholders = meta?['placeholders'] as Map<String, Object?>?;
  return placeholders?.keys.toSet() ?? const {};
}

/// `{name}` / `{name, plural|select, …}` references. A one-word case body
/// such as `=1{Tag}` is preceded by its selector, so it is not counted.
Set<String> _references(String message) => {
  for (final m in RegExp(r'(?<![\w=])\{(\w+)(?=[,}])').allMatches(message))
    m.group(1)!,
};

/// Case selectors of a select message (`morning`, `title`, `1`, `other`).
Set<String> _selectCases(String message) {
  final start = message.indexOf(', select,');
  if (start < 0) return const {};
  return {
    for (final m in RegExp(
      r'(?<=[\s,}])(=?\w+)\{',
    ).allMatches(message.substring(start)))
      m.group(1)!,
  };
}

bool _hasWords(String message) =>
    RegExp('[A-Za-z]{2}').hasMatch(message.replaceAll(RegExp(r'\{\w+'), ''));

void main() {
  final en = _arb('en');
  final enMessages = _messages(en);

  test('the ARB folder holds exactly en + the translations', () {
    final files = Directory(
      _arbDir,
    ).listSync().whereType<File>().map((f) => f.uri.pathSegments.last);
    expect(files.toSet(), {
      'app_en.arb',
      for (final l in _translations) 'app_$l.arb',
    });
  });

  test('iOS and macOS declare every language', () {
    // Without CFBundleLocalizations iOS reports only English to the app.
    for (final path in ['ios/Runner/Info.plist', 'macos/Runner/Info.plist']) {
      final plist = File(path).readAsStringSync();
      final start = plist.indexOf('<key>CFBundleLocalizations</key>');
      expect(start, isNot(-1), reason: path);
      final block = plist.substring(start, plist.indexOf('</array>', start));
      for (final l in ['en', ..._translations]) {
        expect(block, contains('<string>$l</string>'), reason: '$path $l');
      }
    }
  });

  for (final locale in _translations) {
    group(locale, () {
      final arb = _arb(locale);
      final messages = _messages(arb);

      test('declares its locale', () {
        expect(arb['@@locale'], locale);
      });

      test('has every English key and no others', () {
        final missing = enMessages.keys.toSet().difference(
          messages.keys.toSet(),
        );
        final extra = messages.keys.toSet().difference(enMessages.keys.toSet());
        expect(missing, isEmpty, reason: 'translate these in app_$locale.arb');
        expect(extra, isEmpty, reason: 'remove keys English no longer has');
      });

      test('keeps placeholders, select cases and line breaks', () {
        final problems = <String>[];
        for (final MapEntry(:key, value: source) in enMessages.entries) {
          final text = messages[key];
          if (text == null) continue;
          final declared = _declared(en, key);
          final used = _references(source);
          final got = _references(text);
          if (used.difference(got).isNotEmpty) {
            problems.add('$key drops ${used.difference(got)}');
          }
          if (got.difference(declared.union(used)).isNotEmpty) {
            problems.add('$key adds ${got.difference(declared.union(used))}');
          }
          if (!_selectCases(text).containsAll(_selectCases(source))) {
            problems.add('$key changes select cases');
          }
          if (source.contains(', plural,') != text.contains(', plural,')) {
            problems.add('$key changes plural form');
          }
          if ('\n'.allMatches(source).length != '\n'.allMatches(text).length) {
            problems.add('$key changes line count');
          }
          if (text.trim().isEmpty && source.trim().isNotEmpty) {
            problems.add('$key is empty');
          }
        }
        expect(problems, isEmpty);
      });

      test('is translated (identical to English only when listed)', () {
        final allowed = _sameAsEnglish[locale]!;
        final copied = [
          for (final MapEntry(:key, value: source) in enMessages.entries)
            if (messages[key] == source &&
                _hasWords(source) &&
                !allowed.contains(key))
              key,
        ];
        expect(copied, isEmpty);
        expect(allowed.difference(enMessages.keys.toSet()), isEmpty);
      });
    });
  }
}
