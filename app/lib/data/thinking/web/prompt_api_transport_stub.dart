import 'package:dottoday/domain/thinking/on_device_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';

/// Off the web there is no Prompt API: always unavailable.
final class PromptApiTransport implements ThinkingTransport {
  const PromptApiTransport();

  @override
  Future<ThinkingAvailability> availability() async =>
      ThinkingAvailability.unavailable;

  @override
  Future<String?> generate(ThinkingPrompt prompt) async => null;
}
