import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/core/l10n/l10n.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/drag_math.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/features/timeline/state/drag_actions.dart';
import 'package:dottoday/features/timeline/widgets/day_actions.dart';
import 'package:dottoday/shared/dot/thread.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Drag for a day's [blocks] (docs/10 §6, R-05; resize is the task sheet's
/// duration since ADR-0015): drops snap to
/// [snapMinutes] on the wall clock in [zone]; each write has Undo.
/// [elsewhere] finds a task dragged in from another day (the Mac/web
/// spread's columns, M3e.1); it moves alone, without shifting this day.
/// [readOnlyIds] are the imported events a shift never carries (null while
/// unknown: then none moves); [includeCalendar] starts the "Calendar
/// events too" chip, shown only when the day has an event it could carry
/// (docs/09 M7.6).
ThreadDrag dayThreadDrag(
  BuildContext context,
  WidgetRef ref, {
  required List<Occurrence> blocks,
  required tz.Location zone,
  required int snapMinutes,
  required String Function(DateTime utc) timeText,
  ShiftFollowersPolicy shiftFollowers = ShiftFollowersPolicy.ask,
  bool includeCalendar = false,
  Set<String>? readOnlyIds,
  Occurrence? Function(String id)? elsewhere,
}) {
  final fixed = readOnlyIds;
  final carriable =
      fixed != null &&
      blocks.any(
        (o) =>
            o.source == OccurrenceSource.calendar &&
            movableBlock(o, true, fixed),
      );
  final d = _DayDrag(
    ref: ref,
    messenger: ScaffoldMessenger.of(context),
    l10n: context.l10n,
    blocks: blocks,
    zone: zone,
    snapMinutes: snapMinutes,
    timeText: timeText,
    readOnlyIds: fixed ?? const {},
    elsewhere: elsewhere,
  );
  return ThreadDrag(
    hintFor: d.hint,
    onDrop: d.drop,
    // "ask" offers the chip, off; "never" hides it (docs/03 §3.2).
    shiftByDefault: switch (shiftFollowers) {
      ShiftFollowersPolicy.always => true,
      ShiftFollowersPolicy.ask => false,
      ShiftFollowersPolicy.never => null,
    },
    calendarByDefault: carriable ? includeCalendar : null,
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
    required this.readOnlyIds,
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
  final Set<String> readOnlyIds;
  final Occurrence? Function(String id)? elsewhere;

  Occurrence? _own(String id) => blocks.where((o) => o.id == id).firstOrNull;

  Occurrence? _find(String id) => _own(id) ?? elsewhere?.call(id);

  DateTime? _start(String id, DropSpan span, double fraction) {
    final o = _find(id);
    if (o == null) return null;
    return dropStart(
      zone: zone,
      gapStartUtc: span.startUtc,
      gapMinutes: span.minutes,
      fraction: fraction,
      durationMin: o.durationMin,
      snapMinutes: snapMinutes,
      fit: span.fit,
    );
  }

  String? hint(String id, DropSpan? span, double fraction) {
    final start = span == null ? null : _start(id, span, fraction);
    return start == null ? null : l10n.dragDropAt(timeText(start));
  }

  Future<void> drop(
    String id,
    DropSpan span,
    double fraction,
    DropShift shift,
  ) async {
    final o = _find(id);
    final start = _start(id, span, fraction);
    if (o == null || start == null || start == o.startUtc) return;
    final time = timeText(start);
    if (!shift.followers || _own(id) == null) {
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
      includeCalendar: shift.calendar,
      readOnlyIds: readOnlyIds,
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
