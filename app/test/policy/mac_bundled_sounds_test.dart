import 'dart:convert';
import 'dart:io';

import 'package:dottoday/data/notifications/alarm_sound.dart';
import 'package:flutter_test/flutter_test.dart';

// The sandboxed Mac app can't write its Library/Sounds (macOS links it to
// ~/Library/Sounds), so every notification sound must be a Resource of the
// macOS Runner target, or UNNotificationSound and the Sound picker find
// nothing there (found in M8.5). Fix: tool/xcode_add_sounds.rb.
void main() {
  test('every bundled sound is a macOS Runner resource', () {
    final pbxproj = File(
      'macos/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();
    for (final name in bundledSoundFiles) {
      expect(
        File('assets/sounds/$name').existsSync(),
        isTrue,
        reason: '$name is an asset',
      );
      expect(
        pbxproj,
        contains('/* $name in Resources */'),
        reason: '$name: run tool/xcode_add_sounds.rb',
      );
    }
  });

  // docs/12 §4: every catalogue sound's .caf is a Resource of both Apple
  // Runner targets, or UNNotificationSound(named:) falls back to the
  // default sound in silence. Fix: tool/xcode_add_sounds.rb.
  test('every catalogue .caf is an iOS and a macOS Runner resource', () {
    final manifest =
        jsonDecode(File('assets/sounds/manifest.json').readAsStringSync())
            as Map<String, Object?>;
    final files = [
      for (final s
          in (manifest['sounds']! as List).cast<Map<String, Object?>>())
        if (s['source'] != 'dottoday') '${s['file']}.caf',
    ];
    expect(files, isNotEmpty);
    for (final project in ['ios', 'macos']) {
      final pbxproj = File(
        '$project/Runner.xcodeproj/project.pbxproj',
      ).readAsStringSync();
      for (final name in files) {
        expect(File('ios/Runner/Sounds/$name').existsSync(), isTrue);
        expect(
          pbxproj,
          contains('/* $name in Resources */'),
          reason: '$project: $name — run tool/xcode_add_sounds.rb',
        );
      }
    }
  });
}
