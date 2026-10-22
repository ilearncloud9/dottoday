import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/drag_math.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/timeline/state/drag_actions.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Drag and resize for a day's [blocks] (docs/10 §6, R-05): drops snap to
/// [snapMinutes] on the wall clock in [zone]; each write has Undo.
/// [elsewhere] finds a task dragged in from another day (the Mac/web
/// spread's columns, M3e.1); it moves alone, without shifting this day.
ThreadDrag dayThreadDrag(
  BuildContext context,
  WidgetRef ref, {
  required List<Occurrence> blocks,
  required tz.Location zone,
  required int snapMinutes,
  required String Function(DateTime utc) timeText,
  ShiftFollowersPolicy shiftFollowers = ShiftFollowersPolicy.ask,
  bool includeCalendar = false,
  Occurrence? Function(String id)? elsewhere,
}) {
  final d = _DayDrag(
    ref: ref,
    messenger: ScaffoldMessenger.of(context),
    l10n: context.l10n,
    blocks: blocks,
    zone: zone,
    snapMinutes: snapMinutes,
    timeText: timeText,
    includeCalendar: includeCalendar,
    elsewhere: elsewhere,
  );
  return ThreadDrag(
    hintFor: d.hint,
    onDrop: d.drop,
    onResize: d.resize,
    // "ask" offers the chip, off; "never" hides it (docs/03 §3.2).
    shiftByDefault: switch (shiftFollowers) {
      ShiftFollowersPolicy.always => true,
      ShiftFollowersPolicy.ask => false,
      ShiftFollowersPolicy.never => null,
    },
  );
}

/// What [dayThreadDrag] needs, read once while the page is mounted.
final class _DayDrag {
  _DayDrag({
    required this.ref,
    required this.messenger,
    required this.l10n,
    required this.blocks,
    required this.zone,
    required this.snapMinutes,
    required this.timeText,
    required this.includeCalendar,
    this.elsewhere,
  }) : undo = ref.read(undoServiceProvider);

  final WidgetRef ref;
  final ScaffoldMessengerState messenger;
  final AppLocalizations l10n;
  final UndoService undo;
  final List<Occurrence> blocks;
  final tz.Location zone;
  final int snapMinutes;
  final String Function(DateTime utc) timeText;
  final bool includeCalendar;
  final Occurrence? Function(String id)? elsewhere;

  Occurrence? _own(String id) => blocks.where((o) => o.id == id).firstOrNull;

  Occurrence? _find(String id) => _own(id) ?? elsewhere?.call(id);

  DateTime? _start(String id, ThreadGap gap, double fraction) {
    final o = _find(id);
    final gapStart = gap.startUtc;
    if (o == null || gapStart == null) return null;
    return dropStart(
      zone: zone,
      gapStartUtc: gapStart,
      gapMinutes: gap.minutes,
      fraction: fraction,
      durationMin: o.durationMin,
      snapMinutes: snapMinutes,
    );
  }

  String? hint(String id, ThreadGap? gap, double fraction) {
    final start = gap == null ? null : _start(id, gap, fraction);
    return start == null ? null : l10n.dragDropAt(timeText(start));
  }

  Future<void> drop(
    String id,
    ThreadGap gap,
    double fraction,
    bool shift,
  ) async {
    final o = _find(id);
    final start = _start(id, gap, fraction);
    if (o == null || start == null || start == o.startUtc) return;
    final time = timeText(start);
    if (!shift || _own(id) == null) {
      return _report(
        await moveTask(ref, o, start),
        l10n.snackMoved(o.title, time),
      );
    }
    final result = await moveWithFollowing(
      ref,
      day: blocks,
      o: o,
      startUtc: start,
      includeCalendar: includeCalendar,
    );
    reportUndoable(
      messenger,
      l10n,
      undo,
      result,
      message: (v) => switch (v.$2.blockedById) {
        final pin? => l10n.snackMovedShiftedPartial(
          o.title,
          time,
          _find(pin)!.title,
        ),
        null => l10n.snackMovedShifted(o.title, time, v.$2.movedIds.length - 1),
      },
      tokenOf: (v) => v.$1,
    );
  }

  Future<void> resize(String id, int steps) async {
    final o = _find(id);
    if (o == null) return;
    final minutes = resizedDuration(
      o.durationMin,
      steps: steps,
      snapMinutes: snapMinutes,
    );
    if (minutes == o.durationMin) return;
    final end = o.startUtc!.add(Duration(minutes: minutes));
    _report(
      await resizeTask(ref, o, minutes),
      l10n.snackResized(o.title, timeText(end)),
    );
  }

  void _report(Result<UndoToken, AppFailure> result, String message) =>
      reportUndoable(
        messenger,
        l10n,
        undo,
        result,
        message: (_) => message,
        tokenOf: (t) => t,
      );
}
