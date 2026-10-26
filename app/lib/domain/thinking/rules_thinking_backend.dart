import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/domain/quick_add/quick_add_lexicon.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/domain/scheduling/learning.dart';
import 'package:dottoday/domain/thinking/thinking_backend.dart';
import 'package:dottoday/domain/thinking/thinking_memory.dart';
import 'package:dottoday/domain/thinking/thinking_proposals.dart';

/// The path that always answers (ADR-0009 §2): the saved breakdown or an
/// empty three-step template, the user's usual length (`LearningIndex`), and
/// Quick Add's parser for pasted text (R-07). No model, nothing leaves the
/// device.
final class RulesThinkingBackend implements ThinkingBackend {
  const RulesThinkingBackend(
    this._memory, {
    required Future<LearningIndex> Function() learning,
    this.parser = const QuickAddParser(),
  }) : _learning = learning;

  final ThinkingMemory _memory;

  /// The one place a usual length comes from (docs/13 §2).
  final Future<LearningIndex> Function() _learning;
  final QuickAddParser parser;

  /// "Degrades to the saved list or an empty 3-step template" (11 B1).
  static const templateSteps = 3;

  @override
  ThinkingPath get path => ThinkingPath.rules;

  @override
  Future<ThinkingAvailability> availability() async =>
      ThinkingAvailability.available;

  @override
  Future<BreakdownProposal> breakDown(BreakdownRequest request) async {
    final saved = await _memory.savedBreakdown(request.title);
    if (saved != null && saved.isNotEmpty) {
      return BreakdownProposal(
        // The user's own list: all of it, as accepted (up to the sheet's cap).
        steps: saved.take(BreakdownRequest.maxSteps).toList(),
        origin: ThinkingOrigin.saved,
      );
    }
    final shares = splitLength(request.durationMin, templateSteps);
    return BreakdownProposal(
      steps: [
        for (var i = 0; i < templateSteps; i++)
          ProposedStep(title: '', durationMin: shares?[i]),
      ],
      origin: ThinkingOrigin.rules,
    );
  }

  @override
  Future<TextPlanProposal?> planFromText(TextPlanRequest request) async {
    final context = QuickAddContext(
      nowUtc: request.nowUtc,
      tzId: request.tzId,
      language:
          QuickAddLanguage.values.asNameMap()[request.language] ??
          QuickAddLanguage.en,
    );
    final drafts = switch (parser.parseMany(request.text, context)) {
      Ok(:final value) => value,
      Err() => null,
    };
    if (drafts == null) return null;
    final dots = [
      for (final d in drafts)
        if (d.title.isNotEmpty)
          ProposedDot(
            title: d.title,
            minuteOfDay: d.inbox ? null : d.minuteOfDay,
            durationMin: d.durationMin,
          ),
    ];
    return dots.isEmpty
        ? null
        : TextPlanProposal(dots: dots, origin: ThinkingOrigin.rules);
  }

  @override
  Future<DurationProposal?> suggestDuration(DurationRequest request) async {
    final learned = (await _learning()).forTask(title: request.title);
    final usual = learned.usualMinutes;
    return usual == null
        ? null
        : DurationProposal(
            minutes: usual,
            origin: ThinkingOrigin.history,
            samples: learned.samples,
          );
  }
}

/// [total] minutes shared over [parts] steps in whole 5-minute blocks, the
/// remainder on the last step; null without a total.
///
/// ```dart
/// splitLength(50, 3); // [15, 15, 20]
/// ```
List<int>? splitLength(int? total, int parts) {
  if (total == null || parts <= 0) return null;
  if (total < parts * 5) {
    final each = (total ~/ parts).clamp(1, 1440);
    return List.filled(parts, each);
  }
  final each = (total ~/ parts) ~/ 5 * 5;
  return [...List.filled(parts - 1, each), total - each * (parts - 1)];
}
