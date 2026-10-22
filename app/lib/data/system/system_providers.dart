import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'system_providers.g.dart';

/// Opens a link outside the app (mail composer for feedback). A port so
/// tests and previews never leave the app.
abstract interface class LinkLauncher {
  /// Whether the platform handled [uri].
  Future<bool> open(Uri uri);
}

/// [LinkLauncher] over `url_launcher`.
final class UrlLinkLauncher implements LinkLauncher {
  const UrlLinkLauncher();

  @override
  Future<bool> open(Uri uri) => launchUrl(uri);
}

@Riverpod(keepAlive: true)
LinkLauncher linkLauncher(Ref ref) => const UrlLinkLauncher();

/// "0.1.0 (1)" from the platform bundle (Settings › About).
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
}
