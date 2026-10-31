import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/features/onboarding/steps/step_frame.dart';
import 'package:flutter/material.dart';

/// Minimal onboarding's last step (docs/14 §4 "first task"): says how
/// Add reads a line, then opens Today with minimal Add up, so the first
/// dot lands on the thread with the same one field used every day.
class FirstTaskStep extends StatelessWidget {
  const FirstTaskStep({required this.onAdd, super.key});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return StepFrame(
      title: l10n.onboardingFirstTaskTitle,
      body: l10n.onboardingFirstTaskBody,
      primary: l10n.onboardingFirstTaskAdd,
      onPrimary: onAdd,
    );
  }
}
