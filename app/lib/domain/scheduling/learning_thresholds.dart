/// Every number that decides when learning speaks (docs/13 §2): one value,
/// injected through `learningThresholdsProvider`, so no widget or domain
/// function keeps a literal of its own.
///
/// ```dart
/// const LearningThresholds(taskMinSamples: 2).taskMinSamples; // 2
/// ```
final class LearningThresholds {
  const LearningThresholds({
    this.taskMinSamples = 4,
    this.window = 10,
    this.historyDays = 90,
    this.realityMinRuns = 10,
    this.stepMinSamples = 3,
    this.energyMinCompletions = 20,
    this.energyWindowHours = 2,
    this.insightFromMinutes = 15,
    this.tendencyFromMinutes = 5,
  });

  /// What ships.
  static const standard = LearningThresholds();

  /// Finished runs of a task (title or series) before its usual length and
  /// start offset show (11 C3).
  final int taskMinSamples;

  /// Most recent runs a median is taken over, per task and per step.
  final int window;

  /// How far back the learning history reads: ten runs of a weekly task fit.
  final int historyDays;

  /// Finished tasks app-wide with a real start and end before the Plan /
  /// Reality toggle appears (docs/13 §4.3).
  final int realityMinRuns;

  /// Finished runs of a step before a Focus timer uses its usual length
  /// (docs/13 §5).
  final int stepMinSamples;

  /// Finished high-energy tasks before energy suggestions can be on (11 C4).
  final int energyMinCompletions;

  /// Hours in the suggested energy window.
  final int energyWindowHours;

  /// The Reality insight strip shows only when the usual length is this
  /// far from the plan.
  final int insightFromMinutes;

  /// Smaller start offsets are noise, not a habit worth saying.
  final int tendencyFromMinutes;
}
