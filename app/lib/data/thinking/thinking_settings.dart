import 'package:dottoday/domain/thinking/thinking_status.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'thinking_settings.g.dart';

/// Opens where the user turns the model on (docs/09 M14.2): on iPhone
/// only Dottoday's own page in Settings (all iOS allows; the Privacy copy
/// says so), on the Mac System Settings › Apple Intelligence & Siri.
/// False where there is no link; the copy then says where to go.
typedef ThinkingSettingsOpener = Future<bool> Function(ThinkingVendor vendor);

@Riverpod(keepAlive: true)
ThinkingSettingsOpener thinkingSettingsOpener(Ref ref) => (vendor) async {
  final url = switch (vendor) {
    ThinkingVendor.appleIos => 'app-settings:',
    ThinkingVendor.appleMac =>
      'x-apple.systempreferences:com.apple.Siri-Settings.extension',
    ThinkingVendor.google ||
    ThinkingVendor.chrome ||
    ThinkingVendor.none => null,
  };
  if (url == null) return false;
  return launchUrl(Uri.parse(url));
};
