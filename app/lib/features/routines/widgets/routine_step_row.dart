import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/layout/app_layout.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/routine.dart';
import 'package:dottoday/domain/icon_guess/icon_guess.dart';
import 'package:dottoday/domain/validation/field_rules.dart';
import 'package:dottoday/shared/dot/mini_ring.dart';
import 'package:dottoday/shared/duration/duration_chips.dart';
import 'package:dottoday/shared/menus/context_menu.dart';
import 'package:dottoday/shared/text/system_text_menu.dart';
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

  /// The steps back as items, offsets laid end to end with their gaps. A
  /// step still on the plain icon takes the one its name suggests
  /// ([guessIcon] in [language]); the step's colour stays the user's.
  static List<RoutineItem> toItems(
    List<RoutineStepDraft> steps, {
    required String language,
  }) {
    var at = 0;
    return [
      for (final (i, s) in steps.indexed)
        () {
          if (i > 0) at += s.gapMin;
          final item = RoutineItem(
            id: s.id,
            title: s.name.text,
            colorKey: s.color.key,
            iconKey: s.iconKey == TaskIcon.fallback.key
                ? guessIcon(s.name.text, language: language)?.iconKey ??
                      s.iconKey
                : s.iconKey,
            offsetMin: at,
            durationMin: s.durationMin,
          );
          at += s.durationMin;
          return item;
        }(),
    ];
  }
}

/// A step row (E-R2-22): the colour ring (tap for the next colour), name,
/// the length as a pill, and ↑ ↓ × on one line; the free time kept before
/// it on a line above. Large text or a narrow sheet puts the length and
/// the arrows on their own line, so the name keeps its width. Every
/// control is a ≥ 44 pt target with a label.
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
    final ring = Semantics(
      button: true,
      label: title,
      excludeSemantics: true,
      child: InkResponse(
        onTap: () {
          final next = (step.color.index + 1) % TaskColor.values.length;
          step.color = TaskColor.values[next];
          onChanged();
        },
        radius: DotTouch.min / 2,
        child: SizedBox.square(
          dimension: DotTouch.min,
          child: Center(
            child: MiniRing(color: step.color, size: DotSize.rowIcon),
          ),
        ),
      ),
    );
    final name = TextField(
      contextMenuBuilder: systemTextMenu,
      controller: step.name,
      maxLength: maxTitleLength,
      minLines: 1,
      maxLines: 3,
      style: t.styles.body,
      decoration: InputDecoration(
        hintText: l10n.routineStepHint,
        counterText: '',
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        isDense: true,
      ),
      onChanged: (_) => onChanged(),
    );
    final controls = [
      _Length(step: step, title: title, onChanged: onChanged),
      _Icon(DotGlyphs.arrowUp, l10n.routineMoveUp(title), onUp),
      _Icon(DotGlyphs.arrowDown, l10n.routineMoveDown(title), onDown),
      _Icon(DotGlyphs.close, l10n.routineRemoveStep(title), onRemove),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final stacked =
            box.maxWidth < DotSize.stepRowMin ||
            MediaQuery.textScalerOf(context).scale(1) > AppLayout.largeText;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                ring,
                Expanded(child: name),
                if (!stacked) ...controls,
              ],
            ),
            if (stacked)
              Row(
                children: [
                  const SizedBox(width: DotTouch.min),
                  controls.first,
                  const Spacer(),
                  ...controls.skip(1),
                ],
              ),
            if (!first && step.gapMin > 0)
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: DotTouch.min,
                  bottom: DotSpace.xs,
                ),
                child: Text(
                  l10n.routineGap(formatDurationShort(l10n, step.gapMin)),
                  style: t.styles.rowMeta.copyWith(color: t.colors.muted),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The length as a pill; the system menu on the Mac and iOS lists the
/// lengths offered (native pass).
class _Length extends StatelessWidget {
  const _Length({
    required this.step,
    required this.title,
    required this.onChanged,
  });

  final RoutineStepDraft step;
  final String title;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final lengths = {..._lengths, step.durationMin}.toList()..sort();
    return DotMenuButton<int>(
      tooltip: l10n.routineStepLength(title),
      entries: () => [
        for (final m in lengths)
          ContextMenuEntry(
            value: m,
            label: formatDurationShort(l10n, m),
            checked: m == step.durationMin,
          ),
      ],
      onSelected: (m) {
        step.durationMin = m;
        onChanged();
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: DotTouch.min),
        child: Center(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.colors.chip,
              borderRadius: BorderRadius.circular(DotRadii.pill),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DotSpace.s + DotSpace.xxs,
                vertical: DotSpace.xs,
              ),
              child: Text(
                formatDurationShort(l10n, step.durationMin),
                style: t.styles.rowMeta.copyWith(
                  color: t.colors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
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
      constraints: const BoxConstraints.tightFor(
        width: DotTouch.min,
        height: DotTouch.min,
      ),
      padding: EdgeInsets.zero,
      icon: DotIcon(
        glyph,
        color: onPressed == null ? t.colors.threadAhead : t.colors.muted,
        size: DotSize.rowIcon,
      ),
    );
  }
}
