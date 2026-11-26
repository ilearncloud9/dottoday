/// The approved onboarding (the "Dottoday Onboarding Prototype", ED-305,
/// ED-350; M20.11, ED-485): Hello → Your day → What fills your days? →
/// A nudge, in context → You're in. No Layout step: Less is offered later
/// (ED-350). Three required taps to your own Today.
enum OnboardingStep {
  hello,
  day,
  fills,
  nudge,
  today;

  /// Whether this step asks the user for something (PRD F10 allows at
  /// most three such screens; the notification ask doesn't count).
  bool get asksForInput => this == day || this == fills;

  /// The steps with the progress dots, 1 to 3 (`navHTML(i)`).
  static const counted = [day, fills, nudge];

  /// Where this step sits in the dots (1–3), or null without them.
  int? get dot {
    final i = counted.indexOf(this);
    return i < 0 ? null : i + 1;
  }

  /// The step after this one; the last stays.
  OnboardingStep get next => values[(index + 1).clamp(0, values.length - 1)];

  /// The step before this one; [hello] stays.
  OnboardingStep get previous => values[(index - 1).clamp(0, values.length)];

  /// Whether Back (and Esc) work here: the steps with the dots.
  bool get canGoBack => dot != null;
}

/// Where this device is in onboarding: [finished] once You're in is
/// reached; otherwise [step] is where it resumes, so a flow killed
/// half-way picks up there (docs/09 M4.8). [account] is the "I have an
/// account" path, shown over Hello.
final class OnboardingProgress {
  const OnboardingProgress({
    required this.step,
    this.finished = false,
    this.account = false,
  });

  static const start = OnboardingProgress(step: OnboardingStep.hello);

  final OnboardingStep step;
  final bool finished;
  final bool account;

  Map<String, Object> toJson() => {
    'step': step.name,
    'finished': finished,
    'account': account,
  };

  /// Reads what [toJson] wrote; anything unexpected (a step of the
  /// replaced flow, ED-485) starts over, unless it was finished.
  static OnboardingProgress fromJson(Object? json) {
    if (json is! Map) return start;
    final finished = json['finished'] == true;
    final step = OnboardingStep.values
        .where((s) => s.name == json['step'])
        .firstOrNull;
    if (step == null) return finished ? done : start;
    return OnboardingProgress(
      step: step,
      finished: finished,
      account: json['account'] == true,
    );
  }

  /// Finished: onboarding never shows again on this device.
  static const done = OnboardingProgress(
    step: OnboardingStep.today,
    finished: true,
  );
}
