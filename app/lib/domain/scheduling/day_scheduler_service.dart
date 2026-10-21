import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_blocks.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:dottoday/domain/scheduling/slot_finder.dart';

/// Pure day-rearranging operations behind drag, "Running late", insert and
/// gap suggestions (docs/04 §5, R-04, R-05, R-17).
///
/// Every method takes the day's blocks and returns new values; nothing is
/// persisted here. Inbox items (no start) and soft-deleted rows are ignored.
/// Invariants (property-tested): pinned blocks never move, relative order of
/// moved blocks is preserved, and gaps between shifted blocks are kept.
final class DaySchedulerService {
  const DaySchedulerService();

  /// Moves [movedId] by [deltaMin] and shifts every block after it by the
  /// same amount, preserving gaps.
  ///
  /// Calendar events stay put unless [includeCalendar]. Shifting stops at the
  /// first pinned block after the moved one, or earlier if a block would be
  /// pushed onto a pin, and the report is `partial`; the moved block itself
  /// moves even if pinned, because the user dragged it.
  ///
  /// ```dart
  /// scheduler.shiftFollowers(day, 'gym', 30).report.partial; // pinned hit?
  /// ```
  ScheduleResult shiftFollowers(
    List<Occurrence> day,
    String movedId,
    int deltaMin, {
    bool includeCalendar = false,
  }) {
    final sorted = scheduledBlocks(day);
    final index = sorted.indexWhere((o) => o.id == movedId);
    if (index < 0) throw ArgumentError.value(movedId, 'movedId', 'not in day');
    final delta = Duration(minutes: deltaMin);
    if (delta == Duration.zero) {
      return ScheduleResult(sorted, const ShiftReport());
    }
    // Moving earlier, followers must not land on a pin before the group.
    final floor = delta.isNegative
        ? sorted.take(index).where((o) => o.pinned).lastOrNull
        : null;
    final run = _shift(
      sorted.skip(index + 1),
      delta,
      includeCalendar: includeCalendar,
      stopAtPinned: true,
      floor: floor,
    );
    final moved = _moveBy(sorted[index], delta);
    return _apply(
        sorted,
        {moved.id: moved, ...run.changed},
        run.report,
        [
          moved.id,
        ]);
  }

  /// Pushes every planned block starting at or after [nowUtc] by [deltaMin]
  /// ("Running late +5/+15/+30", R-04), up to the first pinned block: a pin
  /// anchors the rest of the day, so the report is `partial` there (R-17).
  /// Done and skipped blocks and (unless [includeCalendar]) calendar events
  /// stay put.
  ScheduleResult runningLate(
    List<Occurrence> day,
    DateTime nowUtc,
    int deltaMin, {
    bool includeCalendar = false,
  }) {
    final sorted = scheduledBlocks(day);
    final run = _shift(
      sorted.where((o) => !o.startUtc!.isBefore(nowUtc)),
      Duration(minutes: deltaMin),
      includeCalendar: includeCalendar,
      stopAtPinned: true,
      skipFinished: true,
    );
    return _apply(sorted, run.changed, run.report);
  }

  /// Free slots for a [durationMin] task; see [findSlots] (docs/04 §5).
  List<Slot> suggestSlots(
    List<Occurrence> day,
    int durationMin, {
    required DateTime fromUtc,
    required DateTime dayStartUtc,
    required DateTime dayEndUtc,
    int snapMinutes = 5,
    int limit = 3,
  }) =>
      findSlots(
        day,
        durationMin,
        fromUtc: fromUtc,
        dayStartUtc: dayStartUtc,
        dayEndUtc: dayEndUtc,
        snapMinutes: snapMinutes,
        limit: limit,
      );

  /// Adds [block] to the day according to [policy] (docs/04 §5).
  ///
  /// `bump` pushes the blocks starting at or after [block] down just enough
  /// to clear it, with the same pinned/calendar rules as [shiftFollowers];
  /// it never moves blocks that started earlier. `fitNextGap` keeps every
  /// other block and moves [block] to the first gap that fits it, counting
  /// travel buffers as busy time.
  ScheduleResult insert(
    List<Occurrence> day,
    Occurrence block,
    InsertPolicy policy, {
    bool includeCalendar = false,
  }) {
    final others = scheduledBlocks(day.where((o) => o.id != block.id));
    final start = block.startUtc;
    if (start == null) throw ArgumentError.value(block.id, 'block', 'no start');
    switch (policy) {
      case InsertPolicy.overlap:
        return _apply([...others, block], const {}, const ShiftReport());
      case InsertPolicy.fitNextGap:
        final placed = block.copyWith(startUtc: _firstFit(others, block));
        return _apply([...others, placed], const {}, const ShiftReport());
      case InsertPolicy.bump:
        return _bump(others, block, includeCalendar);
    }
  }

