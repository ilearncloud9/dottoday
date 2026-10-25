import 'package:flutter/services.dart';

/// `dottoday/intents` (docs/09 M9.2): iOS says `queueChanged` when a widget,
/// control, Live Activity or Siri queued an action while the app runs
/// (ios/Runner/AppDelegate.swift); [onQueued] then drains at once.
/// Elsewhere nothing calls it.
void listenForQueuedIntents(
  Future<void> Function() onQueued, {
  MethodChannel channel = const MethodChannel('dottoday/intents'),
}) {
  channel.setMethodCallHandler((call) async {
    if (call.method == 'queueChanged') await onQueued();
  });
}
