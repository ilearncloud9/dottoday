/// The first-run steps (docs/10 §5.1, PRD F10; docs/14 §4). Only
/// [dayShape], [habits], [account] and [firstTask] ask for anything; every
/// one can be skipped. [layout] is step 0: a choice with a preselected
/// answer, so, like the permission prompt, it isn't counted as one.
enum OnboardingStep {
  welcome,
  layout,
  dayShape,
  habits,
  reminders,
  account,
  firstTask,
  done;

  /// Whether this step asks the user for something (PRD F10 allows at
  /// most three such screens per flow; the permission prompt doesn't
  /// count).
  bool get asksForInput =>
      const {dayShape, habits, account, firstTask}.contains(this);

  /// The full planner's flow: step 0, then the O1–O4 flow as before.
  static const fullFlow = [
    welcome,
    layout,
    dayShape,
    habits,
    reminders,
    account,
    done,
  ];

  /// Minimal's flow (docs/14 §4): step 0, then three steps — Wake Up and
  /// Wind Down, reminders with the test alarm, the first task.
  static const minimalFlow = [welcome, layout, dayShape, reminders, firstTask];

  /// The steps in order for the chosen layout.
  static List<OnboardingStep> flow({required bool minimal}) =>
      minimal ? minimalFlow : fullFlow;

  /// The step after this one in [flow]; the last stays. A step from the
  /// other flow (the layout changed) goes on from step 0's successor.
  ///
  /// ```dart
  /// OnboardingStep.dayShape.nextIn(minimal: true); // reminders
  /// ```
  OnboardingStep nextIn({required bool minimal}) {
    final steps = flow(minimal: minimal);
    final i = steps.indexOf(this);
    if (i < 0) return steps[steps.indexOf(layout) + 1];
    return steps[(i + 1).clamp(0, steps.length - 1)];
  }

  /// The step before this one in [flow]; [welcome] stays.
  OnboardingStep previousIn({required bool minimal}) {
    final steps = flow(minimal: minimal);
    final i = steps.indexOf(this);
    return i <= 0 ? welcome : steps[i - 1];
  }

  /// Whether this is the flow's last step (its primary action finishes).
  bool isLastIn({required bool minimal}) => flow(minimal: minimal).last == this;
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
