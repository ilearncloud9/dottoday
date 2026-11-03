import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/schedule/planned_colors.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/drag_actions.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/sheet_tiles.dart';
import 'package:dottoday/features/timeline/widgets/shell_drops.dart';
import 'package:dottoday/shared/haptics/app_haptics.dart';
import 'package:dottoday/shared/pickers/day_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

/// Done · +15 min · Shift · Move · Edit tiles; in the minimal layout
/// Done · Tomorrow · Later · Delete (docs/14 §4), the rest under More.
class SheetActions extends ConsumerWidget {
  const SheetActions({
    required this.task,
    this.onEdit,
    this.minimal = false,
    this.onClose,
    super.key,
  });

  final TaskView task;

  /// Minimal's four tiles: Tomorrow keeps the time, Later is the Inbox,
  /// Delete is Trash; each says so with Undo and closes the sheet.
  final bool minimal;

  /// How the sheet goes after Tomorrow / Later / Delete: the route pops,
  /// unless the Mac/web panel closes itself (M16).
  final VoidCallback? onClose;

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
      onTap: () async {
        AppHaptics.play(context, HapticTick.light);
        reportUndoable(
          messenger,
          l10n,
          undo,
          await toggleDone(ref, o),
          message: (_) =>
              done ? l10n.snackNotDone(o.title) : l10n.snackDone(o.title),
          tokenOf: (token) => token,
        );
      },
    );
    if (minimal) {
      final drops = ShellDrops(context, ref);
      final navigator = Navigator.of(context);
      void then(void Function() write) {
        write();
        if (onClose case final close?) return close();
        unawaited(navigator.maybePop());
      }

      return SheetTileGrid(
        tiles: [
          doneTile,
          SheetTile(
            glyph: DotGlyphs.rollForward,
            label: l10n.sheetTomorrow,
            onTap: o.startUtc == null
                ? null
                : () => then(() => unawaited(_tomorrow(context, ref))),
          ),
          SheetTile(
            glyph: DotGlyphs.inbox,
            label: l10n.sheetLater,
            onTap: o.startUtc == null || o.pinned
                ? null
                : () => then(() => drops.toInbox(o.id)),
          ),
          SheetTile(
            glyph: DotGlyphs.trash,
            label: l10n.sheetDelete,
            onTap: o.pinned ? null : () => then(() => drops.toTrash(o.id)),
          ),
        ],
      );
    }
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
            onTap: _shift(context, ref),
          ),
          SheetTile(
            glyph: DotGlyphs.move,
            label: l10n.sheetMove,
            onTap: o.startUtc == null || o.pinned
                ? null
                : () => unawaited(_move(context, ref)),
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

  /// The task's local date.
  DateTime get _day {
    final o = task.occurrence;
    final l = tz.TZDateTime.from(o.startUtc!, tz.getLocation(o.tzId));
    return DateTime(l.year, l.month, l.day);
  }

  /// Tomorrow at the same time, with Undo (as a week-strip drop).
  Future<void> _tomorrow(BuildContext context, WidgetRef ref) {
    final d = _day;
    return _toDay(context, ref, DateTime(d.year, d.month, d.day + 1));
  }

  /// Move (docs/03 §3.2 "Move (to a day, same times; pinned stay)"): the
  /// change-day month the selection bar's Move uses, then the same time on
  /// the picked day, with Undo.
  Future<void> _move(BuildContext context, WidgetRef ref) async {
    final container = ProviderScope.containerOf(context);
    final from = _day;
    final to = await showMonthDayPicker(
      context,
      plannedFor: (m) => plannedColors(container, m),
      firstDayOfWeek:
          ref.read(currentProfileProvider).value?.settings.firstDayOfWeek ?? 1,
      title: context.l10n.selectionMoveTitle,
      today: ref.read(todayDateProvider).value ?? from,
      initial: from,
    );
    if (to == null || to == from || !context.mounted) return;
    await _toDay(context, ref, to);
  }

  /// The same time on [date], with Undo.
  Future<void> _toDay(
    BuildContext context,
    WidgetRef ref,
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
  VoidCallback? _shift(BuildContext context, WidgetRef ref) {
    final o = task.occurrence;
    final start = o.startUtc;
    if (start == null) return null;
    final now =
        ref.watch(minuteTickProvider).value ??
        ref.watch(clockProvider).nowUtc();
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
}
