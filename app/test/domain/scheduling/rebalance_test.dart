import 'dart:math';

import 'package:dottoday/domain/entities/enums.dart';
import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/proposals/proposal.dart';
import 'package:dottoday/domain/proposals/rebalance_proposal.dart';
import 'package:dottoday/domain/scheduling/rebalance.dart';
import 'package:flutter_test/flutter_test.dart';

import 'scheduling_support.dart';

// Rebalance's rules (11 C1, docs/09 M11.1): shift → shrink optional →
// past a pin → past Bedtime to tomorrow; pinned never moves; nothing is
// written here. The seeded property checks the invariants on random days.

final _bed = at('22:00');

RebalancePlan _run(
  List<Occurrence> day, {
  String from = '11:00',
  int delta = 25,
  RebalanceOptions options = const RebalanceOptions(),
  RebalanceTomorrow? tomorrow,
}) => rebalance(
  day,
  fromUtc: at(from),
  deltaMin: delta,
  bedUtc: _bed,
  options: options,
  tomorrow: tomorrow,
);

Map<String, String> _startsOf(RebalancePlan p) => {
  for (final MapEntry(:key, :value) in p.changed.entries)
    key: value.startUtc == null ? 'inbox' : hhmm(value.startUtc!),
};

final _tomorrow = RebalanceTomorrow(
  blocks: const [],
  wakeUtc: DateTime.utc(2026, 10, 22, 7),
  bedUtc: DateTime.utc(2026, 10, 22, 20),
);

void main() {
  group('shift followers', () {
    test('on: everything up to the pin moves by the delay, gaps kept', () {
      final plan = _run([
        block('email', '11:00', 30),
        block('call', '11:45', 15),
        block('lunch', '12:30', 45, pinned: true),
      ]);
      expect(_startsOf(plan), {'email': '11:25', 'call': '12:10'});
      // Listed so the user sees why nothing after it moved.
      expect(plan.pinnedIds, ['lunch']);
    });

    test('off: only what collides moves; the gap absorbs the rest', () {
      final plan = _run([
        block('email', '11:00', 30),
        block('call', '11:45', 15),
      ], options: const RebalanceOptions(shiftFollowers: false));
      // email 11:25–11:55; call starts 11:45 → just after email.
      expect(_startsOf(plan), {'email': '11:25', 'call': '11:55'});
    });
  });

  group('a pin in the way', () {
    final day = [
      block('email', '11:00', 30),
      block('spanish', '11:30', 60),
      block('lunch', '12:30', 60, pinned: true),
    ];

    test('optional tasks shrink before anything leaves', () {
      final plan = _run(day);
      // 25 min late: email 11:25–11:55; spanish may lose a quarter at
      // most (60 → 45), which still ends 12:40, past lunch: it moves on.
      expect(plan.changed['spanish']!.startUtc, at('13:30'));
      expect(plan.pinnedIds, ['lunch']);
    });

    test('a small delay is absorbed by shrinking', () {
      final plan = _run(day, delta: 10);
      expect(_startsOf(plan), {'email': '11:10', 'spanish': '11:40'});
      expect(plan.changed['spanish']!.durationMin, 50);
      expect(plan.changed['lunch'], isNull);
    });

    test('high energy and started tasks never shrink', () {
      final plan = _run([
        block('email', '11:00', 30),
        block('spanish', '11:30', 60).copyWith(energy: Energy.high),
        block('lunch', '12:30', 60, pinned: true),
      ], delta: 10);
      expect(plan.changed['spanish']!.durationMin, 60);
      expect(plan.changed['spanish']!.startUtc, at('13:30'));
    });

    test('shrinking off: it moves past the pin', () {
      final plan = _run(
        day,
        delta: 10,
        options: const RebalanceOptions(allowShrink: false),
      );
      expect(plan.changed['spanish']!.startUtc, at('13:30'));
      expect(plan.changed['spanish']!.durationMin, 60);
    });
  });

  group('Bedtime', () {
    final day = [block('read', '20:00', 60), block('dentist', '21:00', 45)];

    test('past Bedtime moves to tomorrow\'s first free slot', () {
      final plan = _run(
        day,
        from: '20:00',
        options: const RebalanceOptions(allowShrink: false),
        tomorrow: _tomorrow,
      );
      expect(plan.sentOffIds, {'dentist'});
      expect(plan.changed['dentist']!.startUtc, DateTime.utc(2026, 10, 22, 7));
    });

    test('no tomorrow given: the Inbox', () {
      final plan = _run(
        day,
        from: '20:00',
        options: const RebalanceOptions(allowShrink: false),
      );
      expect(_startsOf(plan)['dentist'], 'inbox');
    });

    test('Push past bedtime: the day just runs later', () {
      final plan = _run(
        day,
        from: '20:00',
        options: const RebalanceOptions(pastBedtime: true),
      );
      expect(plan.sentOffIds, isEmpty);
      expect(_startsOf(plan), {'read': '20:25', 'dentist': '21:25'});
    });
  });

  test('calendar events and done tasks stay put', () {
    final plan = _run([
      block('standup', '11:00', 15, source: OccurrenceSource.calendar),
      block('done', '11:20', 10, status: OccurrenceStatus.done),
      block('email', '11:30', 30),
    ]);
    expect(plan.changed.keys, ['email']);
    expect(plan.changed['email']!.startUtc, at('11:55'));
  });

  group('the proposal', () {
    Proposal proposalOf(List<Occurrence> day, RebalancePlan plan) =>
        rebalanceProposal(
          day: day,
          plan: plan,
          wakeUtc: at('07:00'),
          bedUtc: _bed,
          nowUtc: at('11:00'),
        );

    test('shifted, shrunk and the pin untouched (not written)', () {
      final day = [
        block('email', '11:00', 30),
        block('spanish', '11:30', 60),
        block('lunch', '12:30', 60, pinned: true),
      ];
      final p = proposalOf(day, _run(day, delta: 10));
      expect(
        {for (final e in p.edits) e.id: e.change},
        {
          'email': ProposalChange.shifted,
          'spanish': ProposalChange.resized,
          'lunch': ProposalChange.untouched,
        },
      );
      final written = p.toBatch().occurrences;
      expect(written.map((o) => o.id), ['email', 'spanish']);
      expect(written.every((o) => o.moveCount == 1), isTrue);
    });

    test('past Bedtime: moved to tomorrow, counted as a move', () {
      final day = [
        block('read', '20:00', 90),
        block('dentist', '21:30', 30).copyWith(energy: Energy.high),
      ];
      final plan = _run(day, from: '20:00', tomorrow: _tomorrow);
      final p = proposalOf(day, plan);
      final dentist = p.edits.firstWhere((e) => e.id == 'dentist');
      expect(dentist.change, ProposalChange.movedToDay);
      expect(dentist.after, isNull);
      expect(dentist.movedToUtc, DateTime.utc(2026, 10, 22, 7));
      expect(dentist.occurrences.single.moveCount, 1);
      expect(p.after.dots.map((d) => d.id), ['read']);
    });
  });

  test('property: seeded random days keep the invariants', () {
    final rnd = Random(1121);
    for (var run = 0; run < 400; run++) {
      final day = _randomDay(rnd);
      final options = RebalanceOptions(
        shiftFollowers: rnd.nextBool(),
        allowShrink: rnd.nextBool(),
        pastBedtime: rnd.nextInt(4) == 0,
      );
      final from = at('09:00').add(Duration(minutes: rnd.nextInt(8) * 30));
      final plan = rebalance(
        day,
        fromUtc: from,
        deltaMin: 5 + rnd.nextInt(12) * 5,
        bedUtc: _bed,
        options: options,
        tomorrow: rnd.nextBool() ? _tomorrow : null,
      );
      _checkInvariants(day, plan, from, options, 'run $run');
    }
  });
}

