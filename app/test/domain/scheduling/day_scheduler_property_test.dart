import 'dart:math';

import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/scheduling/day_scheduler_service.dart';
import 'package:dottoday/domain/scheduling/schedule_result.dart';
import 'package:flutter_test/flutter_test.dart';

import 'scheduling_support.dart';

// Property tests for docs/04 §5 invariants with a hand-rolled, seeded
// generator (docs/08 §1): pinned never moves, order is preserved, gaps
// between shifted blocks are kept, and no overlap is created except against
// the reported blocking pin or skipped events.

const _s = DaySchedulerService();
const _runs = 300;

/// A random non-overlapping day of 2–12 blocks starting 06:00.
List<Occurrence> _day(Random rnd) {
  final blocks = <Occurrence>[];
  var minute = 6 * 60;
  for (var i = 0; i < 2 + rnd.nextInt(11); i++) {
    minute += rnd.nextInt(4) * 15;
    final duration = 5 + rnd.nextInt(12) * 5;
    final source =
        rnd.nextInt(6) == 0 ? OccurrenceSource.calendar : OccurrenceSource.user;
    blocks.add(
      block(
        'b$i',
        '06:00',
        duration,
        pinned: rnd.nextInt(5) == 0,
        source: source,
      ).copyWith(startUtc: at('00:00').add(Duration(minutes: minute))),
    );
    minute += duration;
  }
  return blocks;
}

bool _overlap(Occurrence a, Occurrence b) =>
    a.startUtc!.isBefore(b.endUtc!) && b.startUtc!.isBefore(a.endUtc!);

Set<(String, String)> _overlaps(List<Occurrence> day) => {
      for (final a in day)
        for (final b in day)
          if (a.id.compareTo(b.id) < 0 && _overlap(a, b)) (a.id, b.id),
    };

void _checkInvariants(
  List<Occurrence> before,
  ScheduleResult result, {
  String? exempt,
  Set<String> alsoAllowed = const {},
}) {
  final after = {for (final o in result.day) o.id: o};
  for (final o in before.where((o) => o.pinned && o.id != exempt)) {
    expect(after[o.id]!.startUtc, o.startUtc, reason: 'pinned ${o.id} moved');
  }
  final moved = result.report.movedIds;
  final original = {for (final o in before) o.id: o};
  // Gaps between consecutive moved blocks are unchanged.
  for (var i = 1; i < moved.length; i++) {
    final gapBefore = original[moved[i]]!
        .startUtc!
        .difference(original[moved[i - 1]]!.startUtc!);
    final gapAfter =
        after[moved[i]]!.startUtc!.difference(after[moved[i - 1]]!.startUtc!);
    expect(gapAfter, gapBefore, reason: 'gap changed');
  }
  // No moved block crosses a pinned block.
  for (final id in moved.where((id) => id != exempt)) {
    for (final p in before.where((o) => o.pinned && o.id != exempt)) {
      expect(
        original[id]!.startUtc!.isBefore(p.startUtc!),
        after[id]!.startUtc!.isBefore(p.startUtc!),
        reason: '$id crossed pinned ${p.id}',
      );
    }
  }
  // New overlaps only against blocks the report names as left in place;
  // a partial shift leaves every unmoved block where it was, by design.
  final allowed = {
    if (result.report.partial)
      ...before.map((o) => o.id).where((id) => !moved.contains(id)),
    if (result.report.blockedById case final id?) id,
    ...result.report.skippedIds,
    ...alsoAllowed,
  };
  final created = _overlaps(result.day).difference(_overlaps(before));
  for (final (a, b) in created) {
    expect(
      allowed.contains(a) || allowed.contains(b) || a == exempt || b == exempt,
      isTrue,
      reason:
          'overlap $a/$b created: ${starts(before)} -> ${starts(result.day)} '
          '${result.day.map((o) => '${o.id}:${o.durationMin}${o.pinned ? 'P' : ''}${o.source.name[0]}').join(' ')} '
          'report ${result.report.movedIds} ${result.report.skippedIds} ${result.report.blockedById} exempt $exempt',
    );
  }
}

