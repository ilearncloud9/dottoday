import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/scheduling/energy_window.dart';
import 'package:dottoday/shared/learning/learned_line.dart';
import 'package:dottoday/shared/time/time_labels.dart';
import 'package:flutter/material.dart';

/// "you finish high-energy tasks best 9:00 – 11:00 AM" and, when the task
/// starts outside it, "Try 9:00 AM" (11 C4). The window is app-wide, not
/// per title, so it is explained on tap with no reset (docs/13 §6).
class AddEnergyHint extends StatelessWidget {
  const AddEnergyHint({
    required this.window,
    required this.text,
    required this.startMinute,
    required this.onStart,
    super.key,
  });

  final EnergyWindow window;

  /// Times on the draft's day, in its zone.
  final DayTimeText text;

  /// The draft's local start, minutes after midnight.
  final int startMinute;
  final ValueChanged<int> onStart;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final w = window;
    final from = w.startHour * 60;
    final inside = startMinute >= from && startMinute < from + w.hours * 60;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: DotSpace.s,
      children: [
        LearnedLine(
          text: l10n.addEnergyBest(text.range(from, w.hours * 60)),
          explanation: LearnedExplanation(
            why: l10n.learnEnergyBasedOn(w.completions),
          ),
          style: t.styles.rowMeta.copyWith(color: t.colors.muted),
        ),
        if (!inside)
          TextButton(
            onPressed: () => onStart(from),
            child: Text(l10n.addEnergyTry(text.at(from))),
          ),
      ],
    );
  }
}
