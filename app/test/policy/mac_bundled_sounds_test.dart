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
}
