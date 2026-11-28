import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/selection_commands.dart';
import 'package:dottoday/shared/selection/selection_bar_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The multi-select bar (docs/03 §3.2, R-05): "3 selected", Move,
/// Duplicate, Colour, Save as routine (M11.4) and Delete, at the bottom of
/// Today and the hour grid while tasks are picked. Escape or Back ends
/// selecting; see [announceSelection].
class SelectionBar extends ConsumerWidget {
  const SelectionBar({required this.today, super.key});

  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picked = ref.watch(taskSelectionProvider);
    final days = picked.days.values.toSet().toList()..sort();
    if (days.isEmpty) return const SizedBox.shrink();
    // The grid may pick across its days (E-R2-6): each day's rows.
    final rows = [
      for (final d in days)
        ...?ref
            .watch(timelineDataProvider(d))
            .value
            ?.blocks
            .where((o) => picked.days[o.id] == d),
    ];
    final commands = SelectionCommands(
      context: context,
      container: ProviderScope.containerOf(context),
      rows: rows,
      today: today,
      day: days.first,
    );
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SelectionBarFrame(
      count: picked.ids.length,
      onClose: ref.read(taskSelectionProvider.notifier).clear,
      actions: [
        (
          icon: DotIcon(DotGlyphs.arrowRight, color: t.colors.ink),
          label: l10n.selectionMove,
          onTap: commands.move,
        ),
        (
          icon: DotIcon(DotGlyphs.duplicate, color: t.colors.ink),
          label: l10n.selectionDuplicate,
          onTap: commands.duplicate,
        ),
        (
          icon: const ColourSwatchIcon(),
          label: l10n.selectionColour,
          onTap: commands.recolour,
        ),
        (
          icon: DotIcon(
            DotGlyphs.repeat,
            color: picked.spansDays ? t.colors.tertiary : t.colors.ink,
          ),
          label: l10n.routineSaveSelection,
          // A routine is one day's order and gaps.
          onTap: picked.spansDays ? null : commands.saveAsRoutine,
        ),
        (
          icon: DotIcon(DotGlyphs.trash, color: t.colors.ink),
          label: l10n.selectionDelete,
          onTap: commands.delete,
        ),
      ],
    );
  }
}

/// Says the new count when it changes, from the first pick on (R-12).
/// Called by the screen, which outlives the bar.
void announceSelection(BuildContext context, Picked? before, Picked now) =>
    announceCount(context, before?.ids.length, now.ids.length);
