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
import 'package:dottoday/features/timeline/widgets/when_move.dart';
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
                  : () => unawaited(
                      then(() => pickMoveTask(context, ref, task.occurrence)),
                    ),
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
    // The tinted pill as drawn (E-Phones F3): the label at its start, the
    // chips at its end; they wrap under the label at large text.
    return Container(
      constraints: const BoxConstraints(minHeight: DotSize.extendPill),
      padding: const EdgeInsetsDirectional.fromSTEB(
        DotSpace.m + DotSpace.xxs,
        DotSpace.xs + DotSpace.xxs,
        DotSpace.xs + DotSpace.xxs,
        DotSpace.xs + DotSpace.xxs,
      ),
      decoration: BoxDecoration(
        color: t.colors.sunk,
        borderRadius: BorderRadius.circular(DotRadii.tile),
      ),
      // No alignment: the row gets the pill's full width, so the chips
      // can sit at its end.
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: DotSpace.s,
        runSpacing: DotSpace.xxs,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: DotSpace.m),
            child: Text(l10n.lateNudgeTitle, style: t.styles.cardTitle),
          ),
          Wrap(
            spacing: DotSpace.xs,
            children: [
              for (final m in _amounts)
                _ExtendChip(
                  text: l10n.runningLateBy(m),
                  label: l10n.inspectorExtendLabel(m),
                  onTap: () => unawaited(_extend(context, ref, m)),
                ),
            ],
          ),
        ],
      ),
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

/// One "+15 min": the drawn 44 pt pill in the accent's tint, inside the
/// 48 pt target every touch control keeps.
class _ExtendChip extends StatelessWidget {
  const _ExtendChip({
    required this.text,
    required this.label,
    required this.onTap,
  });

  final String text;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = DotTheme.of(context);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: DotTouch.android,
            minWidth: DotTouch.android,
          ),
          child: Center(
            widthFactor: 1,
            child: DecoratedBox(
              decoration: ShapeDecoration(
                color: t.colors.tonal,
                shape: const StadiumBorder(),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: DotTouch.min,
                  minWidth: DotTouch.min,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DotSpace.s + DotSpace.xxs,
                  ),
                  // Shrink-wrapped: a stretching child would fill the row.
                  child: Center(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: Text(
                      text,
                      style: t.styles.rowMeta.copyWith(
                        color: t.colors.accentText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
