import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/drag_actions.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/sheet_tiles.dart';
import 'package:dottoday/features/timeline/widgets/when_move.dart';
import 'package:dottoday/shared/haptics/app_haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Done · +15 min · Shift · Move · Edit tiles; Minimal has its own
/// screen (`TaskMScreen`, ED-089).
class SheetActions extends ConsumerWidget {
  const SheetActions({required this.task, this.onEdit, super.key});

  final TaskView task;

  /// Opens the editor (M3b.4b wires it).
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final o = task.occurrence;
    final done = o.status == OccurrenceStatus.done;
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(undoServiceProvider);
    final doneTile = SheetTile(
      glyph: DotGlyphs.check,
      label: done ? l10n.sheetUndone : l10n.sheetDone,
      filled: !done,
      onTap: () => unawaited(markDone(context, ref, o)),
    );
    return Row(
      spacing: DotSpace.s,
      children: [
        for (final tile in <SheetTile>[
          doneTile,
          SheetTile(
            glyph: DotGlyphs.clock,
            label: l10n.sheetExtend,
            onTap: o.startUtc == null
                ? null
                : () async => reportUndoable(
                    messenger,
                    l10n,
                    undo,
                    await extendTask(ref, o),
                    message: (_) => l10n.sheetExtend,
                    tokenOf: (token) => token,
                  ),
          ),
          SheetTile(
            glyph: DotGlyphs.rollForward,
            label: l10n.sheetShift,
            onTap: shiftRestAction(context, ref, task),
          ),
          SheetTile(
            glyph: DotGlyphs.move,
            label: l10n.sheetMove,
            onTap: o.startUtc == null || o.pinned
                ? null
                : () => unawaited(pickMoveTask(context, ref, o)),
          ),
          SheetTile(
            glyph: DotGlyphs.edit,
            label: l10n.sheetEdit,
            onTap: onEdit,
          ),
        ])
          Expanded(child: tile),
      ],
    );
  }
}

/// The task's local date.
DateTime _dayOf(TaskView task) {
  final o = task.occurrence;
  final l = tz.TZDateTime.from(o.startUtc!, tz.getLocation(o.tzId));
  return DateTime(l.year, l.month, l.day);
}

/// Tomorrow at the same time, with Undo (as a week-strip drop); the
/// minimal task screen's Tomorrow (ED-089).
Future<void> moveToTomorrow(
  BuildContext context,
  WidgetRef ref,
  TaskView task,
) {
  final d = _dayOf(task);
  return _toDay(context, ref, task, DateTime(d.year, d.month, d.day + 1));
}

/// The same time on [date], with Undo.
Future<void> _toDay(
  BuildContext context,
  WidgetRef ref,
  TaskView task,
  DateTime date,
) async {
  final o = task.occurrence;
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final undo = ref.read(undoServiceProvider);
  final day = DateFormat.MMMMEEEEd(
    Localizations.localeOf(context).toLanguageTag(),
  ).format(date);
  final result = await moveToDay(ref, o.id, date);
  if (result case Ok(value: null)) return;
  reportUndoable(
    messenger,
    l10n,
    undo,
    result,
    message: (v) => l10n.snackMovedDay(v!.$1.title, day),
    tokenOf: (v) => v!.$2,
  );
}

/// Shift the rest (R-04): only for the live task running into the next.
/// Public: option D's Shift the rest tile too (ED-086).
VoidCallback? shiftRestAction(
  BuildContext context,
  WidgetRef ref,
  TaskView task,
) {
  final o = task.occurrence;
  final start = o.startUtc;
  if (start == null) return null;
  final now =
      ref.watch(minuteTickProvider).value ?? ref.watch(clockProvider).nowUtc();
  if (now.isBefore(start) || !now.isBefore(o.endUtc!)) return null;
  final l = tz.TZDateTime.from(start, tz.getLocation(o.tzId));
  final day = ref
      .watch(timelineDataProvider(DateTime(l.year, l.month, l.day)))
      .value;
  if (day == null) return null;
  final overrun = overrunOf(o, day.blocks);
  if (overrun <= 0) return null;
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final undo = ref.read(undoServiceProvider);
  return () async {
    if (rebalanceShiftRest(context, day.blocks, o, overrun)) return;
    reportUndoable(
      messenger,
      l10n,
      undo,
      await shiftRest(ref, day: day.blocks, live: o, overrunMinutes: overrun),
      message: (v) => l10n.snackShifted(v.$2.movedIds.length),
      tokenOf: (v) => v.$1,
    );
  };
}

/// Done, or not done again (the task sheet's Done tile, option D's tile and
/// circle, ED-086): the haptic, the write with the Done sound (docs/12
/// D4), and Undo.
Future<void> markDone(BuildContext context, WidgetRef ref, Occurrence o) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final undo = ref.read(undoServiceProvider);
  final done = o.status == OccurrenceStatus.done;
  AppHaptics.play(context, done ? HapticTick.light : HapticTick.success);
  reportUndoable(
    messenger,
    l10n,
    undo,
    await toggleDone(ref, o),
    message: (_) => done ? l10n.snackNotDone(o.title) : l10n.snackDone(o.title),
    tokenOf: (token) => token,
  );
}
