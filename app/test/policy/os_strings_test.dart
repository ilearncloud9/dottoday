import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// OS-rendered strings speak every app language (docs/09 M8.3b, R-13): the
// permission prompts iOS and macOS show come from Info.plist's
// *UsageDescription keys, translated per language in InfoPlist.strings; a
// key added to Info.plist fails CI until every language has it. Android 13+
// lists the same languages under the per-app language setting.

/// The app's languages besides English, from the ARB files (M8.3).
final _translations = [
  for (final f in Directory('lib/core/l10n/arb').listSync())
    if (RegExp(r'app_(\w+)\.arb$').firstMatch(f.path)?.group(1) case final lang?
        when lang != 'en')
      lang,
]..sort();

final _usageKey = RegExp(
  r'<key>(\w+UsageDescription)</key>\s*<string>([^<]*)</string>',
);
final _stringsLine = RegExp(
  r'^"(\w+)"\s*=\s*"((?:[^"\\]|\\.)*)";\s*$',
  multiLine: true,
);

/// Every target's Info.plist: `ios/<target>/Info.plist`,
/// `macos/<target>/Info.plist` (plugin symlinks and Pods are not ours).
List<File> _infoPlists() => [
  for (final root in ['ios', 'macos'])
    for (final dir in Directory(root).listSync().whereType<Directory>())
      if (File('${dir.path}/Info.plist') case final f when f.existsSync()) f,
];

Map<String, String> _usage(File plist) => {
  for (final m in _usageKey.allMatches(plist.readAsStringSync()))
    m.group(1)!: m.group(2)!,
};

Map<String, String> _strings(File file) => {
  for (final m in _stringsLine.allMatches(file.readAsStringSync()))
    m.group(1)!: m.group(2)!,
};

void main() {
  test('the languages come from the ARB files', () {
    expect(_translations, containsAll(['de', 'es', 'fr']));
  });

  for (final plist in _infoPlists()) {
    final usage = _usage(plist);
    if (usage.isEmpty) continue;
    final dir = plist.parent.path;
    group(plist.path, () {
      for (final lang in _translations) {
        test('$lang translates every usage description', () {
          final file = File('$dir/$lang.lproj/InfoPlist.strings');
          expect(file.existsSync(), isTrue, reason: file.path);
          final strings = _strings(file);
          expect(strings.keys.toSet(), usage.keys.toSet(), reason: file.path);
          for (final MapEntry(:key, :value) in strings.entries) {
            expect(value.trim(), isNotEmpty, reason: '${file.path} $key');
            expect(value, isNot(usage[key]), reason: '${file.path} $key');
          }
        });
      }

      test('the Xcode project bundles every language', () {
        final project = File(
          '${plist.parent.parent.path}/Runner.xcodeproj/project.pbxproj',
        ).readAsStringSync();
        final regions = RegExp(
          r'knownRegions = \(([^)]*)\)',
        ).firstMatch(project)!.group(1)!;
        for (final lang in _translations) {
          expect(project, contains('path = $lang.lproj/InfoPlist.strings;'));
          expect(regions, contains('$lang,'));
        }
        expect(project, contains('InfoPlist.strings in Resources'));
      });
    });
  }

  // App Intents titles, parameters and dialogs (docs/09 M9.2): iOS and
  // Siri show them, so they speak every app language too.
  group('ios/Shared Localizable.strings', () {
    final english = _strings(File('ios/Shared/en.lproj/Localizable.strings'));
    test('English has the intent strings', () {
      expect(english.keys, contains('intentAddTaskTitle'));
    });
    for (final lang in _translations) {
      test('$lang has every key, translated', () {
        final file = File('ios/Shared/$lang.lproj/Localizable.strings');
        final strings = _strings(file);
        expect(strings.keys.toSet(), english.keys.toSet(), reason: file.path);
        for (final MapEntry(:key, :value) in strings.entries) {
          expect(value.trim(), isNotEmpty, reason: '${file.path} $key');
        }
      });
    }
    test('the app and the widget extension bundle them', () {
      final project = File(
        'ios/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();
      expect(
        'Localizable.strings in Resources */ = {isa = PBXBuildFile'.allMatches(
          project,
        ),
        hasLength(2),
      );
      for (final lang in ['en', ..._translations]) {
        expect(project, contains('path = $lang.lproj/Localizable.strings;'));
      }
    });
  });

  test('Android 13+ offers every language per app', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android:localeConfig="@xml/locales_config"'));
    final config = File(
      'android/app/src/main/res/xml/locales_config.xml',
    ).readAsStringSync();
    final locales = RegExp(
      r'<locale android:name="(\w+)"/>',
    ).allMatches(config).map((m) => m.group(1)!).toList()..sort();
    expect(locales, (['en', ..._translations])..sort());
  });
}
