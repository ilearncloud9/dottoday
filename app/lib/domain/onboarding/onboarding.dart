/// The first-run steps (docs/10 §5.1, PRD F10). Only [dayShape], [habits]
/// and [account] ask for anything; every one can be skipped.
enum OnboardingStep {
  welcome,
  dayShape,
  habits,
  reminders,
  account,
  done;

  /// The step after this one; [done] stays.
  OnboardingStep get next => values[(index + 1).clamp(0, done.index)];

  /// The step before this one; [welcome] stays.
  OnboardingStep get previous => values[(index - 1).clamp(0, done.index)];
}

/// Where this device is in onboarding: [finished] once "Open today" (or
/// the last skip) is tapped; otherwise [step] is where it resumes, so a
/// flow killed half-way picks up there (docs/09 M4.8).
final class OnboardingProgress {
  const OnboardingProgress({
    required this.step,
    this.finished = false,
    this.returning = false,
  });

  static const start = OnboardingProgress(step: OnboardingStep.welcome);

  final OnboardingStep step;
  final bool finished;

  /// Came in through "I already have an account" (O1): O5 says "Welcome
  /// back" and leads with signing in.
  final bool returning;

  Map<String, Object> toJson() => {
    'step': step.name,
    'finished': finished,
    'returning': returning,
  };

  /// Reads what [toJson] wrote; anything unexpected starts over.
  static OnboardingProgress fromJson(Object? json) {
    if (json is! Map) return start;
    final step = OnboardingStep.values
        .where((s) => s.name == json['step'])
        .firstOrNull;
    return OnboardingProgress(
      step: step ?? OnboardingStep.welcome,
      finished: json['finished'] == true,
      returning: json['returning'] == true,
    );
  }
}
