import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:dottoday/domain/thinking/on_device_thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/domain/thinking/thinking_prompts.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';

import '../domain/fixtures.dart';

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
  final exchanges = <ThinkingExchange>[];

  @override
  Future<List<ProposedStep>?> savedBreakdown(String title) async =>
      saved[title.trim().toLowerCase()];

  @override
  Future<void> saveBreakdown(String title, List<ProposedStep> steps) async =>
      saved[title.trim().toLowerCase()] = steps;

  @override
  Future<void> record(ThinkingExchange exchange) async =>
      exchanges.add(exchange);
}

/// Real lengths per title, as runs with actual timestamps, read through
/// the one derivation (`LearningIndex`, docs/13 §2): what B4's rules ask.
final class FakeLearning {
  final lengths = <String, List<int>>{};

  Future<LearningIndex> call() async {
    var n = 0;
    final start = DateTime.utc(2026, 10, 1, 9);
    return LearningIndex.from([
      for (final MapEntry(key: title, value: minutes) in lengths.entries)
        for (final m in minutes)
          occurrenceFixture().copyWith(
            id: 'learn-${n++}',
            title: title,
            actualStartUtc: start.add(Duration(days: n)),
            actualEndUtc: start.add(Duration(days: n, minutes: m)),
          ),
    ]);
  }
}
