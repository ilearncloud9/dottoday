import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/clock/minute_tick.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/sheet_actions.dart';
import 'package:dottoday/features/timeline/widgets/shell_drops.dart';
import 'package:dottoday/shared/dot/task_dot.dart';
import 'package:dottoday/shared/dot/thread_day.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The minimal task screen's decisions (ED-089): Done, the one
/// prominent action; Tomorrow and Later under it; Need more time? +5 /
/// +15 / +30 while the task runs; More options (the full editor); and
/// Delete task, small and apart, with Undo. Tomorrow, Later and Delete
/// put the screen away ([onClose]).
class TaskMActions extends ConsumerWidget {
  const TaskMActions({
    required this.task,
    required this.onClose,
    required this.onMore,
    this.column = false,
    super.key,
  });

  final TaskView task;
  final VoidCallback onClose;
  final VoidCallback onMore;

  /// The Mac and web Day column's narrower layout.
  final bool column;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    final o = task.occurrence;
    final done = o.status == OccurrenceStatus.done;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    final live = dotStateOf(o, now) == DotState.live;
    final drops = ShellDrops(context, ref);
    void then(VoidCallback write) {
      write();
      onClose();
    }

    Widget quiet(DotGlyph glyph, String label, VoidCallback? onTap) =>
        FilledButton.icon(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            backgroundColor: t.colors.sunk,
            foregroundColor: t.colors.ink,
            minimumSize: const Size.fromHeight(DotTouch.android),
            padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
          ),
          icon: DotIcon(glyph, color: t.colors.ink, size: DotSize.rowIcon),
          label: Text(label),
        );
    final tomorrow = quiet(
      DotGlyphs.rollForward,
      l10n.sheetTomorrow,
      o.startUtc == null
          ? null
          : () => then(() => unawaited(moveToTomorrow(context, ref, task))),
    );
    final later = quiet(
      DotGlyphs.inbox,
      l10n.sheetLater,
      o.startUtc == null || o.pinned
          ? null
          : () => then(() => drops.toInbox(o.id)),
    );
    final large = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.s,
      children: [
        FilledButton.icon(
          onPressed: () => unawaited(markDone(context, ref, o)),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(DotSize.androidFab),
          ),
          icon: DotIcon(
            done ? DotGlyphs.undo : DotGlyphs.check,
            color: t.colors.onAccent,
          ),
          label: Text(done ? l10n.sheetUndone : l10n.sheetDone),
        ),
        // Side by side; one over the other at large text, so no word
        // breaks (200 %, CLAUDE.md §5).
        Flex(
          direction: large ? Axis.vertical : Axis.horizontal,
          crossAxisAlignment: large
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.center,
          spacing: DotSpace.s,
          children: [
            for (final b in [tomorrow, later]) large ? b : Expanded(child: b),
          ],
        ),
        if (live) _MoreTime(task: task, column: column),
        _MoreOptions(onTap: onMore),
        Center(
          child: TextButton.icon(
            onPressed: o.pinned ? null : () => then(() => drops.toTrash(o.id)),
            style: TextButton.styleFrom(foregroundColor: t.colors.secondary),
            icon: DotIcon(
              DotGlyphs.trash,
              color: t.colors.secondary,
              size: DotSize.rowIcon,
            ),
            label: Text(l10n.editorDelete),
          ),
        ),
      ],
    );
  }
}

/// "Need more time?" with +5 / +15 / +30 while the task runs (ED-089).
class _MoreTime extends ConsumerWidget {
  const _MoreTime({required this.task, required this.column});

  final TaskView task;
  final bool column;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    Future<void> add(int m) async {
      final messenger = ScaffoldMessenger.of(context);
      final undo = ref.read(undoServiceProvider);
      reportUndoable(
        messenger,
        l10n,
        undo,
        await extendTask(ref, task.occurrence, minutes: m),
        message: (_) => l10n.runningLateBy(m),
        tokenOf: (token) => token,
      );
    }

    final label = Text(
      l10n.lateNudgeTitle,
      style: t.styles.rowMeta.copyWith(
        color: t.colors.ink,
        fontWeight: FontWeight.w700,
      ),
    );
    final chips = [
      for (final m in const [5, 15, 30])
        FilledButton(
          onPressed: () => unawaited(add(m)),
          style: FilledButton.styleFrom(
            backgroundColor: t.colors.tonal,
            foregroundColor: t.colors.accentText,
            minimumSize: const Size(DotTouch.min, DotTouch.min),
            padding: const EdgeInsets.symmetric(horizontal: DotSpace.s),
            textStyle: t.styles.rowMeta.copyWith(fontWeight: FontWeight.w700),
          ),
          child: Text(l10n.runningLateBy(m)),
        ),
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.colors.sunk,
        borderRadius: BorderRadius.circular(DotRadii.sheetCardAndroid),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DotSpace.s),
        // One line on a phone; the label over the chips in the narrow
        // Day column (E-Minimal).
        child: column
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: DotSpace.xs,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: DotSpace.s,
                    ),
                    child: label,
                  ),
                  Wrap(spacing: DotSpace.xs, children: chips),
                ],
              )
            : Row(
                spacing: DotSpace.xs,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(
                        start: DotSpace.s,
                      ),
                      child: label,
                    ),
                  ),
                  ...chips,
                ],
              ),
      ),
    );
  }
}

/// More options: the full editor, "alerts, repeat, steps, notes, colour
/// and icon" (ED-089).
class _MoreOptions extends StatelessWidget {
  const _MoreOptions({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return MergeSemantics(
      child: Material(
        color: t.colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DotRadii.sheetCardAndroid),
          side: BorderSide(color: t.colors.hairline),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DotRadii.sheetCardAndroid),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DotSpace.m),
            child: Row(
              spacing: DotSpace.s,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.createMore, style: t.styles.cardTitle),
                      Text(l10n.taskMMoreHint, style: t.styles.rowMeta),
                    ],
                  ),
                ),
                DotIcon(
                  DotGlyphs.chevronRight,
                  color: t.colors.ink,
                  size: DotSize.rowIcon,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
