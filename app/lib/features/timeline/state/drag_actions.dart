import 'package:dottoday/core/clock/clock_provider.dart';
import 'package:dottoday/core/failures/app_failure.dart';
import 'package:dottoday/core/failures/result.dart';
import 'package:dottoday/data/profile/profile_providers.dart';
import 'package:dottoday/data/repositories/repository_providers.dart';
import 'package:dottoday/data/trash/trash_providers.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/drag_math.dart';
import 'package:dottoday/domain/scheduling/move_with_followers.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:dottoday/domain/scheduling/unstick.dart';
import 'package:dottoday/domain/undo/undo_service.dart';
import 'package:dottoday/domain/writes/write_batch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;

/// Writes [changed] (already edited) through the undoable path, stamping
/// the edit time.
Future<Result<UndoToken, AppFailure>> _write(
  WidgetRef ref,
  Occurrence changed,
) {
  final row = changed.copyWith(updatedAt: ref.read(clockProvider).nowUtc());
  return ref
      .read(undoServiceProvider)
      .applyUndoable(WriteBatch(userId: row.userId, occurrences: [row]));
}

/// Moves [o] to start at [startUtc], keeping its length unless given
/// [durationMin] (an all-day task dropped on a time, or made all day).
/// Other tasks stay put; it may overlap them (ADR-0015).
Future<Result<UndoToken, AppFailure>> moveTask(
  WidgetRef ref,
  Occurrence o,
  DateTime startUtc, {
  int? durationMin,
}) => _write(
  ref,
  countMove(
    o,
    o.copyWith(startUtc: startUtc, durationMin: durationMin ?? o.durationMin),
  ),
);

/// Moves [o] to [startUtc] and lets the tasks after it follow ("Shift
/// later tasks" on, R-04); see `moveWithFollowers` for the pin and
/// calendar rules (R-17).
Future<Result<(UndoToken, ShiftReport), AppFailure>> moveWithFollowing(
  WidgetRef ref, {
  required List<Occurrence> day,
  required Occurrence o,
  required DateTime startUtc,
  required bool includeCalendar,
  Set<String> readOnlyIds = const {},
}) async {
  final result = const DaySchedulerService().moveWithFollowers(
    day,
    o.id,
    startUtc,
    includeCalendar: includeCalendar,
    readOnlyIds: readOnlyIds,
  );
  final now = ref.read(clockProvider).nowUtc();
  // Every task the drop moved counts a move (Unstick, M10.7).
  final changed = countMoves(day, [
    for (final id in result.report.movedIds)
      result.byId(id).copyWith(updatedAt: now),
  ]);
  final applied = await ref
      .read(undoServiceProvider)
      .applyUndoable(WriteBatch(userId: o.userId, occurrences: changed));
  return switch (applied) {
    Ok(:final value) => Ok((value, result.report)),
    Err(:final failure) => Err(failure),
  };
}

/// Moves task [id] onto [date] at the same wall time (drop on a week-strip
/// day, PRD F8). Returns the moved row with the token, or null when the
/// task is gone or can't move (pinned, untimed).
Future<Result<(Occurrence, UndoToken)?, AppFailure>> moveToDay(
  WidgetRef ref,
  String id,
  DateTime date,
) async {
  final profile = await ref.read(currentProfileProvider.future);
  final o = await ref
      .read(occurrenceRepositoryProvider)
      .findById(profile.id, id);
  final start = o?.startUtc;
  if (o == null || start == null || o.pinned) return const Ok(null);
  final zone = tz.getLocation(o.tzId);
  final moved = countMove(
    o,
    o.copyWith(startUtc: sameTimeOn(zone, start, date)),
  );
  final result = await _write(ref, moved);
  return switch (result) {
    Ok(:final value) => Ok((moved, value)),
    Err(:final failure) => Err(failure),
  };
}
