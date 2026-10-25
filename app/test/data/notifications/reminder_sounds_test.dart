import 'dart:io';

import 'package:dottoday/data/notifications/alarm_sound.dart';
import 'package:dottoday/data/notifications/notification_platform.dart';
import 'package:dottoday/domain/notifications/reminder_sound.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../tool/gen_sounds.dart' as gen;

// The bundled reminder sounds (docs/02 F6.6, M8.4d): made by
// tool/gen_sounds.dart, present for every target, short enough for iOS.
void main() {
  test('every sound has a generator entry and nothing else does', () {
    expect(
      gen.sounds.keys.toSet(),
      ReminderSound.values.map((s) => s.name).toSet(),
    );
  });

  for (final sound in ReminderSound.values) {
    test('${sound.name}: asset and Android raw match the generator', () {
      final expected = gen.renderWav(gen.sounds[sound.name]!);
      final name = reminderSoundFile(sound);
      for (final path in [
        'assets/sounds/$name',
        'android/app/src/main/res/raw/$name',
      ]) {
        final bytes = File(path).readAsBytesSync();
        expect(bytes, expected, reason: '$path is stale: run the generator');
        expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
      }
      // iOS plays at most 30 s; these are under 2 s.
      expect(expected.length, lessThan(2 * gen.sampleRate * 2 + 44));
    });
  }

  test('Android keeps them through resource shrinking', () {
    final keep = File(
      'android/app/src/main/res/raw/keep.xml',
    ).readAsStringSync();
    expect(keep, contains('@raw/reminder_*'));
    expect(keep, contains('@raw/dot_alarm'));
  });

  test('Apple platforms install the chime and every reminder sound', () {
    expect(bundledSoundFiles, [
      alarmSoundFile,
      for (final s in ReminderSound.values) 'reminder_${s.name}.wav',
    ]);
  });

  test('an unknown or missing key is the system sound', () {
    expect(ReminderSound.fromKey('bell'), ReminderSound.bell);
    expect(ReminderSound.fromKey('../../etc/passwd'), isNull);
    expect(ReminderSound.fromKey(null), isNull);
  });
}
