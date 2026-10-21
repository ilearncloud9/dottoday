import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/features/timeline/state/task_selection.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/selection_commands.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The multi-select bar (docs/03 §3.2, R-05): "3 selected", Move,
/// Duplicate, Colour and Delete, at the bottom of Today while tasks are
/// picked. Escape or Back ends selecting; see [announceSelection].
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
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): ref
            .read(taskSelectionProvider.notifier)
            .clear,
      },
      child: Focus(
        autofocus: true,
        child: _Bar(count: picked.ids.length, commands: commands),
      ),
    );
  }
}

class _Bar extends ConsumerWidget {
  const _Bar({required this.count, required this.commands});

  final int count;
  final SelectionCommands commands;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(DotSpace.s),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.colors.raised,
          borderRadius: BorderRadius.circular(DotRadii.card),
          boxShadow: DotElevation.floating,
        ),
        child: Padding(
          padding: const EdgeInsets.all(DotSpace.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: l10n.selectionClose,
                    onPressed: ref.read(taskSelectionProvider.notifier).clear,
                    icon: DotIcon(DotGlyphs.close, color: t.colors.text),
                  ),
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        l10n.selectionCount(count),
                        style: t.styles.cardTitle,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _Action(
                    icon: DotIcon(DotGlyphs.move, color: t.colors.text),
                    label: l10n.selectionMove,
                    onTap: commands.move,
                  ),
                  _Action(
                    icon: DotIcon(DotGlyphs.add, color: t.colors.text),
                    label: l10n.selectionDuplicate,
                    onTap: commands.duplicate,
                  ),
                  _Action(
                    icon: const _Swatch(),
                    label: l10n.selectionColour,
                    onTap: commands.recolour,
                  ),
                  _Action(
                    icon: DotIcon(DotGlyphs.trash, color: t.colors.text),
                    label: l10n.selectionDelete,
                    onTap: commands.delete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, this.onTap});

  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DotRadii.card),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: DotTouch.android),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DotSpace.xs),
              child: Column(
                spacing: DotSpace.xxs,
                children: [
                  icon,
                  Text(
                    label,
                    style: t.styles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The Colour action's icon: a filled accent dot in a text-coloured ring.
class _Swatch extends StatelessWidget {
  const _Swatch();

  @override
  Widget build(BuildContext context) {
    final c = DotTheme.of(context).colors;
    // The size of the other actions' glyphs, so the labels line up.
    return SizedBox.square(
      dimension: DotSize.navIcon,
      child: Center(
        child: Container(
          width: DotSize.rowIcon,
          height: DotSize.rowIcon,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.accent,
            border: Border.all(color: c.text, width: DotSize.smallDotOutline),
          ),
        ),
      ),
    );
  }
}

/// Says the new count when it changes, from the first pick on (R-12).
/// Called by the screen, which outlives the bar.
void announceSelection(BuildContext context, Picked? before, Picked now) {
  if (now.ids.isEmpty || now.ids.length == before?.ids.length) return;
  unawaited(
    SemanticsService.sendAnnouncement(
      View.of(context),
      context.l10n.selectionCount(now.ids.length),
      Directionality.of(context),
    ),
  );
}