List<Occurrence> _randomDay(Random rnd) {
  final blocks = <Occurrence>[];
  var minute = 8 * 60;
  for (var i = 0; i < 2 + rnd.nextInt(10); i++) {
    minute += rnd.nextInt(4) * 15;
    final length = 15 + rnd.nextInt(12) * 5;
    blocks.add(
      block(
        'b$i',
        '00:00',
        length,
        pinned: rnd.nextInt(5) == 0,
        source: rnd.nextInt(7) == 0
            ? OccurrenceSource.calendar
            : OccurrenceSource.user,
      ).copyWith(
        startUtc: at('00:00').add(Duration(minutes: minute)),
        energy: rnd.nextInt(4) == 0 ? Energy.high : null,
      ),
    );
    minute += length;
  }
  return blocks;
}

void _checkInvariants(
  List<Occurrence> day,
  RebalancePlan plan,
  DateTime from,
  RebalanceOptions options,
  String reason,
) {
  final after =
      [for (final o in day) plan.changed[o.id] ?? o]
          .where(
            (o) =>
                o.startUtc != null &&
                o.startUtc!.isBefore(_bed.add(const Duration(hours: 6))),
          )
          .toList()
        ..sort((a, b) => a.startUtc!.compareTo(b.startUtc!));
  final original = {for (final o in day) o.id: o};
  for (final o in day) {
    final next = plan.changed[o.id];
    if (next == null) continue;
    expect(o.pinned, isFalse, reason: '$reason: pinned ${o.id} moved');
    expect(o.source, OccurrenceSource.user, reason: '$reason: event moved');
    expect(o.startUtc!.isBefore(from), isFalse, reason: '$reason: earlier');
    if (next.startUtc case final s?) {
      expect(s.isBefore(o.startUtc!), isFalse, reason: '$reason: pulled in');
    }
    if (next.durationMin != o.durationMin) {
      expect(options.allowShrink, isTrue, reason: reason);
      expect(next.durationMin >= shrunkMinutes(o), isTrue, reason: reason);
    }
    if (plan.sentOffIds.contains(o.id)) {
      expect(options.pastBedtime, isFalse, reason: reason);
    }
  }
  // Moved tasks never overlap each other or a pin (events may overlap:
  // they were never the plan's to move, as with Running late today).
  final today = after.where((o) => !plan.sentOffIds.contains(o.id)).toList();
  for (var i = 0; i < today.length; i++) {
    for (var j = i + 1; j < today.length; j++) {
      final a = today[i];
      final b = today[j];
      final involved =
          plan.changed.containsKey(a.id) || plan.changed.containsKey(b.id);
      final fixedPair =
          (a.source == OccurrenceSource.calendar) ||
          (b.source == OccurrenceSource.calendar);
      if (!involved || fixedPair) continue;
      final overlap =
          a.startUtc!.isBefore(b.endUtc!) && b.startUtc!.isBefore(a.endUtc!);
      expect(overlap, isFalse, reason: '$reason: ${a.id} × ${b.id}');
    }
  }
  // Order among the moved user tasks that stay today is kept.
  final kept = today
      .where((o) => plan.changed.containsKey(o.id))
      .map((o) => original[o.id]!.startUtc!)
      .toList();
  for (var i = 1; i < kept.length; i++) {
    expect(kept[i].isBefore(kept[i - 1]), isFalse, reason: '$reason: order');
  }
}
