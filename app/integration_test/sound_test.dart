// The Sound picker's sounds reach the device's audio (docs/08 §6.2 M8.4d
// row, run in M8.5; docs/12 §4): after start-up has installed the
// first-party tones (Library/Sounds on iPhone, Resources on Mac, raw
// resources on Android), every catalogue sound — the four tones, the alarm
// and the bundled .caf/raw files — is played through the same
// `dottoday/sound` channel the picker uses, and the native side must accept
// it: on Apple platforms that means it found the file and made a system
// sound of it. A bad name must be refused, so a silent "success" can't pass.
// Prints SOUND_CHECK lines; whether it is heard (volume, silent switch)
// stays a manual row.
//
// Run through tool/device_tests.sh <platform> [device] sound, or
// `flutter test integration_test/sound_test.dart -d macos`.
import 'package:dottoday/bootstrap.dart';
import 'package:dottoday/data/notifications/sound_files.dart';
import 'package:dottoday/domain/notifications/sound_catalogue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'pass_onboarding.dart';

const _channel = MethodChannel('dottoday/sound');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('every catalogue sound plays on this device', (tester) async {
    final flutterOnError = FlutterError.onError;
    final platformOnError = PlatformDispatcher.instance.onError;
    await bootstrap();
    FlutterError.onError = flutterOnError;
    PlatformDispatcher.instance.onError = platformOnError;
    await passOnboarding(tester);

    for (final sound in soundCatalogue) {
      final file = appleSoundFile(sound);
      await _channel.invokeMethod<void>('play', file);
      debugPrint('SOUND_CHECK ${sound.id} played ($file)');
      // A short gap: this proves each file is found, not how it sounds.
      await tester.pump(const Duration(milliseconds: 300));
    }
    await expectLater(
      _channel.invokeMethod<void>('play', 'nope.mp3'),
      throwsA(isA<PlatformException>()),
    );
    debugPrint('SOUND_CHECK bad name refused');
    // Apple platforms answer no_sound when the file is missing, so the
    // successes above mean each one was found. Android plays raw
    // resources compiled into the APK and doesn't report a missing one.
    final apple = {TargetPlatform.iOS, TargetPlatform.macOS};
    if (apple.contains(defaultTargetPlatform)) {
      await expectLater(
        _channel.invokeMethod<void>('play', 'reminder_nope.wav'),
        throwsA(isA<PlatformException>()),
      );
      debugPrint('SOUND_CHECK missing file refused');
    }
  });
}
