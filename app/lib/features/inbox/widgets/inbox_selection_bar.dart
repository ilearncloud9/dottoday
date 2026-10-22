import 'dart:async';

import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/inbox_plan.dart';
import 'package:dottoday/domain/scheduling/week_plan.dart';
import 'package:dottoday/features/inbox/state/inbox_selection.dart';
import 'package:dottoday/features/inbox/state/inbox_state.dart';
import 'package:dottoday/features/inbox/widgets/inbox_commands.dart';
import 'package:dottoday/shared/selection/selection_bar_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Inbox's selection bar (PRD F3, docs/09 M3f.9c; the M3b.7 bar):
/// Plan these (where each first fits this week), Colour, Delete. Each is
/// one write with Undo, and ends selecting.
class InboxSelectionBar extends ConsumerWidget {
  const InboxSelectionBar({
    required this.items,
    required this.today,
    required this.commands,
    super.key,
  });

  final List<Occurrence> items;
  final DateTime today;
  final InboxCommands commands;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final picked = ref.watch(inboxSelectionProvider);
    final rows = [...items.where((o) => picked.contains(o.id))];
    if (rows.isEmpty) return const SizedBox.shrink();
    final selection = ref.read(inboxSelectionProvider.notifier);
    // The bar is gone once selecting ends, so the actions keep the
    // container rather than this widget's ref.
    final container = ProviderScope.containerOf(context, listen: false);
    void then(Future<void> Function() action) => unawaited(() async {
      selection.clear();
      await action();
    }());
    return SelectionBarFrame(
      count: rows.length,
      onClose: selection.clear,
      actions: [
        (
          icon: DotIcon(DotGlyphs.week, color: t.colors.text),
          label: l10n.inboxPlanThese,
          onTap: () => then(() => _plan(container, rows)),
        ),
        (
          icon: const ColourSwatchIcon(),
          label: l10n.selectionColour,
          onTap: () => unawaited(() async {
            final colour = await showColourChoice(context);
            if (colour != null) then(() => commands.recolour(rows, colour));
          }()),
        ),
        (
          icon: DotIcon(DotGlyphs.trash, color: t.colors.text),
          label: l10n.selectionDelete,
          onTap: () => unawaited(() async {
            if (await confirmDeleteMany(context, rows.length)) {
              then(() => commands.trashMany(rows));
            }
          }()),
        ),
      ],
    );
  }

  /// Like Auto-plan, for the picked ones in the list's order.
  Future<void> _plan(ProviderContainer container, List<Occurrence> rows) async {
    // Listened, so the auto-dispose provider lives until it answers.
    final sub = container.listen(
      inboxWeekRoomsProvider(today).future,
      (_, _) {},
    );
    final List<DayRoom> rooms;
    try {
      rooms = await sub.read();
    } finally {
      sub.close();
    }
    final plan = autoPlan(rows, rooms);
    await commands.placeAll(plan.placed, left: plan.unplaced.length);
  }
}
