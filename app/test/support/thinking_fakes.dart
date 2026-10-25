import 'package:dottoday/domain/thinking/on_device_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';

/// The one fake every thinking backend runs through (docs/09 M10.1): a
/// scripted model answer per kind, or a throw, or silence.
class FakeThinkingTransport implements ThinkingTransport {
  FakeThinkingTransport({
    this.state = ThinkingAvailability.available,
    Map<ThinkingKind, String?>? answers,
    this.error,
    this.delay = Duration.zero,
  }) : answers = answers ?? {};

  ThinkingAvailability state;
  final Map<ThinkingKind, String?> answers;
  Object? error;
  Duration delay;
  final prompts = <ThinkingPrompt>[];

  @override
  Future<ThinkingAvailability> availability() async => state;

  @override
  Future<String?> generate(ThinkingPrompt prompt) async {
    prompts.add(prompt);
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (error != null) throw error!;
    return answers[prompt.kind];
  }
}

/// In-memory [ThinkingMemory] + [ThinkingJournal].
final class MemoryThinkingMemory implements ThinkingMemory, ThinkingJournal {
  final saved = <String, List<ProposedStep>>{};
  final lengths = <String, List<int>>{};
  final exchanges = <ThinkingExchange>[];

  @override
  Future<List<ProposedStep>?> savedBreakdown(String title) async =>
      saved[title.trim().toLowerCase()];

  @override
  Future<void> saveBreakdown(String title, List<ProposedStep> steps) async =>
      saved[title.trim().toLowerCase()] = steps;

  @override
  Future<List<int>> pastLengths(String title) async =>
      lengths[title.trim().toLowerCase()] ?? const [];

  @override
  Future<void> record(ThinkingExchange exchange) async =>
      exchanges.add(exchange);
}
