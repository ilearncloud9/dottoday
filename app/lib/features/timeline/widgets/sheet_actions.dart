import 'dart:async';

import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/core/theme/dot_theme.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/features/timeline/state/block_actions.dart';
import 'package:dottoday/features/timeline/state/drag_actions.dart';
import 'package:dottoday/features/timeline/state/rebalance_flow.dart';
import 'package:dottoday/features/timeline/state/task_view.dart';
import 'package:dottoday/features/timeline/state/timeline_providers.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/features/timeline/widgets/shell_drops.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    super.key,
  });

  final TaskView task;

  /// Minimal's four tiles: Tomorrow keeps the time, Later is the Inbox,
  /// Delete is Trash; each says so with Undo and closes the sheet.
  final bool minimal;

  /// Opens the editor (M3b.4b wires it).
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final o = task.occurrence;
    final done = o.status == OccurrenceStatus.done;
    final messenger = ScaffoldMessenger.of(context);
    final undo = ref.read(undoServiceProvider);
    final doneTile = _Tile(
      glyph: DotGlyphs.check,
      label: done ? l10n.sheetUndone : l10n.sheetDone,
      filled: !done,
      onTap: () async {
        unawaited(HapticFeedback.lightImpact());
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
        unawaited(navigator.maybePop());
      }

      return Row(
        spacing: DotSpace.s,
        children: [
          doneTile,
          _Tile(
            glyph: DotGlyphs.rollForward,
            label: l10n.sheetTomorrow,
            onTap: o.startUtc == null
                ? null
                : () => then(() => unawaited(_tomorrow(context, ref))),
          ),
          _Tile(
            glyph: DotGlyphs.inbox,
            label: l10n.sheetLater,
            onTap: o.startUtc == null || o.pinned
                ? null
                : () => then(() => drops.toInbox(o.id)),
          ),
          _Tile(
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
        doneTile,
        _Tile(
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
        _Tile(
          glyph: DotGlyphs.rollForward,
          label: l10n.sheetShift,
          onTap: _shift(context, ref),
        ),
        _Tile(glyph: DotGlyphs.move, label: l10n.sheetMove),
        _Tile(glyph: DotGlyphs.edit, label: l10n.sheetEdit, onTap: onEdit),
      ],
    );
  }

  /// Tomorrow at the same time, with Undo (as a week-strip drop).
  Future<void> _tomorrow(BuildContext context, WidgetRef ref) async {
    final o = task.occurrence;
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final undo = ref.read(undoServiceProvider);
    final l = tz.TZDateTime.from(o.startUtc!, tz.getLocation(o.tzId));
    final date = DateTime(l.year, l.month, l.day + 1);
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

class _Tile extends StatelessWidget {
  const _Tile({
    required this.glyph,
    required this.label,
    this.onTap,
    this.filled = false,
  });

  final DotGlyph glyph;
  final String label;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    final c = t.colors;
    final enabled = onTap != null;
    final ink = filled ? c.onAccent : (enabled ? c.text : c.muted);
    return Expanded(
      child: Semantics(
        button: true,
        enabled: enabled,
        label: label,
        excludeSemantics: true,
        onTap: onTap,
        child: Material(
          color: filled ? c.accentFill : c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DotRadii.card),
            side: filled ? BorderSide.none : BorderSide(color: c.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: DotSize.rowDot * 2),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: DotSpace.s),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: DotSpace.xs,
                  children: [
                    DotIcon(glyph, color: ink, active: filled),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: t.styles.button.copyWith(color: ink),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
