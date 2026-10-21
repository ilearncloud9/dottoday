import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_blocks.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';

/// Drag with "Shift later tasks" on (docs/03 §3.2, R-04, R-05, R-17).
extension MoveWithFollowers on DaySchedulerService {
  /// Moves [movedId] to start at [startUtc] and lets the tasks after it
  /// follow, under the same pinned and calendar rules as [shiftFollowers].
  ///
  /// When the drop keeps the task's place in the day, everything after it
  /// moves by the same amount, gaps kept ([shiftFollowers]). When it jumps
  /// past other tasks, there is no "same amount" that makes sense, so the
  /// tasks at the new place only make room for it ([InsertPolicy.bump]).
  ///
  /// ```dart
  /// // b 9:00–10:00 → 9:30; c at 10:30 follows to 11:00.
  /// scheduler.moveWithFollowers(day, 'b', nine30).report.movedIds; // [b, c]
  /// ```
  ScheduleResult moveWithFollowers(
    List<Occurrence> day,
    String movedId,
    DateTime startUtc, {
    bool includeCalendar = false,
  }) {
    final sorted = scheduledBlocks(day);
    final moved = sorted.firstWhere((o) => o.id == movedId);
    final from = moved.startUtc!;
    final crossed = sorted.any((o) {
      if (o.id == movedId) return false;
      final s = o.startUtc!;
      return startUtc.isAfter(from)
          ? s.isAfter(from) && s.isBefore(startUtc)
          : !s.isBefore(startUtc) && s.isBefore(from);
    });
    if (!crossed) {
      return shiftFollowers(
        sorted,
        movedId,
        startUtc.difference(from).inMinutes,
        includeCalendar: includeCalendar,
      );
    }
    final placed = moved.copyWith(startUtc: startUtc);
    final r = insert(
      sorted,
      placed,
      InsertPolicy.bump,
      includeCalendar: includeCalendar,
    );
    return ScheduleResult(
      r.day,
      ShiftReport(
        movedIds: [movedId, ...r.report.movedIds],
        blockedById: r.report.blockedById,
        skippedIds: r.report.skippedIds,
      ),
    );
  }
}
