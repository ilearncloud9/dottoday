import 'package:dottoday/domain/entities/occurrence.dart';
import 'package:dottoday/domain/entities/reveal_hint.dart';
import 'package:dottoday/domain/reveal/hint_scheduler.dart';
import 'package:dottoday/domain/reveal/hint_signals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// docs/14 §5, M16: the hint budget — one hint per local calendar day, each
// twice ever, never after Not now, never in Focus, a Wind Down review or
// low-energy mode — proven on the pure scheduler with a fixed clock.

late tz.Location berlin;

/// 10:00 in Berlin on day [d] of November 2026 (UTC+1).
DateTime day(int d, {int hour = 10}) => DateTime.utc(2026, 11, d, hour - 1);

RevealHint record(
  HintId hint, {
  int shown = 0,
  DateTime? last,
  DateTime? dismissed,
}) => RevealHint(
  id: hint.name,
  userId: 'u',
  hintId: hint,
  shownCount: shown,
  lastShownUtc: last,
  dismissedAtUtc: dismissed,
  createdAt: day(1),
  updatedAt: day(1),
);

/// Minimal mode's six (docs/14 §5); Wake Up's discovery is in
/// `discovery_hints_test.dart`.
final minimalHints = HintId.values.take(6).toList();

/// Every trigger at once.
const all = HintSignals(
  daysOfUse: 30,
  movedTaskId: 'moved',
  sameMornings: true,
  longTaskId: 'long',
  liveActivityDismissed: true,
  overrunsThisWeek: 5,
);

/// Runs the app's loop for [days]: each day pick, record a first showing,
/// pick again later the same day. Returns what showed on each day.
List<HintId?> simulate(
  int days, {
  HintSignals signals = all,
  Set<HintId> dismissOnSight = const {},
}) {
  final records = <HintId, RevealHint>{};
  final shown = <HintId?>[];
  for (var d = 1; d <= days; d++) {
    final pick = pickHint(
      signals: signals,
      records: records,
      nowUtc: day(d),
      zone: berlin,
    );
    shown.add(pick?.hint);
    if (pick == null) continue;
    expect(pick.firstToday, isTrue, reason: 'day $d');
    final r = records[pick.hint] ?? record(pick.hint);
    records[pick.hint] = r.copyWith(
      shownCount: r.shownCount + 1,
      lastShownUtc: day(d),
      dismissedAtUtc: dismissOnSight.contains(pick.hint) ? day(d) : null,
    );
    // Later that day: the same hint again (not counted), or nothing.
    final again = pickHint(
      signals: signals,
      records: records,
      nowUtc: day(d, hour: 20),
      zone: berlin,
    );
    if (dismissOnSight.contains(pick.hint)) {
      expect(again, isNull, reason: 'Not now ends the day too');
    } else {
      expect(again?.hint, pick.hint);
      expect(again?.firstToday, isFalse);
    }
  }
  return shown;
}

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    berlin = tz.getLocation('Europe/Berlin');
  });

  test('one hint a day, each twice ever, then nothing', () {
    final shown = simulate(15);
    // Day 1 and 2 show the first hint (twice), days 3–4 the second, …
    expect(shown.take(12), [
      for (final h in minimalHints) ...[h, h],
    ]);
    expect(shown.skip(12), everyElement(isNull));
    for (final h in minimalHints) {
      expect(shown.where((s) => s == h), hasLength(hintMaxShows));
    }
  });

  test('Not now retires a hint for good', () {
    final shown = simulate(8, dismissOnSight: {HintId.unstick});
    expect(shown.where((h) => h == HintId.unstick), hasLength(1));
    expect(shown[1], HintId.routines);
  });

  test('never in Focus, a Wind Down review or low-energy mode', () {
    for (final quiet in const [
      HintSignals(daysOfUse: 30, inFocus: true, sameMornings: true),
      HintSignals(daysOfUse: 30, inWindDownReview: true, sameMornings: true),
      HintSignals(daysOfUse: 30, lowEnergy: true, sameMornings: true),
    ]) {
      expect(
        pickHint(signals: quiet, records: {}, nowUtc: day(3), zone: berlin),
        isNull,
      );
    }
  });

  test('a day is the local calendar day', () {
    // 23:30 and 00:30 Berlin are two days, so a second hint may show.
    final late = DateTime.utc(2026, 11, 3, 22, 30);
    final records = {
      HintId.unstick: record(HintId.unstick, shown: 1, last: late),
    };
    final sameNight = pickHint(
      signals: all,
      records: records,
      nowUtc: DateTime.utc(2026, 11, 3, 22, 50),
      zone: berlin,
    );
    expect(sameNight?.firstToday, isFalse);
    final nextDay = pickHint(
      signals: all,
      records: records,
      nowUtc: DateTime.utc(2026, 11, 3, 23, 30),
      zone: berlin,
    );
    expect(nextDay?.firstToday, isTrue);
  });

  test('nothing triggers, nothing shows; the week review waits 14 days', () {
    expect(
      pickHint(
        signals: const HintSignals(daysOfUse: 13),
        records: {},
        nowUtc: day(2),
        zone: berlin,
      ),
      isNull,
    );
    expect(
      pickHint(
        signals: const HintSignals(daysOfUse: 14),
        records: {},
        nowUtc: day(2),
        zone: berlin,
      )?.hint,
      HintId.weekReview,
    );
  });

  group('triggers', () {
    Occurrence task(
      String title,
      int hour, {
      int moves = 0,
      int minutes = 30,
      int? actualEndAfter,
    }) {
      final start = DateTime.utc(2026, 11, 2, hour);
      return Occurrence(
        id: '$title$hour',
        userId: 'u',
        title: title,
        tzId: 'UTC',
        startUtc: start,
        durationMin: minutes,
        moveCount: moves,
        actualEndUtc: actualEndAfter == null
            ? null
            : start.add(Duration(minutes: minutes + actualEndAfter)),
        createdAt: start,
        updatedAt: start,
      );
    }

    test('moved three times without steps', () {
      final o = task('Taxes', 9, moves: 3);
      expect(movedTaskOf([o], {}), o.id);
      expect(movedTaskOf([o], {o.id: 2}), isNull, reason: 'has steps');
      expect(movedTaskOf([task('Taxes', 9, moves: 2)], {}), isNull);
    });

    test('over an hour without steps', () {
      final o = task('Deep work', 9, minutes: 90);
      expect(longTaskOf([o], {}), o.id);
      expect(longTaskOf([task('Walk', 9, minutes: 60)], {}), isNull);
    });

    test('three mornings with the same first three dots', () {
      List<Occurrence> morning() => [
        task('Coffee', 7),
        task('Run', 8),
        task('Email', 9),
        task('Lunch', 12),
      ];
      expect(sameMornings([morning(), morning(), morning()]), isTrue);
      expect(sameMornings([morning(), morning()]), isFalse);
      final changed = morning()..[1] = task('Swim', 8);
      expect(sameMornings([morning(), changed, morning()]), isFalse);
    });

    test('finished more than 20 min after plan', () {
      expect(
        overrunsOf([
          task('A', 9, actualEndAfter: 21),
          task('B', 10, actualEndAfter: 20),
          task('C', 11),
        ]),
        1,
      );
    });
  });
}
