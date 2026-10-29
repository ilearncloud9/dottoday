import 'package:dottoday/domain/thinking/on_device_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:flutter/services.dart';

/// [ThinkingTransport] over `dottoday/thinking` (docs/09 M10.1): Apple
/// Foundation Models on iOS/macOS 26+ (`ThinkingBridge.swift`, guided
/// generation) and Gemini Nano through ML Kit GenAI on Android
/// (`ThinkingBridge.kt`). A platform without the handler reads as not
/// eligible, so the rules path answers.
final class ChannelThinkingTransport implements ThinkingTransport {
  const ChannelThinkingTransport([
    this._channel = const MethodChannel('dottoday/thinking'),
  ]);

  final MethodChannel _channel;

  @override
  Future<ThinkingAvailability> availability() async {
    try {
      return parseAvailability(
        await _channel.invokeMethod<String>('availability'),
      );
    } on MissingPluginException {
      return ThinkingAvailability.notEligible;
    }
  }

  @override
  Future<String?> generate(ThinkingPrompt prompt) =>
      _channel.invokeMethod<String>('generate', prompt.toWire());
}

/// The native sides' availability words (`ThinkingBridge.swift`,
/// `ThinkingBridge.kt`, the Prompt API; pinned by
/// `test/policy/thinking_wire_contract_test.dart`). Chrome's own
/// "unavailable" means the browser can't run the model; any other word
/// is [ThinkingAvailability.unknown].
ThinkingAvailability parseAvailability(String? value) => switch (value) {
  'available' => ThinkingAvailability.available,
  'downloadable' => ThinkingAvailability.downloadable,
  'downloading' => ThinkingAvailability.downloading,
  'not_enabled' => ThinkingAvailability.notEnabled,
  'not_eligible' || 'unavailable' => ThinkingAvailability.notEligible,
  _ => ThinkingAvailability.unknown,
};