  ScheduleResult _bump(
    List<Occurrence> others,
    Occurrence block,
    bool includeCalendar,
  ) {
    final followers =
        others.where((o) => !o.startUtc!.isBefore(block.startUtc!)).toList();
    final first = followers
        .where((o) => o.pinned || _movable(o, includeCalendar))
        .firstOrNull;
    // Calendar events before the first movable follower stay put; report
    // them so the UI can flag the overlap.
    final passed = [
      for (final o in followers.takeWhile((o) => o != first)) o.id,
    ];
    final day = [...others, block];
    if (first == null || first.pinned) {
      final report = ShiftReport(blockedById: first?.id, skippedIds: passed);
      return _apply(day, const {}, report);
    }
    final overlap = block.endUtc!.difference(footprintStart(first));
    if (overlap <= Duration.zero) {
      return _apply(day, const {}, ShiftReport(skippedIds: passed));
    }
    final run = _shift(
      followers,
      overlap,
      includeCalendar: includeCalendar,
      stopAtPinned: true,
    );
    return _apply(day, run.changed, run.report);
  }

  /// Earliest start ≥ the requested one where [block] and its travel buffer
  /// fit between the footprints of [others].
  DateTime _firstFit(List<Occurrence> others, Occurrence block) {
    final need = Duration(minutes: block.durationMin);
    final buffer = Duration(minutes: block.travelBufferMin);
    var candidate = block.startUtc!;
    for (final other in others.where(occupiesTime)) {
      final otherStart = footprintStart(other);
      if (!other.endUtc!.isAfter(candidate.subtract(buffer))) continue;
      if (!candidate.add(need).isAfter(otherStart)) break;
      final next = other.endUtc!.add(buffer);
      if (next.isAfter(candidate)) candidate = next;
    }
    return candidate;
  }

  /// Moves [candidates] (in timeline order) by [delta], skipping blocks the
  /// rules keep in place.
  ///
  /// With [stopAtPinned] the pass ends at the first pinned candidate, and
  /// also as soon as a block would be pushed onto that pin (or, moving
  /// earlier, onto [floor], the pin before the group): a shift never carries
  /// a block across a pinned one (docs/04 §5).
  _Run _shift(
    Iterable<Occurrence> candidates,
    Duration delta, {
    required bool includeCalendar,
    required bool stopAtPinned,
    bool skipFinished = false,
    Occurrence? floor,
  }) {
    final list = candidates.toList();
    final pinAt = stopAtPinned ? list.indexWhere((o) => o.pinned) : -1;
    final pin = pinAt < 0 ? null : list[pinAt];
    final changed = <String, Occurrence>{};
    final skipped = <String>[];
    for (final o in pinAt < 0 ? list : list.take(pinAt)) {
      final finished = skipFinished && o.status != OccurrenceStatus.planned;
      if (o.pinned || finished || !_movable(o, includeCalendar)) {
        skipped.add(o.id);
        continue;
      }
      final moved = _moveBy(o, delta);
      final blocker = _collision(moved, pin, floor);
      if (blocker != null) {
        return _Run(changed, _report(changed, skipped, blocker.id));
      }
      changed[o.id] = moved;
    }
    return _Run(changed, _report(changed, skipped, pin?.id));
  }

  /// The pin [moved] would now overlap: [pin] ahead of it, or [floor] behind.
  static Occurrence? _collision(
    Occurrence moved,
    Occurrence? pin,
    Occurrence? floor,
  ) {
    if (pin != null && moved.endUtc!.isAfter(footprintStart(pin))) return pin;
    if (floor != null && footprintStart(moved).isBefore(floor.endUtc!)) {
      return floor;
    }
    return null;
  }

  static ShiftReport _report(
    Map<String, Occurrence> changed,
    List<String> skipped,
    String? blockedById,
  ) =>
      ShiftReport(
        movedIds: [...changed.keys],
        blockedById: blockedById,
        skippedIds: skipped,
      );

  ScheduleResult _apply(
    List<Occurrence> day,
    Map<String, Occurrence> changed,
    ShiftReport report, [
    List<String> leadingMoved = const [],
  ]) {
    final next = sortedByStart([for (final o in day) changed[o.id] ?? o]);
    final moved = [...leadingMoved, ...report.movedIds];
    return ScheduleResult(
      next,
      ShiftReport(
        movedIds: moved,
        blockedById: report.blockedById,
        skippedIds: report.skippedIds,
      ),
    );
  }
}

/// Changed blocks by id plus the report of one shift pass.
final class _Run {
  const _Run(this.changed, this.report);

  final Map<String, Occurrence> changed;
  final ShiftReport report;
}

bool _movable(Occurrence o, bool includeCalendar) =>
    includeCalendar || o.source != OccurrenceSource.calendar;

Occurrence _moveBy(Occurrence o, Duration delta) =>
    o.copyWith(startUtc: o.startUtc!.add(delta));
