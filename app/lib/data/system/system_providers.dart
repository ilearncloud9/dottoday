import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'system_providers.g.dart';

/// Opens a link outside the app (mail composer for feedback). A port so
/// tests and previews never leave the app.
abstract interface class LinkLauncher {
  /// Whether the platform handled [uri]. [sameWindow] replaces the page on
  /// the web instead of opening a tab (connecting a calendar, M7.4).
  Future<bool> open(Uri uri, {bool sameWindow = false});
}

/// [LinkLauncher] over `url_launcher`.
final class UrlLinkLauncher implements LinkLauncher {
  const UrlLinkLauncher();

  @override
  Future<bool> open(Uri uri, {bool sameWindow = false}) =>
      launchUrl(uri, webOnlyWindowName: sameWindow ? '_self' : null);
}

@Riverpod(keepAlive: true)
LinkLauncher linkLauncher(Ref ref) => const UrlLinkLauncher();

/// "0.1.0 (1)" from the platform bundle (Settings › About).
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
}

/// "0.1.0": the marketing version alone, for What's new (M8.2).
@Riverpod(keepAlive: true)
Future<String> appVersionName(Ref ref) async =>
    (await PackageInfo.fromPlatform()).version;
