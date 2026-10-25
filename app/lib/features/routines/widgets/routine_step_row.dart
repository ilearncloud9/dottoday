import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:flutter/material.dart';

/// Step lengths offered in the editor (minutes).
const _lengths = [5, 10, 15, 20, 30, 45, 60, 90, 120];

/// One step while a routine is edited: its name field, colour, length and
/// the free time kept before it ([gapMin], from the routine as saved).
final class RoutineStepDraft {
  RoutineStepDraft({
    required this.id,
    required String title,
    required this.color,
    required this.iconKey,
    required this.durationMin,
    required this.gapMin,
  }) : name = TextEditingController(text: title);

  /// A new step after the others, coloured by its position.
  factory RoutineStepDraft.blank(String id, int index) => RoutineStepDraft(
    id: id,
    title: '',
    color: TaskColor.values[index % TaskColor.values.length],
    iconKey: TaskIcon.fallback.key,
    durationMin: 15,
    gapMin: 0,
  );

  final String id;
  final TextEditingController name;
  TaskColor color;
  final String iconKey;
  int durationMin;
  final int gapMin;

  void dispose() => name.dispose();

  /// [items] in start order, each with the gap before it (overlaps: 0).
  static List<RoutineStepDraft> fromItems(List<RoutineItem> items) {
    final sorted = [...items]
      ..sort((a, b) => a.offsetMin.compareTo(b.offsetMin));
    var end = 0;
    return [
      for (final (i, item) in sorted.indexed)
        () {
          final gap = i == 0 || item.offsetMin < end ? 0 : item.offsetMin - end;
          end = item.offsetMin + item.durationMin;
          return RoutineStepDraft(
            id: item.id,
            title: item.title,
            color: TaskColor.fromKey(item.colorKey),
            iconKey: item.iconKey,
            durationMin: item.durationMin,
            gapMin: gap,
          );
        }(),
    ];
  }

  /// The steps back as items, offsets laid end to end with their gaps.
  static List<RoutineItem> toItems(List<RoutineStepDraft> steps) {
    var at = 0;
    return [
      for (final (i, s) in steps.indexed)
        () {
          if (i > 0) at += s.gapMin;
          final item = RoutineItem(
            id: s.id,
            title: s.name.text,
            colorKey: s.color.key,
            iconKey: s.iconKey,
            offsetMin: at,
            durationMin: s.durationMin,
          );
          at += s.durationMin;
          return item;
        }(),
    ];
  }
}

/// A step row: the colour dot (tap for the next colour), name, length,
/// and ↑ ↓ × — every control a ≥ 44 pt target with a label.
class RoutineStepRow extends StatelessWidget {
  const RoutineStepRow({
    required this.step,
    required this.first,
    required this.onChanged,
    this.onUp,
    this.onDown,
    this.onRemove,
    super.key,
  });

  final RoutineStepDraft step;
  final bool first;
  final VoidCallback onChanged;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final title = step.name.text.isEmpty
        ? l10n.routineStepHint
        : step.name.text;
    final lengths = {..._lengths, step.durationMin}.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!first && step.gapMin > 0)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: DotSpace.s),
            child: Text(
              l10n.routineGap(formatDurationShort(l10n, step.gapMin)),
              style: t.styles.rowMeta.copyWith(color: t.colors.muted),
            ),
          ),
        Row(
          children: [
            TaskDot(
              color: step.color,
              icon: TaskIcon.fromKey(step.iconKey),
              state: DotState.upcoming,
              label: title,
              size: DotSize.pickerDot,
              onTap: () {
                final next = (step.color.index + 1) % TaskColor.values.length;
                step.color = TaskColor.values[next];
                onChanged();
              },
            ),
            const SizedBox(width: DotSpace.s),
            Expanded(
              child: TextField(
                controller: step.name,
                maxLength: maxTitleLength,
                decoration: InputDecoration(
                  hintText: l10n.routineStepHint,
                  counterText: '',
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        ),
        // Length and order on their own line, so the name keeps its width.
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: DotSize.pickerDot + DotSpace.s,
          ),
          child: Row(
            children: [
              DropdownButton<int>(
                value: step.durationMin,
                underline: const SizedBox.shrink(),
                items: [
                  for (final m in lengths)
                    DropdownMenuItem(
                      value: m,
                      child: Text(formatDurationShort(l10n, m)),
                    ),
                ],
                onChanged: (m) {
                  if (m == null) return;
                  step.durationMin = m;
                  onChanged();
                },
              ),
              const Spacer(),
              _Icon(DotGlyphs.chevronUp, l10n.routineMoveUp(title), onUp),
              _Icon(DotGlyphs.chevronDown, l10n.routineMoveDown(title), onDown),
              _Icon(DotGlyphs.close, l10n.routineRemoveStep(title), onRemove),
            ],
          ),
        ),
      ],
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon(this.glyph, this.tooltip, this.onPressed);

  final DotGlyph glyph;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: DotIcon(
        glyph,
        color: onPressed == null ? t.colors.hairline : t.colors.text,
        size: DotSize.rowIcon,
      ),
    );
  }
}
