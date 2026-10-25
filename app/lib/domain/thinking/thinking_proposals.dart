/// What the thinking features hand back (11 §0 B4, ADR-0009). Every value
/// here is a *proposal*: nothing in this file is persisted, and only an
/// Accept in `ProposalSheet` (B3) turns one into rows.
library;

/// Which path produced a proposal. Shown as the origin chip ("On device",
/// "Your usual", B-ios-break-it-down.png) and logged as a code, never with
/// the text.
enum ThinkingOrigin {
  /// An on-device model: Apple Foundation Models, Gemini Nano or Chrome's
  /// built-in Prompt API.
  onDevice,

  /// The breakdown the user accepted last time for this title.
  saved,

  /// The user's own history (median lengths).
  history,

  /// The empty three-step template or a parsed list: no model, no history.
  rules,
}

/// One step of a proposed breakdown. [title] may be empty only in the
/// template, which the user fills in before Accept.
final class ProposedStep {
  const ProposedStep({required this.title, this.durationMin});

  final String title;

  /// Minutes, 1–1440 (the `subtasks.duration_min` check), or none.
  final int? durationMin;

  ProposedStep copyWith({String? title, int? durationMin}) => ProposedStep(
    title: title ?? this.title,
    durationMin: durationMin ?? this.durationMin,
  );

  @override
  bool operator ==(Object other) =>
      other is ProposedStep &&
      other.title == title &&
      other.durationMin == durationMin;

  @override
  int get hashCode => Object.hash(title, durationMin);

  @override
  String toString() => 'ProposedStep(${title.length} chars, $durationMin)';
}

/// "Break it down" (11 B1): ordered steps for one task or step.
final class BreakdownProposal {
  const BreakdownProposal({required this.steps, required this.origin});

  final List<ProposedStep> steps;
  final ThinkingOrigin origin;

  /// Sum of the steps that have a length; null when none has one.
  int? get totalMin {
    final lengths = [for (final s in steps) ?s.durationMin];
    return lengths.isEmpty ? null : lengths.fold<int>(0, (a, b) => a + b);
  }

  @override
  String toString() => 'BreakdownProposal(${steps.length}, ${origin.name})';
}

/// One dot proposed from free text (11 B4).
final class ProposedDot {
  const ProposedDot({required this.title, this.minuteOfDay, this.durationMin});

  final String title;

  /// Local start, minutes after midnight on the chosen day; null = Inbox.
  final int? minuteOfDay;

  /// Minutes, 5–1440 (the task duration check), or none.
  final int? durationMin;

  @override
  bool operator ==(Object other) =>
      other is ProposedDot &&
      other.title == title &&
      other.minuteOfDay == minuteOfDay &&
      other.durationMin == durationMin;

  @override
  int get hashCode => Object.hash(title, minuteOfDay, durationMin);

  @override
  String toString() => 'ProposedDot($minuteOfDay+$durationMin)';
}

/// Brain-dump to thread (11 B4): dots for the chosen day.
final class TextPlanProposal {
  const TextPlanProposal({required this.dots, required this.origin});

  final List<ProposedDot> dots;
  final ThinkingOrigin origin;

  @override
  String toString() => 'TextPlanProposal(${dots.length}, ${origin.name})';
}

/// A suggested length for a task.
final class DurationProposal {
  const DurationProposal({
    required this.minutes,
    required this.origin,
    this.samples = 0,
  });

  final int minutes;
  final ThinkingOrigin origin;

  /// How many past tasks the [ThinkingOrigin.history] median came from.
  final int samples;

  @override
  String toString() => 'DurationProposal($minutes, ${origin.name})';
}
