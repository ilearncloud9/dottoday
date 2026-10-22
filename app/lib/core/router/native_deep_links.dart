import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// The channel the Apple runners queue opened links on (docs/09 M5.0).
///
/// Android passes a `dottoday://` link to the router as its initial route,
/// and iOS passes links to a running app the same way. Two cases need help:
/// the macOS embedder doesn't forward links at all, and on an iOS cold start
/// the engine's push can arrive before the router listens and is dropped.
/// So `macos/Runner/AppDelegate.swift` and `ios/Runner/SceneDelegate.swift`
/// keep those links until [listenForNativeDeepLinks] takes them.
const nativeDeepLinkChannel = MethodChannel('dottoday/deep_links');

/// Sends the links queued before launch finished to [router], then each
/// later one the runner sends (macOS only).
///
/// The router's redirect allow-lists them like any other location, so an
/// unknown or malformed link lands on Today (docs/06 §7).
Future<void> listenForNativeDeepLinks(
  GoRouter router, {
  MethodChannel channel = nativeDeepLinkChannel,
}) async {
  channel.setMethodCallHandler((call) async {
    if (call.method == 'open' && call.arguments is String) {
      router.go(call.arguments as String);
    }
  });
  final pending = await channel.invokeListMethod<String>('takePending');
  for (final link in pending ?? const <String>[]) {
    router.go(link);
  }
}
