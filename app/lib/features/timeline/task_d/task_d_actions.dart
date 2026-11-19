import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/editing/focus_task.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/sheet_actions.dart';
import 'package:dottoday/features/timeline/widgets/sheet_tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Option D's tiles (E-Phones "Task sheet (medium detent)", ED-086):
/// Done · Move · Shift the rest · Focus, then "Need more time?" +5 +15
/// +30 (ED-163) while the task runs. Each writes on its own, after the
/// draft is saved ([beforeWrite]), with Undo; Done with its sound.
class TaskDActions extends ConsumerWidget {
  const TaskDActions({
    required this.task,
    required this.draft,
    required this.beforeWrite,
    super.key,
  });

  final TaskView task;

  /// The draft as it stands: Done's label follows it.
  final Occurrence draft;

  /// Saves the draft first, so the editor never puts an older row back.
  final Future<bool> Function() beforeWrite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final o = task.occurrence;
    final done = draft.status == OccurrenceStatus.done;
    final shift = shiftRestAction(context, ref, task);
    Future<void> then(Future<void> Function() write) async {
      if (await beforeWrite() && context.mounted) await write();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DotSpace.m,
      children: [
        SheetTileGrid(
          tiles: [
            SheetTile(
              glyph: DotGlyphs.check,
              label: done ? l10n.sheetUndone : l10n.sheetDone,
              filled: !done,
              onTap: () => unawaited(
                then(() => markDone(context, ref, task.occurrence)),
              ),
            ),
            SheetTile(
              glyph: DotGlyphs.clock,
              label: l10n.sheetMove,
              onTap: o.startUtc == null || o.pinned
                  ? null
                  : () => unawaited(then(() => moveTask(context, ref, task))),
            ),
            SheetTile(
              glyph: DotGlyphs.rollForward,
              label: l10n.liveShiftRest,
              onTap: shift == null
                  ? null
                  : () => unawaited(then(() async => shift())),
            ),
            SheetTile(
              glyph: DotGlyphs.bolt,
              label: l10n.focusTitle,
              onTap: done
                  ? null
                  : () => unawaited(then(() async => openFocus(context, o.id))),
            ),
          ],
        ),
        if (_running(ref, o) && !done)
          NeedMoreTime(task: o, beforeWrite: beforeWrite),
      ],
    );
  }

  /// Under way now: Need more time? speaks only then (ED-162).
  static bool _running(WidgetRef ref, Occurrence o) {
    final start = o.startUtc;
    if (start == null) return false;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
    return !now.isBefore(start) && now.isBefore(o.endUtc!);
  }
}

/// "Need more time?" with three 44 pt chips, +5 +15 +30 (ED-163): each
/// extends the task once, in its own day, with Undo; the row wraps under
/// its label at large text.
class NeedMoreTime extends ConsumerWidget {
  const NeedMoreTime({
    required this.task,
    required this.beforeWrite,
    super.key,
  });

  final Occurrence task;
  final Future<bool> Function() beforeWrite;

  static const _amounts = [5, 15, 30];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = DotTheme.of(context);
    final l10n = context.l10n;
    return Wrap(
      spacing: DotSpace.s,
      runSpacing: DotSpace.xs,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(l10n.lateNudgeTitle, style: t.styles.body),
        for (final m in _amounts)
          Semantics(
            button: true,
            label: l10n.inspectorExtendLabel(m),
            excludeSemantics: true,
            child: ActionChip(
              label: Text(l10n.runningLateBy(m)),
              backgroundColor: t.colors.accentTint,
              side: BorderSide.none,
              shape: const StadiumBorder(),
              labelStyle: t.styles.rowMeta.copyWith(
                color: t.colors.accentText,
                fontWeight: FontWeight.w700,
              ),
              onPressed: () => unawaited(_extend(context, ref, m)),
            ),
          ),
      ],
    );
  }

  Future<void> _extend(BuildContext context, WidgetRef ref, int m) async {
    if (!await beforeWrite() || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final undo = ref.read(undoServiceProvider);
    reportUndoable(
      messenger,
      l10n,
      undo,
      await extendTask(ref, task, minutes: m),
      message: (_) => l10n.runningLateBy(m),
      tokenOf: (token) => token,
    );
  }
}
