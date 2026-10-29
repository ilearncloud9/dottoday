import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'mic_settings.g.dart';

/// Whether Dottoday shows its own words before the OS asks for the
/// microphone (D5): Android's dialog has no usage text of its own; iOS
/// and macOS show Info.plist's. Read here so widgets never check the
/// platform.
@Riverpod(keepAlive: true)
bool micNeedsRationale(Ref ref) =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Opens where the microphone is switched back on (M14.5): Dottoday's page
/// in iPhone Settings, Privacy & Security › Microphone on the Mac, the
/// app's details on Android. False where there is no link (the web).
typedef MicSettingsOpener = Future<bool> Function();

@Riverpod(keepAlive: true)
MicSettingsOpener micSettingsOpener(Ref ref) => () async {
  if (kIsWeb) return false;
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      return launchUrl(Uri.parse('app-settings:'));
    case TargetPlatform.macOS:
      return launchUrl(
        Uri.parse(
          'x-apple.systempreferences:'
          'com.apple.preference.security?Privacy_Microphone',
        ),
      );
    case TargetPlatform.android:
      try {
        return await const MethodChannel(
              'dottoday/speech',
            ).invokeMethod<bool>('openSettings') ??
            false;
      } on PlatformException {
        return false;
      } on MissingPluginException {
        return false;
      }
    case TargetPlatform.fuchsia ||
        TargetPlatform.linux ||
        TargetPlatform.windows:
      return false;
  }
};
