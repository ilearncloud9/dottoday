import 'package:dottoday/data/pwa/install_prompt_stub.dart'
    if (dart.library.js_interop) 'package:dottoday/data/pwa/install_prompt_web.dart'
    as platform;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'install_prompt.g.dart';

/// Whether the web app may offer to install itself (docs/07 Web "install
/// prompt after 2nd visit", M5.7); always false off the web.
@Riverpod(keepAlive: true)
Stream<bool> installAvailable(Ref ref) => platform.installAvailability();

/// Install and "not now" (M5.7).
abstract interface class InstallPrompt {
  /// Shows the browser's install dialog; true when the user installed.
  Future<bool> install();

  /// Never offer again in this browser.
  void dismiss();
}

final class BrowserInstallPrompt implements InstallPrompt {
  const BrowserInstallPrompt();

  @override
  Future<bool> install() => platform.promptInstall();

  @override
  void dismiss() => platform.dismissInstall();
}

@Riverpod(keepAlive: true)
InstallPrompt installPrompt(Ref ref) => const BrowserInstallPrompt();
