import 'dart:io';

import 'package:dottoday/background_refresh.dart';
import 'package:flutter_test/flutter_test.dart';

// Android delivery guarantees stay inside Play policy (docs/09 M6.5.5,
// local-notifications-scheduler): exact alarms only as the user-granted
// opt-in, the full-screen intent for loud dot-starts, battery settings
// opened rather than the restricted permission, and re-arm on clock/zone
// changes.
final _manifest = File(
  'android/app/src/main/AndroidManifest.xml',
).readAsStringSync();

void main() {
  test('permissions: SCHEDULE_EXACT_ALARM and full-screen intent only', () {
    expect(_manifest, contains('android.permission.SCHEDULE_EXACT_ALARM'));
    expect(_manifest, contains('android.permission.USE_FULL_SCREEN_INTENT'));
    expect(_manifest, isNot(contains('android.permission.USE_EXACT_ALARM')));
    expect(_manifest, isNot(contains('REQUEST_IGNORE_BATTERY_OPTIMIZATIONS')));
  });

  // Dictation (docs/09 M14.4, ADR-0014): the mic, and the on-device speech
  // service made visible on Android 11+.
  test('RECORD_AUDIO and the RecognitionService query', () {
    expect(_manifest, contains('android.permission.RECORD_AUDIO'));
    expect(_manifest, contains('android.speech.RecognitionService'));
  });

  // Only the Wake Up ringing screen shows over the lock screen (docs/15
  // W1b): the time and two buttons, never the task list.
  test('no task list over the lock screen', () {
    final activities = RegExp(
      r'<activity\b[^>]*>',
    ).allMatches(_manifest).map((m) => m[0]!).toList();
    final locked = activities.where(
      (a) => a.contains('showWhenLocked') || a.contains('turnScreenOn'),
    );
    expect(locked, hasLength(1));
    expect(locked.single, contains('.alarms.WakeUpAlarmActivity'));
    expect(locked.single, contains('android:exported="false"'));
  });

  test('clock and zone changes re-arm through the background task', () {
    expect(_manifest, contains('.alarms.TimeChangeReceiver'));
    expect(_manifest, contains('android.intent.action.TIMEZONE_CHANGED'));
    expect(_manifest, contains('android.intent.action.TIME_SET'));
    final receiver = File(
      'android/app/src/main/kotlin/app/dottoday/planner/alarms/'
      'TimeChangeReceiver.kt',
    ).readAsStringSync();
    expect(receiver, contains('const val TASK = "$rearmTask"'));
  });

  test('the alarm chime ships as a raw resource', () {
    expect(
      File('android/app/src/main/res/raw/dot_alarm.m4a').existsSync(),
      isTrue,
    );
  });
}
