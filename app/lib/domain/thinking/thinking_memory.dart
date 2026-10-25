import 'package:dottoday/domain/thinking/thinking_proposals.dart';

/// What the device remembers for the thinking features, all local only
/// (ADR-0009 §4): accepted breakdowns per title (11 B1 "My usual
/// breakdown") and how long tasks with a title took.
abstract interface class ThinkingMemory {
  /// The steps accepted last time for [title] (case and spacing ignored),
  /// or null.
  Future<List<ProposedStep>?> savedBreakdown(String title);

  /// Remembers [steps] as the usual breakdown of [title]; called by Accept
  /// only (M10.4), never by a backend.
  Future<void> saveBreakdown(String title, List<ProposedStep> steps);

  /// Minutes each past task named [title] took, newest first: the real
  /// length when both actual timestamps exist (B1), else the planned one.
  Future<List<int>> pastLengths(String title);
}

/// What was asked of a model and what came back, kept on this device so
/// the user's prompts never exist anywhere else (ADR-0009 §4).
final class ThinkingExchange {
  const ThinkingExchange({
    required this.kind,
    required this.prompt,
    required this.output,
    required this.atUtc,
  });

  /// `break_down`, `plan_from_text` or `suggest_duration`.
  final String kind;
  final String prompt;

  /// The model's raw text; null when it gave none (error or timeout).
  final String? output;
  final DateTime atUtc;
}

/// Where [ThinkingExchange]s go: a bounded local log (data layer).
abstract interface class ThinkingJournal {
  Future<void> record(ThinkingExchange exchange);
}
