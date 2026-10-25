import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_blocks.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/low_energy.dart';
import 'package:dottoday/domain/scheduling/slot_finder.dart';

// Rebalance (11 C1, docs/09 M11.1): the rule pass behind the proposal.
// Pure; nothing here writes. Rules in order: shift → shrink optional →
// past a pin → past Bedtime to tomorrow (or the Inbox). Pinned tasks and
// calendar events the shift may not carry never move.

/// The three rule switches of `B-ios-rebalance`.
final class RebalanceOptions {
  const RebalanceOptions({
    this.shiftFollowers = true,
    this.allowShrink = true,
    this.pastBedtime = false,
  });

  /// On: up to the first pin, every later task moves by the delay and
  /// keeps its gap. Off: only what would collide moves; gaps absorb the
  /// delay.
  final bool shiftFollowers;

  /// Shorten optional tasks ([shrinkable]) before moving one off the day.
  final bool allowShrink;

  /// Let the day run past Bedtime instead of moving tasks to tomorrow.
  final bool pastBedtime;

  RebalanceOptions copyWith({
    bool? shiftFollowers,
    bool? allowShrink,
    bool? pastBedtime,
  }) => RebalanceOptions(
    shiftFollowers: shiftFollowers ?? this.shiftFollowers,
    allowShrink: allowShrink ?? this.allowShrink,
    pastBedtime: pastBedtime ?? this.pastBedtime,
  );
}

/// Where a task pushed past Bedtime may go: tomorrow's blocks between its
/// Wake Up and Bedtime.
final class RebalanceTomorrow {
  const RebalanceTomorrow({
    required this.blocks,
    required this.wakeUtc,
    required this.bedUtc,
  });

  final List<Occurrence> blocks;
  final DateTime wakeUtc;
  final DateTime bedUtc;
}

/// What the rules did: new versions of the tasks that change (a null
/// start = the Inbox), and the pins the plan worked around.
final class RebalancePlan {
  const RebalancePlan({
    required this.changed,
    required this.pinnedIds,
    this.sentOffIds = const {},
  });

  /// By id, in day order; moves not counted yet (the proposal does).
  final Map<String, Occurrence> changed;

  /// Tasks moved off the day: to tomorrow, or to the Inbox.
  final Set<String> sentOffIds;

  /// Pinned tasks that bounded a part of the day that changed.
  final List<String> pinnedIds;

  bool get isEmpty => changed.isEmpty;
}

/// Shortest a shrunk task becomes, and the most it gives up (a quarter).
const rebalanceMinMinutes = 15;
const _keepShare = 0.75;

/// Whether Rebalance may shorten [o]: an optional task ([isOptional])
/// longer than [rebalanceMinMinutes] (11 C1, docs/09 M11.1).
bool shrinkable(Occurrence o) =>
    isOptional(o) && o.durationMin > rebalanceMinMinutes;

/// The length [o] may be shrunk to: three quarters, rounded up to 5 min,
/// never under [rebalanceMinMinutes].
int shrunkMinutes(Occurrence o) {
  final keep = ((o.durationMin * _keepShare) / 5).ceil() * 5;
  return keep < rebalanceMinMinutes ? rebalanceMinMinutes : keep;
}

/// Rebalances [day] for a delay of [deltaMin] at [fromUtc]: the planned
/// tasks starting then or later, by [options]. Tasks never start earlier
/// than planned, keep their order, and never overlap a pin or each other.
///
/// ```dart
/// rebalance(day, fromUtc: now, deltaMin: 25, bedUtc: bed).changed.keys;
/// ```
RebalancePlan rebalance(
  List<Occurrence> day, {
  required DateTime fromUtc,
  required int deltaMin,
  required DateTime bedUtc,
  RebalanceOptions options = const RebalanceOptions(),
  RebalanceTomorrow? tomorrow,
  bool includeCalendar = false,
  Set<String> readOnlyIds = const {},
}) {
  final later = scheduledBlocks(day).where(
    (o) =>
        o.status == OccurrenceStatus.planned && !o.startUtc!.isBefore(fromUtc),
  );
  bool fixed(Occurrence o) =>
      o.pinned || !movableBlock(o, includeCalendar, readOnlyIds);
  final pass = _Pass(options, Duration(minutes: deltaMin));
  var cursor = fromUtc.add(Duration(minutes: deltaMin));
  var queue = <Occurrence>[];
  for (final o in later) {
    if (!fixed(o)) {
      queue.add(o);
      continue;
    }
    final before = pass.changed.length;
    final spill = pass.settle(queue, cursor, footprintStart(o));
    if (o.pinned && (pass.changed.length > before || spill.isNotEmpty)) {
      pass.pinnedIds.add(o.id);
    }
    // A pin anchors the rest of the day: the shift stops there, as
    // "Shift the rest" does (R-17); an event is only stepped around.
    if (o.pinned) pass.shifting = false;
    queue = spill;
    if (o.endUtc!.isAfter(cursor)) cursor = o.endUtc!;
  }
  final overflow = pass.settle(
    queue,
    cursor,
    _dayLimit(queue, bedUtc, options),
  );
  pass.sendOff(overflow, tomorrow);
  return RebalancePlan(
    changed: pass.changed,
    pinnedIds: pass.pinnedIds,
    sentOffIds: {for (final o in overflow) o.id},
  );
}

