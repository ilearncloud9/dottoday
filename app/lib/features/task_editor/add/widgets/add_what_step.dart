import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/quick_add/quick_add_draft.dart';
import 'package:dottoday/domain/quick_add/quick_add_parser.dart';
import 'package:dottoday/features/task_editor/add/state/add_flow.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_minimal_parts.dart';
import 'package:dottoday/features/task_editor/add/widgets/add_title_field.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:flutter/material.dart';

/// Minimal's Add (docs/14 §4; E-PhonesMinimal frames 3 and 6, M19.6
/// part 6d-2): "What and when" with live parsing (R-06), the when and
/// length chips, where it lands on the day, and Add. The iPhone's nav bar
/// (Cancel · New task · Add) with a filled field; Android's M3 sheet with
/// an outlined field, More options and Add at the foot. Several lines
/// open a plan first (B4). Full Add is Create task (M19.3).
class AddWhatStep extends StatelessWidget {
  const AddWhatStep({
    required this.state,
    required this.onType,
    required this.onRemoveToken,
    required this.onSubmit,
    required this.onAnother,
    required this.onAddMany,
    required this.onWhen,
    required this.onMore,
    required this.onCancel,
    this.whenLabel,
    this.lengthLabel = '',
    this.landsAt,
    super.key,
  });

  final AddFlowState state;
  final ValueChanged<String> onType;

  /// A chip's ×: its word stays as title text.
  final ValueChanged<QuickAddToken> onRemoveToken;

  /// Enter in the title, or Add: add with what is known.
  final VoidCallback onSubmit;

  /// Shift+Enter: add and start the next.
  final VoidCallback onAnother;

  /// A pasted list confirmed.
  final VoidCallback onAddMany;

  /// Either chip: the When step.
  final VoidCallback onWhen;

  /// More (options): the detailed Create task with this draft.
  final VoidCallback onMore;
  final VoidCallback onCancel;

  /// "Lands at …" with its strip; null until the day is known.
  final AddLandsAt? landsAt;

  /// The when chip ("At 11:30 AM") and the length chip.
  final String? whenLabel;
  final String lengthLabel;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final android = DotIdiom.of(context) == DotIdiom.material;
    final draft = state.draft;
    // A pasted list is answered by the field first (R-07).
    final many = QuickAddParser.lines(state.text).length > 1;
    final empty = state.text.trim().isEmpty;
    // A list waits for the field's answer ("Add 3 tasks?", R-07).
    final add = many || empty ? null : onSubmit;
    final dot = TaskDot(
      color: TaskColor.fromKey(draft.color),
      icon: TaskIcon.fromKey(draft.icon),
      state: DotState.upcoming,
      label: draft.title,
      size: DotTouch.android,
    );
    final field = AddTitleField(
      text: state.text,
      typed: draft.typed,
      onChanged: onType,
      onRemoveToken: onRemoveToken,
      onSubmit: onSubmit,
      onAnother: onAnother,
      onAddMany: onAddMany,
      // Manrope 600 20 on both phones (ED-206 7a).
      style: t.styles.lookTitle.copyWith(fontWeight: FontWeight.w600),
      decoration: android
          ? InputDecoration(
              labelText: l10n.addWhatAndWhen,
              helperText: l10n.addSeveralLinesShort,
              border: const OutlineInputBorder(),
              suffixIcon: empty
                  ? null
                  : IconButton(
                      tooltip: l10n.addClear,
                      onPressed: () => onType(''),
                      icon: DotIcon(DotGlyphs.close, color: t.colors.ink),
                    ),
            )
          : InputDecoration.collapsed(hintText: l10n.addWhatAndWhen),
      frame: android
          ? null
          : (f) => DecoratedBox(
              decoration: BoxDecoration(
                color: t.colors.sunk,
                borderRadius: BorderRadius.circular(DotRadii.tile),
              ),
              child: Padding(
                padding: const EdgeInsets.all(DotSpace.s),
                child: Row(
                  spacing: DotSpace.m,
                  children: [
                    dot,
                    Expanded(child: f),
                  ],
                ),
              ),
            ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AddMinimalHeader(android: android, onCancel: onCancel, onAdd: add),
        // A short form, built whole; it scrolls at large text.
        Flexible(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              DotSpace.page,
              DotSpace.xs,
              DotSpace.page,
              android ? DotSpace.m : DotSpace.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!android)
                  Padding(
                    padding: const EdgeInsets.only(bottom: DotSpace.s),
                    child: Text(l10n.addWhatAndWhen, style: t.styles.rowMeta),
                  ),
                field,
                // A list's when, length and landing would be one line's:
                // hidden until the list is answered.
                if (!many) ...[
                  const SizedBox(height: DotSpace.m),
                  AddQuickChips(
                    when: whenLabel,
                    length: lengthLabel,
                    onWhen: onWhen,
                    onMore: android ? null : onMore,
                  ),
                  if (landsAt case final l?) ...[
                    const SizedBox(height: DotSpace.m),
                    l,
                  ],
                ],
                if (!android) ...[
                  const SizedBox(height: DotSpace.m),
                  const AddManyHint(),
                ],
              ],
            ),
          ),
        ),
        // Android's More options · Add stay in view under the scrolling
        // form (M19.7: on a tablet in landscape the keyboard left 372
        // px and Add scrolled out of sight).
        if (android)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DotSpace.page,
              0,
              DotSpace.page,
              DotSpace.l,
            ),
            child: AddMinimalFoot(onMore: many ? null : onMore, onAdd: add),
          ),
      ],
    );
  }
}
