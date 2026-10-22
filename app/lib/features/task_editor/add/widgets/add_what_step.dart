import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/domain/suggestions/suggestion_service.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_title_field.dart';
import 'package:dottoday/features/task_editor/add/widgets/habit_list.dart';
import 'package:dottoday/shared/dot/colour_icon_block.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';

/// Most suggestions shown under the title (`A-ios-add-what` shows four).
const addSuggestionLimit = 4;

/// Add step 1 "What" (docs/10 §5.2 A1, `A-ios-add-what`): title with live
/// parsing, colour and icon, Suggestions from habits, Continue, and "Add to
/// Inbox instead".
class AddWhatStep extends StatelessWidget {
  const AddWhatStep({
    required this.state,
    required this.habits,
    required this.use24h,
    required this.onType,
    required this.onPickHabit,
    required this.onColor,
    required this.onIcon,
    required this.onSubmit,
    required this.onAnother,
    required this.onAddMany,
    required this.onContinue,
    required this.onInbox,
    super.key,
  });

  final AddFlowState state;

  /// All habits; the step shows the ones matching the title.
  final List<HabitSuggestion> habits;
  final bool use24h;
  final ValueChanged<String> onType;
  final ValueChanged<HabitSuggestion> onPickHabit;
  final ValueChanged<TaskColor> onColor;
  final ValueChanged<TaskIcon> onIcon;

  /// Enter in the title: add with what is known.
  final VoidCallback onSubmit;

  /// Shift+Enter: add and start the next.
  final VoidCallback onAnother;

  /// A pasted list confirmed.
  final VoidCallback onAddMany;
  final VoidCallback? onContinue;
  final VoidCallback? onInbox;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _fields(context)),
        // A pasted list is answered above first.
        if (QuickAddParser.lines(state.text).length > 1)
          const _Footer(onContinue: null, onInbox: null)
        else
          _Footer(onContinue: onContinue, onInbox: onInbox),
      ],
    );
  }

  Widget _fields(BuildContext context) {
    final draft = state.draft;
    final colour = TaskColor.fromKey(draft.color);
    final icon = TaskIcon.fromKey(draft.icon);
    final shown = const SuggestionService().shownFor(
      draft.title,
      habits,
      limit: addSuggestionLimit,
    );
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: DotSpace.page,
        vertical: DotSpace.l,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DotSpace.l,
          children: [
            TaskDot(
              color: colour,
              icon: icon,
              state: DotState.upcoming,
              label: draft.title,
              size: DotSize.addDot,
            ),
            Expanded(child: _title()),
          ],
        ),
        const SizedBox(height: DotSpace.xl),
        _look(colour, icon),
        if (shown.isNotEmpty) ...[
          const SizedBox(height: DotSpace.xl),
          HabitList(
            habits: shown,
            selected: draft.habit,
            use24h: use24h,
            onPick: onPickHabit,
          ),
        ],
      ],
    );
  }

  Widget _look(TaskColor colour, TaskIcon icon) => ColourIconBlock(
    color: colour,
    icon: icon,
    onColor: onColor,
    onIcon: onIcon,
    suggested: _quickIcons(habits),
  );

  Widget _title() => AddTitleField(
    text: state.text,
    typed: state.draft.typed,
    onChanged: onType,
    onSubmit: onSubmit,
    onAnother: onAnother,
    onAddMany: onAddMany,
  );

  /// Icons of the top habits, then the defaults, for the quick row.
  static List<TaskIcon> _quickIcons(List<HabitSuggestion> habits) => {
    for (final h in habits)
      if (TaskIcon.fromKey(h.iconKey).glyph != null)
        TaskIcon.fromKey(h.iconKey),
    TaskIcon.cart,
    TaskIcon.heart,
  }.toList();
}

/// Continue and "Add to Inbox instead", pinned under the fields.
class _Footer extends StatelessWidget {
  const _Footer({required this.onContinue, required this.onInbox});

  final VoidCallback? onContinue;
  final VoidCallback? onInbox;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DotSpace.page,
        DotSpace.s,
        DotSpace.page,
        DotSpace.l,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DotSpace.s,
        children: [
          FilledButton.icon(
            onPressed: onContinue,
            iconAlignment: IconAlignment.end,
            icon: DotIcon(
              DotGlyphs.arrowRight,
              color: onContinue == null ? t.colors.muted : t.colors.onAccent,
            ),
            label: Text(l10n.addContinue),
          ),
          TextButton(onPressed: onInbox, child: Text(l10n.addToInbox)),
        ],
      ),
    );
  }
}