void main() {
  test('shiftFollowers invariants hold for random days', () {
    final rnd = Random(20261021);
    for (var run = 0; run < _runs; run++) {
      final day = _day(rnd);
      final moved = day[rnd.nextInt(day.length)];
      final delta = (rnd.nextInt(13) - 2) * 10;
      final r = _s.shiftFollowers(day, moved.id, delta);
      // The dragged block may itself be pinned; it moves by user intent.
      // Dragging earlier can land the group on blocks before it, which the
      // shift never touches, so those overlaps are the user's choice.
      final earlier = {
        for (final o in day)
          if (o.startUtc!.isBefore(moved.startUtc!)) o.id,
      };
      _checkInvariants(day, r, exempt: moved.id, alsoAllowed: earlier);
      final order = r.report.movedIds;
      expect(
        order,
        [
          for (final o in r.day)
            if (order.contains(o.id)) o.id,
        ],
        reason: 'relative order changed',
      );
    }
  });

  test('runningLate invariants hold for random days', () {
    final rnd = Random(7);
    for (var run = 0; run < _runs; run++) {
      final day = _day(rnd);
      final now = at('06:00').add(Duration(minutes: rnd.nextInt(600)));
      final r = _s.runningLate(day, now, [5, 15, 30][rnd.nextInt(3)]);
      _checkInvariants(day, r);
      for (final id in r.report.movedIds) {
        final o = day.firstWhere((o) => o.id == id);
        expect(o.startUtc!.isBefore(now), isFalse);
        expect(o.pinned, isFalse);
      }
    }
  });

  test('insert(bump) creates no overlap with movable followers', () {
    final rnd = Random(42);
    for (var run = 0; run < _runs; run++) {
      final day = _day(rnd);
      final start = at('06:00').add(Duration(minutes: rnd.nextInt(600)));
      final fresh = block('new', '06:00', 5 + rnd.nextInt(12) * 5)
          .copyWith(startUtc: start);
      final r = _s.insert(day, fresh, InsertPolicy.bump);
      // Blocks that began before the new one are never moved by bump.
      final earlier = {
        for (final o in day)
          if (o.startUtc!.isBefore(start)) o.id,
      };
      final created = _overlaps(r.day).difference(_overlaps(day));
      final allowed = {
        if (r.report.partial)
          ...day
              .map((o) => o.id)
              .where((id) => !r.report.movedIds.contains(id)),
        if (r.report.blockedById case final id?) id,
        ...r.report.skippedIds,
        ...earlier,
      };
      for (final (a, b) in created) {
        expect(
          allowed.contains(a) || allowed.contains(b),
          isTrue,
          reason: 'overlap $a/$b: ${starts(r.day)} '
              '${r.day.map((o) => '${o.id}:${o.durationMin}${o.pinned ? 'P' : ''}${o.source.name[0]}').join(' ')} '
              'report ${r.report.movedIds} ${r.report.skippedIds} ${r.report.blockedById}',
        );
      }
      _checkInvariants([...day, fresh], r);
    }
  });

  test('insert(fitNextGap) never overlaps an occupying block', () {
    final rnd = Random(99);
    for (var run = 0; run < _runs; run++) {
      final day = _day(rnd);
      final fresh = block('new', '06:00', 5 + rnd.nextInt(24) * 5).copyWith(
        startUtc: at('06:00').add(Duration(minutes: rnd.nextInt(600))),
      );
      final r = _s.insert(day, fresh, InsertPolicy.fitNextGap);
      final placed = r.byId('new');
      expect(placed.startUtc!.isBefore(fresh.startUtc!), isFalse);
      for (final o in r.day.where((o) => o.id != 'new')) {
        expect(_overlap(o, placed), isFalse, reason: 'overlaps ${o.id}');
      }
    }
  });
}
