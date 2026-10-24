import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Asking for device calendars (docs/09 M7.1) needs the OS usage text, or
// iOS terminates the app at the prompt and Android never shows it.
void main() {
  test('iOS explains calendar access (iOS 17 full access and older)', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, contains('NSCalendarsFullAccessUsageDescription'));
    expect(plist, contains('NSCalendarsUsageDescription'));
  });

  test('Android declares the calendar permissions', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android.permission.READ_CALENDAR'));
    expect(manifest, contains('android.permission.WRITE_CALENDAR'));
  });
}
