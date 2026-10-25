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
/// Today while tasks are picked. Escape or Back ends selecting; see
/// [announceSelection].
class SelectionBar extends ConsumerWidget {
  const SelectionBar({required this.today, super.key});

  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picked = ref.watch(taskSelectionProvider);
    final day = picked.day;
    if (day == null) return const SizedBox.shrink();
    final blocks = ref.watch(timelineDataProvider(day)).value?.blocks;
    final rows = [...?blocks?.where((o) => picked.ids.contains(o.id))];
    final commands = SelectionCommands(
      context: context,
      container: ProviderScope.containerOf(context),
      rows: rows,
      today: today,
      day: day,
    );
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return SelectionBarFrame(
      count: picked.ids.length,
      onClose: ref.read(taskSelectionProvider.notifier).clear,
      actions: [
        (
          icon: DotIcon(DotGlyphs.move, color: t.colors.text),
          label: l10n.selectionMove,
          onTap: commands.move,
        ),
        (
          icon: DotIcon(DotGlyphs.add, color: t.colors.text),
          label: l10n.selectionDuplicate,
          onTap: commands.duplicate,
        ),
        (
          icon: const ColourSwatchIcon(),
          label: l10n.selectionColour,
          onTap: commands.recolour,
        ),
        (
          icon: DotIcon(DotGlyphs.repeat, color: t.colors.text),
          label: l10n.routineSaveSelection,
          onTap: commands.saveAsRoutine,
        ),
        (
          icon: DotIcon(DotGlyphs.trash, color: t.colors.text),
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
