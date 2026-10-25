import 'package:dottoday/domain/live_activity/live_dot_plan.dart';
import 'package:dottoday/domain/snapshot/day_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

// The Live Activity / ongoing notification lifecycle (docs/09 M9.3, M9.4,
// docs/11 A1): shown while a dot is live or starts within 60 min, kept 30
// min past a planned end, gone on Done.

final _t = DateTime.utc(2026, 10, 21, 9);

SnapshotDot _dot(String id, int startMin, int minutes, {bool done = false}) =>
    SnapshotDot(
      id: id,
      title: id,
      startUtc: _t.add(Duration(minutes: startMin)),
      durationMin: minutes,
      colorKey: 'indigo',
      iconKey: 'code',
      done: done,
    );

DaySnapshot _snap(List<SnapshotDot> dots) => DaySnapshot(
  generatedAtUtc: _t,
  wakeUtc: _t.subtract(const Duration(hours: 2)),
  bedUtc: _t.add(const Duration(hours: 13)),
  dots: dots,
  inboxCount: 0,
  dayDone: 1,
  dayTotal: 3,
);

DateTime _at(int minutes) => _t.add(Duration(minutes: minutes));

void main() {
  // Deep work 9:00–11:00, Reply 11:00–11:30, Lunch 12:30–13:15, Call 15:00.
  final day = _snap([
    _dot('deep', 0, 120),
    _dot('reply', 120, 30),
    _dot('lunch', 210, 45),
    _dot('call', 360, 30),
  ]);

  test('a live dot is the focus, with the next two', () {
    final plan = liveDotPlan(day, _at(82))!;
    expect(plan.focus.id, 'deep');
    expect(plan.isLive, isTrue);
    expect(plan.next.map((d) => d.id), ['reply', 'lunch']);
    expect((plan.dayDone, plan.dayTotal), (1, 3));
    expect(plan.endsAtUtc, _at(150));
  });

  test('the next dot within 60 min shows as coming up', () {
    // 12:20: Reply's grace ended at 12:00; Lunch starts at 12:30.
    final plan = liveDotPlan(day, _at(200))!;
    expect(plan.focus.id, 'lunch');
    expect(plan.isLive, isFalse);
  });

  test('nothing live or within the hour: no surface', () {
    // 13:50: Lunch's grace ended at 13:45; Call is 70 min away.
    expect(liveDotPlan(day, _at(290)), isNull);
    expect(liveDotPlan(day, _at(-61)), isNull);
    expect(liveDotPlan(day, _at(-60))?.focus.id, 'deep');
  });

  test('an overrun stays 30 min past the planned end, then goes', () {
    final solo = _snap([_dot('deep', 0, 120)]);
    expect(liveDotPlan(solo, _at(149))?.isLive, isTrue);
    expect(liveDotPlan(solo, _at(150)), isNull);
  });

  test('Done ends it: a done dot is never the focus', () {
    final done = _snap([_dot('deep', 0, 120, done: true)]);
    expect(liveDotPlan(done, _at(30)), isNull);
  });

  test('a dot that starts takes over from an overrunning one', () {
    // 11:10: Deep work is 10 min over (not done), Reply has started.
    expect(liveDotPlan(day, _at(130))?.focus.id, 'reply');
  });

  test('re-plans at the next lead, start or grace end', () {
    // At 10:22 the next moment is Reply's start at 11:00.
    expect(nextPlanChange(day, _at(82)), _at(120));
    expect(nextPlanChange(_snap(const []), _at(82)), isNull);
  });
}