/// Where the last stretch must end: Bedtime (or a task already planned
/// past it), none with Push past bedtime.
DateTime? _dayLimit(
  List<Occurrence> queue,
  DateTime bedUtc,
  RebalanceOptions options,
) {
  if (options.pastBedtime) return null;
  final last = queue.isEmpty ? null : queue.last.endUtc!;
  return last != null && last.isAfter(bedUtc) ? last : bedUtc;
}

/// One placement: a task with its proposed start and length.
typedef _Placed = ({Occurrence o, DateTime start, int minutes});

/// The running state of one [rebalance] call.
final class _Pass {
  _Pass(this.options, this.delay);

  final RebalanceOptions options;
  final Duration delay;
  final Map<String, Occurrence> changed = {};
  final List<String> pinnedIds = [];

  /// Only the stretch before the first pin shifts by [delay].
  bool shifting = true;

  /// Places [queue] from [cursor] so it ends by [limit] (none = open);
  /// returns the tasks that don't fit, which carry on past the limit.
  List<Occurrence> settle(
    List<Occurrence> queue,
    DateTime cursor,
    DateTime? limit,
  ) {
    final shift = shifting && options.shiftFollowers;
    final spill = <Occurrence>[];
    final rest = [...queue];
    while (rest.isNotEmpty) {
      final fit = _fit(rest, cursor, limit, shift);
      if (fit != null) {
        _record(fit);
        return spill;
      }
      spill.insert(0, rest.removeLast());
    }
    return spill;
  }

  /// [queue] placed within [limit]: shifted, else just enough, else with
  /// optional tasks shrunk; null when even that overruns.
  List<_Placed>? _fit(
    List<Occurrence> queue,
    DateTime cursor,
    DateTime? limit,
    bool shift,
  ) {
    bool fits(List<_Placed> p) =>
        limit == null ||
        !p.last.start.add(Duration(minutes: p.last.minutes)).isAfter(limit);
    final lengths = [for (final o in queue) o.durationMin];
    if (shift) {
      final shifted = _pack(queue, lengths, cursor, delay);
      if (fits(shifted)) return shifted;
    }
    final snug = _pack(queue, lengths, cursor, Duration.zero);
    if (fits(snug) || !options.allowShrink || limit == null) {
      return fits(snug) ? snug : null;
    }
    final end = snug.last.start.add(Duration(minutes: snug.last.minutes));
    var need = end.difference(limit).inMinutes;
    for (var i = queue.length - 1; i >= 0 && need > 0; i--) {
      final o = queue[i];
      if (!shrinkable(o)) continue;
      final cut = o.durationMin - shrunkMinutes(o);
      final take = cut < need ? cut : need;
      lengths[i] = o.durationMin - take;
      need -= take;
    }
    final shrunk = _pack(queue, lengths, cursor, Duration.zero);
    return fits(shrunk) ? shrunk : null;
  }

  /// Each task at its planned start (plus [shift]) or right after the one
  /// before it, whichever is later.
  static List<_Placed> _pack(
    List<Occurrence> queue,
    List<int> lengths,
    DateTime cursor,
    Duration shift,
  ) {
    final out = <_Placed>[];
    var at = cursor;
    for (final (i, o) in queue.indexed) {
      final wanted = o.startUtc!.add(shift);
      final earliest = at.add(Duration(minutes: o.travelBufferMin));
      final start = wanted.isAfter(earliest) ? wanted : earliest;
      out.add((o: o, start: start, minutes: lengths[i]));
      at = start.add(Duration(minutes: lengths[i]));
    }
    return out;
  }

  void _record(List<_Placed> placed) {
    for (final p in placed) {
      if (p.start == p.o.startUtc && p.minutes == p.o.durationMin) continue;
      changed[p.o.id] = p.o.copyWith(startUtc: p.start, durationMin: p.minutes);
    }
  }

  /// Tasks past Bedtime: tomorrow's first free slot from Wake Up, else
  /// the Inbox.
  void sendOff(List<Occurrence> overflow, RebalanceTomorrow? tomorrow) {
    final taken = [...?tomorrow?.blocks];
    for (final o in overflow) {
      final slot = tomorrow == null
          ? null
          : findSlots(
              taken,
              o.durationMin,
              fromUtc: tomorrow.wakeUtc,
              dayStartUtc: tomorrow.wakeUtc,
              dayEndUtc: tomorrow.bedUtc,
              limit: 1,
            ).firstOrNull;
      final moved = o.copyWith(startUtc: slot?.startUtc);
      if (slot != null) taken.add(moved);
      changed[o.id] = moved;
    }
  }
}
