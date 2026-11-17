import 'dart:io';

import 'package:dottoday/background_refresh.dart';
import 'package:flutter_test/flutter_test.dart';

// Android delivery guarantees stay inside Play policy (docs/09 M6.5.5,
// local-notifications-scheduler): exact alarms through USE_EXACT_ALARM on
// Android 13+ (a calendar app's own permission; owner, 2026-11-02) and the
// user-granted SCHEDULE_EXACT_ALARM on 12 and 12L only, the full-screen
// intent for loud dot-starts, battery settings opened rather than the
// restricted permission, and re-arm on clock/zone changes.
final _manifest = File(
  'android/app/src/main/AndroidManifest.xml',
).readAsStringSync();

void main() {
  test('permissions: exact alarms and the full-screen intent only', () {
    expect(_manifest, contains('android.permission.USE_EXACT_ALARM'));
    // Both declared without a cap would ask Play to review both; 13+ needs
    // only USE_EXACT_ALARM.
    expect(
      _manifest,
      matches(
        RegExp(
          r'android\.permission\.SCHEDULE_EXACT_ALARM"\s*'
          r'android:maxSdkVersion="32"',
        ),
      ),
    );
    expect(_manifest, contains('android.permission.USE_FULL_SCREEN_INTENT'));
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

  // No Android backup of app data (CR-160 I1, docs/06 §4): Auto Backup and
  // adb backup off, Android 12+ cloud backup and device transfer excluding
  // every domain, the legacy rules excluding everything too, and no build
  // type's manifest overriding them. A manifest test proves the declaration
  // only; the platform's behaviour is checked on a device.
  group('Android backup', () {
    const domains = [
      'root',
      'file',
      'database',
      'sharedpref',
      'external',
      'device_root',
      'device_file',
      'device_database',
      'device_sharedpref',
    ];

    String app() =>
        RegExp(r'<application[^>]*>').firstMatch(_manifest)!.group(0)!;

    test('the application turns backup off and names both rule files', () {
      expect(app(), contains('android:allowBackup="false"'));
      expect(app(), contains('android:fullBackupContent="@xml/backup_rules"'));
      expect(
        app(),
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
      expect(
        app(),
        contains(
          'tools:replace="android:allowBackup,android:fullBackupContent,'
          'android:dataExtractionRules"',
        ),
      );
    });

    test('Android 12+: cloud backup and device transfer exclude every '
        'domain, include nothing', () {
      final rules = File(
        'android/app/src/main/res/xml/data_extraction_rules.xml',
      ).readAsStringSync();
      expect(rules, isNot(contains('<include')));
      for (final section in ['cloud-backup', 'device-transfer']) {
        final body = RegExp(
          '<$section>([\\s\\S]*?)</$section>',
        ).firstMatch(rules)!.group(1)!;
        for (final d in domains) {
          expect(
            body,
            contains('<exclude domain="$d" path="." />'),
            reason: '$section $d',
          );
        }
      }
    });

    test('Android 11 and older: the legacy rules exclude every domain', () {
      final rules = File(
        'android/app/src/main/res/xml/backup_rules.xml',
      ).readAsStringSync();
      expect(rules, isNot(contains('<include')));
      for (final d in domains) {
        expect(rules, contains('<exclude domain="$d" path="." />'));
      }
    });

    test('no build type or flavor manifest turns backup back on', () {
      final manifests = Directory('android/app/src')
          .listSync()
          .whereType<Directory>()
          .map((d) => File('${d.path}/AndroidManifest.xml'))
          .where((f) => f.existsSync() && !f.path.contains('/main/'));
      expect(manifests, isNotEmpty);
      for (final f in manifests) {
        final text = f.readAsStringSync();
        expect(text, isNot(contains('allowBackup')), reason: f.path);
        expect(text, isNot(contains('BackupContent')), reason: f.path);
        expect(text, isNot(contains('dataExtractionRules')), reason: f.path);
      }
    });
  });
}
