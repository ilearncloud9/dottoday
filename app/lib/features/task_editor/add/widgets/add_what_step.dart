import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_minimal_parts.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_title_field.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';

/// Minimal's Add (docs/14 §4): the title with live parsing (R-06) and two
/// chips, when and how long, then Add and More (the When step). Full Add
/// is Create task on phones and the popover from medium width (M19.3).
class AddWhatStep extends StatelessWidget {
  const AddWhatStep({
    required this.state,
    required this.onType,
    required this.onRemoveToken,
    required this.onSubmit,
    required this.onAnother,
    required this.onAddMany,
    required this.onMore,
    this.whenLabel,
    this.lengthLabel = '',
    super.key,
  });

  final AddFlowState state;
  final ValueChanged<String> onType;

  /// A chip's ×: its word stays as title text.
  final ValueChanged<QuickAddToken> onRemoveToken;

  /// Enter in the title: add with what is known.
  final VoidCallback onSubmit;

  /// Shift+Enter: add and start the next.
  final VoidCallback onAnother;

  /// A pasted list confirmed.
  final VoidCallback onAddMany;

  /// More, and either chip: the When step.
  final VoidCallback onMore;

  /// The when chip ("At 11:30 AM") and the length chip.
  final String? whenLabel;
  final String lengthLabel;

  @override
  Widget build(BuildContext context) {
    final draft = state.draft;
    // A pasted list is answered above first.
    final many = QuickAddParser.lines(state.text).length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
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
                    color: TaskColor.fromKey(draft.color),
                    icon: TaskIcon.fromKey(draft.icon),
                    state: DotState.upcoming,
                    label: draft.title,
                    size: DotSize.addDot,
                  ),
                  Expanded(
                    child: AddTitleField(
                      text: state.text,
                      typed: draft.typed,
                      onChanged: onType,
                      onRemoveToken: onRemoveToken,
                      onSubmit: onSubmit,
                      onAnother: onAnother,
                      onAddMany: onAddMany,
                    ),
                  ),
                ],
              ),
              // A list's when and length would be one line's: hidden
              // until the list is answered.
              if (!many)
                AddQuickChips(
                  when: whenLabel,
                  length: lengthLabel,
                  onMore: onMore,
                ),
            ],
          ),
        ),
        AddMinimalFooter(
          onAdd: many ? null : onSubmit,
          onMore: many ? null : onMore,
        ),
      ],
    );
  }
}
