import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/reveal/hint_scheduler.dart';
import 'package:dottoday/domain/reveal/hint_signals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// docs/15 §11, M17.6: Wake Up's discovery shares minimal mode's hint
// budget (owner: one a day, twice ever) — the promise returns once after
// 7 days, the mission offer after 30, Shift's coach mark shows once, the
// check's text is never a surface, and the card and Today share the day.

late tz.Location berlin;

/// 10:00 in Berlin, [d] days after 1 November 2026.
DateTime at(int d, {int hour = 10}) =>
    DateTime.utc(2026, 11, 1, hour - 1).add(Duration(days: d));

RevealHint record(HintId hint, {int shown = 0, DateTime? last}) => RevealHint(
  id: hint.name,
  userId: 'u',
  hintId: hint,
  shownCount: shown,
  lastShownUtc: last,
  createdAt: at(0),
  updatedAt: at(0),
);

const today = HintSignals(daysOfUse: 30, minimal: false, wakeUpOffer: true);
const card = HintSignals(
  daysOfUse: 30,
  surface: HintSurface.wakeUpCard,
  alarmStopped: true,
  shiftOffered: true,
);

HintId? pick(HintSignals s, Map<HintId, RevealHint> r, DateTime now) =>
    pickHint(signals: s, records: r, nowUtc: now, zone: berlin)?.hint;

/// Shows what [s] picks each day for [days] days and records it.
List<HintId?> run(int days, HintSignals s, Map<HintId, RevealHint> r) => [
  for (var d = 0; d < days; d++)
    () {
      final h = pick(s, r, at(d));
      if (h != null) {
        final old = r[h] ?? record(h);
        r[h] = old.copyWith(
          shownCount: old.shownCount + 1,
          lastShownUtc: at(d),
        );
      }
      return h;
    }(),
];

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  test('the promise shows in the full layout, again only after 7 days', () {
    final shown = run(20, today, {});
    expect(shown[0], HintId.wakeUpPromise);
    expect(shown.sublist(1, 7), everyElement(isNull));
    expect(shown[7], HintId.wakeUpPromise);
    expect(shown.skip(8), everyElement(isNull));
  });

  test("minimal mode's hints never show in the full layout", () {
    const s = HintSignals(
      daysOfUse: 30,
      minimal: false,
      movedTaskId: 'm',
      sameMornings: true,
    );
    expect(pick(s, {}, at(0)), isNull);
    expect(
      pick(const HintSignals(daysOfUse: 30, movedTaskId: 'm'), {}, at(0)),
      HintId.unstick,
    );
  });

  test('Start the day twice, then Shift once, on the card only', () {
    final shown = run(5, card, {});
    expect(shown, [
      HintId.wakeUpStartDay,
      HintId.wakeUpStartDay,
      HintId.wakeUpShift,
      null,
      null,
    ]);
    const onToday = HintSignals(
      daysOfUse: 0,
      alarmStopped: true,
      shiftOffered: true,
    );
    expect(pick(onToday, {}, at(0)), isNull);
  });

  test('the card and Today share one hint a day', () {
    final r = <HintId, RevealHint>{};
    expect(run(1, card, r), [HintId.wakeUpStartDay]);
    // Later that morning Today has the promise to show: not today.
    expect(pick(today, r, at(0, hour: 11)), isNull);
    expect(pick(today, r, at(1)), HintId.wakeUpPromise);
  });

  test("the check's text is never a row or a coach mark", () {
    const everything = HintSignals(
      daysOfUse: 0,
      wakeUpOffer: true,
      lateMornings: true,
    );
    final r = {
      HintId.wakeUpPromise: record(HintId.wakeUpPromise, shown: 2),
      HintId.missionOffer: record(HintId.missionOffer, shown: 2),
    };
    expect(pick(everything, r, at(0)), isNull);
    expect(hintMaxShowsOf(HintId.wakeUpCheckPing), 2);
  });

  test('the mission offer waits 30 days between its two showings', () {
    const s = HintSignals(daysOfUse: 30, minimal: false, lateMornings: true);
    final shown = run(70, s, {});
    expect(
      [
        for (var d = 0; d < shown.length; d++)
          if (shown[d] != null) d,
      ],
      [0, 30],
    );
  });

  test('late mornings: the newest three each ≥ 20 min after Wake Up', () {
    expect(lateMorningsOf([25, 20, 40, 0]), isTrue);
    expect(lateMorningsOf([25, 19, 40]), isFalse);
    expect(lateMorningsOf([25, 30]), isFalse);
    expect(lateMorningsOf([0, 25, 30, 40]), isFalse);
  });
}
