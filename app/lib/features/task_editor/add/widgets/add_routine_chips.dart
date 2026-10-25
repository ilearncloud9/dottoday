import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';

/// "ROUTINES" under Add's suggestions (11 C2 "Add › Suggestions"): the
/// routines whose name holds what is typed (all of them before typing);
/// a tap proposes that routine on the draft's day.
class AddRoutineChips extends StatelessWidget {
  const AddRoutineChips({
    required this.routines,
    required this.typed,
    required this.onPick,
    super.key,
  });

  final List<Routine> routines;
  final String typed;
  final ValueChanged<Routine> onPick;

  /// The routines shown for [typed].
  static List<Routine> matching(List<Routine> routines, String typed) {
    final key = normaliseTitle(typed);
    return [
      for (final r in routines)
        if (key.isEmpty || normaliseTitle(r.title).contains(key)) r,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final shown = matching(routines, typed);
    if (shown.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DotSpace.s,
      children: [
        Text(l10n.routinesSuggestions.toUpperCase(), style: t.styles.caption),
        Wrap(
          spacing: DotSpace.s,
          runSpacing: DotSpace.s,
          children: [
            for (final r in shown)
              Semantics(
                button: true,
                label: l10n.routineChipLabel(r.title),
                excludeSemantics: true,
                child: ActionChip(
                  shape: dotChipShape(context),
                  avatar: TaskDot(
                    color: TaskColor.fromKey(r.items.firstOrNull?.colorKey),
                    icon: TaskIcon.fromKey(r.items.firstOrNull?.iconKey),
                    state: DotState.upcoming,
                    label: r.title,
                    size: DotSize.pickerDot,
                  ),
                  label: Text(r.title),
                  onPressed: () => onPick(r),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
